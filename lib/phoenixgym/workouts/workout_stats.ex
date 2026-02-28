defmodule Phoenixgym.WorkoutStats do
  @moduledoc """
  Pure logic for computing personal record candidates from a completed workout.
  No database access. Used by Records.compute_and_save_prs/1 to persist only
  PRs that beat existing records.
  """

  @doc """
  Returns a list of PR candidates for the given workout (completed sets only).
  Each candidate is a map: %{exercise_id, record_type, value, achieved_at, workout_set_id}.
  Records context should compare with existing PRs and only insert when value beats existing.
  """
  def compute_prs(workout) do
    achieved_at = get_finished_at(workout)
    workout_exercises = get_workout_exercises(workout)

    workout_exercises
    |> Enum.flat_map(fn we ->
      exercise_id = get_exercise_id(we)
      sets = get_workout_sets(we)
      completed = Enum.filter(sets, &get_completed/1)

      if completed == [] do
        []
      else
        [
          max_weight_pr(exercise_id, completed, achieved_at),
          max_reps_pr(exercise_id, completed, achieved_at),
          estimated_1rm_pr(exercise_id, completed, achieved_at),
          max_volume_set_pr(exercise_id, completed, achieved_at),
          max_volume_session_pr(exercise_id, completed, achieved_at)
        ]
        |> Enum.reject(&is_nil/1)
      end
    end)
  end

  defp get_finished_at(workout) do
    if is_struct(workout),
      do: workout.finished_at,
      else: workout["finished_at"] || workout[:finished_at]
  end

  defp get_workout_exercises(workout) do
    if is_struct(workout),
      do: workout.workout_exercises || [],
      else: workout["workout_exercises"] || workout[:workout_exercises] || []
  end

  defp get_exercise_id(we) do
    if is_struct(we), do: we.exercise_id, else: we["exercise_id"] || we[:exercise_id]
  end

  defp get_workout_sets(we) do
    if is_struct(we),
      do: we.workout_sets || [],
      else: we["workout_sets"] || we[:workout_sets] || []
  end

  defp get_completed(set) do
    if is_struct(set),
      do: set.is_completed,
      else: Map.get(set, :is_completed, Map.get(set, "is_completed", false))
  end

  defp get_weight(set) do
    w = if is_struct(set), do: set.weight, else: set[:weight] || set["weight"]
    if w, do: Decimal.new(w), else: Decimal.new(0)
  end

  defp get_reps(set) do
    r = if is_struct(set), do: set.reps, else: set[:reps] || set["reps"]
    r || 0
  end

  defp get_set_id(set) do
    if is_struct(set), do: set.id, else: set[:id] || set["id"]
  end

  defp max_weight_pr(exercise_id, completed, achieved_at) do
    set = Enum.max_by(completed, fn s -> get_weight(s) end, Decimal)

    %{
      exercise_id: exercise_id,
      record_type: "max_weight",
      value: get_weight(set),
      achieved_at: achieved_at,
      workout_set_id: get_set_id(set)
    }
  end

  defp max_reps_pr(exercise_id, completed, achieved_at) do
    set = Enum.max_by(completed, &get_reps/1)

    %{
      exercise_id: exercise_id,
      record_type: "max_reps",
      value: Decimal.new(get_reps(set)),
      achieved_at: achieved_at,
      workout_set_id: get_set_id(set)
    }
  end

  defp estimated_1rm_pr(exercise_id, completed, achieved_at) do
    {set, best_1rm} =
      completed
      |> Enum.map(fn s ->
        weight = get_weight(s)
        reps = get_reps(s)

        val =
          if reps > 0 do
            Decimal.mult(
              weight,
              Decimal.add(Decimal.new(1), Decimal.div(Decimal.new(reps), Decimal.new(30)))
            )
          else
            Decimal.new(0)
          end

        {s, val}
      end)
      |> Enum.max_by(fn {_, v} -> v end, Decimal)

    %{
      exercise_id: exercise_id,
      record_type: "estimated_1rm",
      value: best_1rm,
      achieved_at: achieved_at,
      workout_set_id: get_set_id(set)
    }
  end

  defp max_volume_set_pr(exercise_id, completed, achieved_at) do
    {set, volume} =
      completed
      |> Enum.map(fn s ->
        vol = Decimal.mult(get_weight(s), Decimal.new(get_reps(s)))
        {s, vol}
      end)
      |> Enum.max_by(fn {_, v} -> v end, Decimal)

    %{
      exercise_id: exercise_id,
      record_type: "max_volume_set",
      value: volume,
      achieved_at: achieved_at,
      workout_set_id: get_set_id(set)
    }
  end

  defp max_volume_session_pr(exercise_id, completed, achieved_at) do
    total =
      Enum.reduce(completed, Decimal.new(0), fn s, acc ->
        vol = Decimal.mult(get_weight(s), Decimal.new(get_reps(s)))
        Decimal.add(acc, vol)
      end)

    first_set_id = completed |> List.first() |> get_set_id()

    %{
      exercise_id: exercise_id,
      record_type: "max_volume_session",
      value: total,
      achieved_at: achieved_at,
      workout_set_id: first_set_id
    }
  end
end
