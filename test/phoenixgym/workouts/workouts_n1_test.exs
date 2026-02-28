defmodule Phoenixgym.WorkoutsN1Test do
  @moduledoc """
  N+1 regression: list_completed_workouts_with_exercises/1 must issue
  a bounded number of DB queries (no N+1 when loading workouts with exercises).
  """
  use Phoenixgym.DataCase, async: false

  import Phoenixgym.Fixtures

  alias Phoenixgym.Workouts

  test "list_completed_workouts_with_exercises issues bounded number of queries" do
    # Create 5 completed workouts, each with 2 exercises (so 10 workout_exercises total).
    # Without preload we would see 1 + N (workouts) + N (workout_exercises) or similar.
    # With proper preload we expect at most 2–3 queries (workouts + preloads).
    for _ <- 1..5 do
      ex1 = exercise_fixture()
      ex2 = exercise_fixture()

      {:ok, workout} =
        Workouts.start_workout(%{"name" => "N1 Workout #{System.unique_integer()}"})

      pos = Workouts.next_exercise_position(workout.id)
      {:ok, we1} = Workouts.create_workout_exercise(workout.id, ex1.id, pos)
      {:ok, we2} = Workouts.create_workout_exercise(workout.id, ex2.id, pos + 1)
      Workouts.create_workout_set(we1.id, 1, %{weight: "60", reps: 10, is_completed: true})
      Workouts.create_workout_set(we2.id, 1, %{weight: "80", reps: 8, is_completed: true})
      Workouts.finish_workout(workout)
    end

    query_count =
      count_queries(fn ->
        list = Workouts.list_completed_workouts_with_exercises(limit: 10, offset: 0)
        assert length(list) >= 5
        # Force access to preloaded associations so we would trigger N+1 if present
        Enum.each(list, fn w ->
          _ = w.workout_exercises
          Enum.each(w.workout_exercises, fn we -> _ = we.exercise end)
        end)
      end)

    # With a single query for workouts and one (or two) for preloads we stay under 5.
    assert query_count <= 5,
           "Expected at most 5 queries (no N+1), got #{query_count}"
  end

  defp count_queries(fun) do
    parent = self()
    ref = make_ref()

    handler = fn _event, _measurements, _metadata, _config ->
      send(parent, {:query})
    end

    :telemetry.attach(
      ref,
      [:phoenixgym, :repo, :query],
      handler,
      nil
    )

    try do
      fun.()
      Process.sleep(50)
      flush_queries(0)
    after
      :telemetry.detach(ref)
    end
  end

  defp flush_queries(count) do
    receive do
      {:query} -> flush_queries(count + 1)
    after
      0 -> count
    end
  end
end
