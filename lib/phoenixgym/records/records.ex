defmodule Phoenixgym.Records do
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Records.PersonalRecord
  alias Phoenixgym.Workouts.WorkoutSet
  alias Phoenixgym.Workouts.WorkoutExercise
  alias Phoenixgym.WorkoutStats

  @doc "Returns all PRs for an exercise."
  def list_records_for_exercise(exercise_id) do
    from(pr in PersonalRecord,
      where: pr.exercise_id == ^exercise_id,
      order_by: [desc: pr.achieved_at]
    )
    |> Repo.all()
  end

  @doc "Returns the best PR of each type for an exercise."
  def get_best_records(exercise_id) do
    PersonalRecord.record_types()
    |> Enum.map(fn type ->
      record =
        from(pr in PersonalRecord,
          where: pr.exercise_id == ^exercise_id,
          where: pr.record_type == ^type,
          order_by: [desc: pr.value],
          limit: 1
        )
        |> Repo.one()

      {type, record}
    end)
    |> Enum.reject(fn {_type, record} -> is_nil(record) end)
    |> Map.new()
  end

  @doc "Returns recent PRs across all exercises."
  def list_recent_records(limit \\ 5) do
    from(pr in PersonalRecord,
      order_by: [desc: pr.achieved_at],
      limit: ^limit,
      preload: :exercise
    )
    |> Repo.all()
  end

  @doc "Returns one row per record_type for the exercise (the best PR of each type)."
  def list_prs_for_exercise(exercise_id) do
    get_best_records(exercise_id)
    |> Map.values()
    |> Enum.reject(&is_nil/1)
  end

  @doc "Returns the latest N PRs across all exercises, ordered by achieved_at descending."
  def get_recent_prs(limit \\ 5) do
    list_recent_records(limit)
  end

  @doc "Returns the set IDs (from the given workout) that have a personal record linked to them."
  def list_pr_set_ids_for_workout(workout_id) do
    set_ids_subquery =
      from(ws in WorkoutSet,
        join: we in WorkoutExercise,
        on: we.id == ws.workout_exercise_id,
        where: we.workout_id == ^workout_id,
        select: ws.id
      )

    from(pr in PersonalRecord,
      where: not is_nil(pr.workout_set_id),
      where: pr.workout_set_id in subquery(set_ids_subquery),
      select: pr.workout_set_id,
      distinct: true
    )
    |> Repo.all()
  end

  @doc "Checks and creates PR entries after a workout is finished. Uses WorkoutStats for pure PR computation."
  def compute_and_save_prs(workout) do
    workout =
      Repo.preload(workout,
        workout_exercises: [
          :exercise,
          workout_sets: []
        ]
      )

    candidates = WorkoutStats.compute_prs(workout)

    Enum.each(candidates, fn pr ->
      existing = get_best_records(pr.exercise_id)

      maybe_save_pr(
        pr.exercise_id,
        pr.record_type,
        pr.value,
        existing,
        pr.achieved_at,
        pr.workout_set_id
      )
    end)
  end

  defp maybe_save_pr(_exercise_id, _type, value, _existing, _achieved_at, _workout_set_id)
       when value in [nil] do
    :skip
  end

  defp maybe_save_pr(exercise_id, type, value, existing, achieved_at, workout_set_id) do
    existing_record = Map.get(existing, type)

    is_new_pr =
      case existing_record do
        nil -> Decimal.compare(value, Decimal.new(0)) == :gt
        record -> Decimal.compare(value, record.value) == :gt
      end

    if is_new_pr do
      attrs = %{
        exercise_id: exercise_id,
        record_type: type,
        value: value,
        achieved_at: achieved_at
      }

      attrs = if workout_set_id, do: Map.put(attrs, :workout_set_id, workout_set_id), else: attrs

      %PersonalRecord{}
      |> PersonalRecord.changeset(attrs)
      |> Repo.insert()
    end
  end
end
