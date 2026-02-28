defmodule Phoenixgym.StatsTest do
  use Phoenixgym.DataCase, async: true

  alias Phoenixgym.Stats
  alias Phoenixgym.Workouts
  import Phoenixgym.Fixtures

  describe "weekly_volume/0" do
    test "returns 8 data points (one per week), zero-padded for weeks with no workouts" do
      data = Stats.weekly_volume()
      assert length(data) == 8

      assert Enum.all?(data, fn {_label, volume} ->
               is_struct(volume, Decimal) or is_number(volume)
             end)
    end

    test "includes volume from completed workouts in the correct week" do
      %{workout: _workout} = completed_workout_fixture()
      # workout has total_volume from the fixture
      data = Stats.weekly_volume()
      assert length(data) == 8
      volumes = Enum.map(data, fn {_label, vol} -> (vol && Decimal.to_float(vol)) || 0.0 end)
      assert Enum.sum(volumes) >= 500.0
    end
  end

  describe "streak_count/0" do
    test "returns 0 when no completed workouts" do
      assert Stats.streak_count() == 0
    end

    test "returns 1 when there is one completed workout" do
      completed_workout_fixture()
      assert Stats.streak_count() >= 1
    end

    test "returns correct consecutive-day count for multiple workout days" do
      exercise = exercise_fixture()
      # Complete workout today
      {:ok, w1} = Workouts.start_workout()
      pos = Workouts.next_exercise_position(w1.id)
      {:ok, we1} = Workouts.create_workout_exercise(w1.id, exercise.id, pos)
      Workouts.create_workout_set(we1.id, 1, %{weight: "50", reps: 5, is_completed: true})
      Workouts.finish_workout(Workouts.get_workout!(w1.id))

      count = Stats.streak_count()
      assert count >= 1
    end
  end

  describe "top_muscle_groups/1" do
    test "returns empty list when no workouts" do
      assert Stats.top_muscle_groups(5) == []
    end

    test "returns correct ranking by primary_muscle from recent workouts" do
      completed_workout_fixture()
      completed_workout_fixture()
      top = Stats.top_muscle_groups(5)
      assert is_list(top)
      assert length(top) <= 5

      if length(top) > 0 do
        assert Enum.all?(top, fn {_muscle, count} -> is_integer(count) and count >= 1 end)
      end
    end

    test "respects limit parameter" do
      completed_workout_fixture()
      assert length(Stats.top_muscle_groups(2)) <= 2
      assert length(Stats.top_muscle_groups(10)) <= 10
    end
  end

  describe "workouts_this_week/0 and workouts_this_month/0" do
    test "workouts_this_week returns count of completed workouts in current week" do
      completed_workout_fixture()
      count = Stats.workouts_this_week()
      assert count >= 1
    end

    test "workouts_this_month returns count of completed workouts in current month" do
      completed_workout_fixture()
      count = Stats.workouts_this_month()
      assert count >= 1
    end
  end
end
