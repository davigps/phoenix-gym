defmodule Phoenixgym.Records do
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Records.PersonalRecord

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

  @doc "Checks and creates PR entries after a workout is finished."
  def compute_and_save_prs(workout) do
    workout = Repo.preload(workout,
      workout_exercises: [
        :exercise,
        workout_sets: []
      ]
    )

    Enum.each(workout.workout_exercises, fn we ->
      completed_sets = Enum.filter(we.workout_sets, & &1.is_completed)
      exercise_id = we.exercise_id

      existing = get_best_records(exercise_id)

      # Max weight
      max_weight = completed_sets |> Enum.map(&(&1.weight || Decimal.new(0))) |> Enum.max(Decimal, fn -> Decimal.new(0) end)
      maybe_save_pr(exercise_id, "max_weight", max_weight, existing, workout.finished_at)

      # Max reps
      max_reps = completed_sets |> Enum.map(&(&1.reps || 0)) |> Enum.max(fn -> 0 end)
      maybe_save_pr(exercise_id, "max_reps", Decimal.new(max_reps), existing, workout.finished_at)

      # Estimated 1RM (Epley formula: weight * (1 + reps/30))
      best_1rm =
        completed_sets
        |> Enum.map(fn s ->
          if s.weight && s.reps && s.reps > 0 do
            Decimal.mult(s.weight, Decimal.add(Decimal.new(1), Decimal.div(Decimal.new(s.reps), Decimal.new(30))))
          else
            Decimal.new(0)
          end
        end)
        |> Enum.max(Decimal, fn -> Decimal.new(0) end)

      maybe_save_pr(exercise_id, "estimated_1rm", best_1rm, existing, workout.finished_at)

      # Max volume in single set (weight * reps)
      max_vol_set =
        completed_sets
        |> Enum.map(fn s ->
          weight = s.weight || Decimal.new(0)
          reps = s.reps || 0
          Decimal.mult(weight, Decimal.new(reps))
        end)
        |> Enum.max(Decimal, fn -> Decimal.new(0) end)

      maybe_save_pr(exercise_id, "max_volume_set", max_vol_set, existing, workout.finished_at)

      # Max volume in session (sum of weight * reps for all completed sets)
      session_volume =
        Enum.reduce(completed_sets, Decimal.new(0), fn s, acc ->
          weight = s.weight || Decimal.new(0)
          reps = s.reps || 0
          Decimal.add(acc, Decimal.mult(weight, Decimal.new(reps)))
        end)

      maybe_save_pr(exercise_id, "max_volume_session", session_volume, existing, workout.finished_at)
    end)
  end

  defp maybe_save_pr(_exercise_id, _type, value, _existing, _achieved_at)
       when value in [nil] do
    :skip
  end

  defp maybe_save_pr(exercise_id, type, value, existing, achieved_at) do
    existing_record = Map.get(existing, type)

    is_new_pr =
      case existing_record do
        nil -> Decimal.compare(value, Decimal.new(0)) == :gt
        record -> Decimal.compare(value, record.value) == :gt
      end

    if is_new_pr do
      %PersonalRecord{}
      |> PersonalRecord.changeset(%{
        exercise_id: exercise_id,
        record_type: type,
        value: value,
        achieved_at: achieved_at
      })
      |> Repo.insert()
    end
  end
end
