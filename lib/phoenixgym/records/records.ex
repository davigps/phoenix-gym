defmodule Phoenixgym.Records do
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Records.PersonalRecord
  alias Phoenixgym.Workouts.WorkoutSet
  alias Phoenixgym.Workouts.WorkoutExercise

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

  @doc "Checks and creates PR entries after a workout is finished."
  def compute_and_save_prs(workout) do
    workout =
      Repo.preload(workout,
        workout_exercises: [
          :exercise,
          workout_sets: []
        ]
      )

    Enum.each(workout.workout_exercises, fn we ->
      completed_sets = Enum.filter(we.workout_sets, & &1.is_completed)
      exercise_id = we.exercise_id

      existing = get_best_records(exercise_id)

      if completed_sets == [] do
        :ok
      else
        # Max weight — set that achieved it
        max_weight_set =
          completed_sets |> Enum.max_by(fn s -> s.weight || Decimal.new(0) end, Decimal)

        max_weight = max_weight_set.weight || Decimal.new(0)

        maybe_save_pr(
          exercise_id,
          "max_weight",
          max_weight,
          existing,
          workout.finished_at,
          max_weight_set.id
        )

        # Max reps
        max_reps_set = completed_sets |> Enum.max_by(fn s -> s.reps || 0 end)
        max_reps = max_reps_set.reps || 0

        maybe_save_pr(
          exercise_id,
          "max_reps",
          Decimal.new(max_reps),
          existing,
          workout.finished_at,
          max_reps_set.id
        )

        # Estimated 1RM (Epley formula: weight * (1 + reps/30))
        best_1rm_set =
          completed_sets
          |> Enum.map(fn s ->
            val =
              if s.weight && s.reps && s.reps > 0 do
                Decimal.mult(
                  s.weight,
                  Decimal.add(Decimal.new(1), Decimal.div(Decimal.new(s.reps), Decimal.new(30)))
                )
              else
                Decimal.new(0)
              end

            {s, val}
          end)
          |> Enum.max_by(fn {_s, v} -> v end, Decimal)

        set_1rm = elem(best_1rm_set, 0)
        best_1rm = elem(best_1rm_set, 1)

        maybe_save_pr(
          exercise_id,
          "estimated_1rm",
          best_1rm,
          existing,
          workout.finished_at,
          set_1rm.id
        )

        # Max volume in single set (weight * reps)
        max_vol_set_tuple =
          completed_sets
          |> Enum.map(fn s ->
            weight = s.weight || Decimal.new(0)
            reps = s.reps || 0
            {s, Decimal.mult(weight, Decimal.new(reps))}
          end)
          |> Enum.max_by(fn {_s, v} -> v end, Decimal)

        max_vol_set_val = elem(max_vol_set_tuple, 1)
        max_vol_set_id = elem(max_vol_set_tuple, 0).id

        maybe_save_pr(
          exercise_id,
          "max_volume_set",
          max_vol_set_val,
          existing,
          workout.finished_at,
          max_vol_set_id
        )

        # Max volume in session — attribute to first completed set for display
        session_volume =
          Enum.reduce(completed_sets, Decimal.new(0), fn s, acc ->
            weight = s.weight || Decimal.new(0)
            reps = s.reps || 0
            Decimal.add(acc, Decimal.mult(weight, Decimal.new(reps)))
          end)

        first_set_id = completed_sets |> List.first() |> Map.get(:id)

        maybe_save_pr(
          exercise_id,
          "max_volume_session",
          session_volume,
          existing,
          workout.finished_at,
          first_set_id
        )
      end
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
