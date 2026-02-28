defmodule Phoenixgym.Routines do
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Routines.{Routine, RoutineExercise}

  @doc "Returns all routines with their exercise count."
  def list_routines do
    Routine
    |> order_by([r], desc: r.updated_at)
    |> Repo.all()
    |> Repo.preload(routine_exercises: :exercise)
  end

  @doc "Gets a single routine with exercises preloaded."
  def get_routine!(id) do
    Routine
    |> Repo.get!(id)
    |> Repo.preload(
      routine_exercises: {from(re in RoutineExercise, order_by: re.position), :exercise}
    )
  end

  @doc "Creates a routine."
  def create_routine(attrs \\ %{}) do
    %Routine{}
    |> Routine.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Updates a routine."
  def update_routine(%Routine{} = routine, attrs) do
    routine
    |> Routine.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a routine."
  def delete_routine(%Routine{} = routine) do
    Repo.delete(routine)
  end

  @doc "Returns a changeset for the routine."
  def change_routine(%Routine{} = routine, attrs \\ %{}) do
    Routine.changeset(routine, attrs)
  end

  @doc "Adds an exercise to a routine."
  def add_exercise_to_routine(routine_id, exercise_id) do
    position = next_position(routine_id)

    %RoutineExercise{}
    |> RoutineExercise.changeset(%{
      routine_id: routine_id,
      exercise_id: exercise_id,
      position: position
    })
    |> Repo.insert()
  end

  @doc "Removes an exercise from a routine."
  def remove_exercise_from_routine(%RoutineExercise{} = routine_exercise) do
    Repo.delete(routine_exercise)
  end

  @doc "Updates target sets for a routine exercise."
  def update_routine_exercise(%RoutineExercise{} = re, attrs) do
    re
    |> RoutineExercise.changeset(attrs)
    |> Repo.update()
  end

  @doc "Reorders exercises in a routine by swapping positions."
  def move_exercise(routine_id, exercise_id, direction) when direction in [:up, :down] do
    routine = get_routine!(routine_id)
    exercises = routine.routine_exercises |> Enum.sort_by(& &1.position)
    current_idx = Enum.find_index(exercises, &(&1.exercise_id == exercise_id))

    target_idx =
      case direction do
        :up -> current_idx - 1
        :down -> current_idx + 1
      end

    if target_idx >= 0 and target_idx < length(exercises) do
      current = Enum.at(exercises, current_idx)
      target = Enum.at(exercises, target_idx)

      Repo.transaction(fn ->
        Repo.update!(RoutineExercise.changeset(current, %{position: target.position}))
        Repo.update!(RoutineExercise.changeset(target, %{position: current.position}))
      end)
    else
      {:ok, :noop}
    end
  end

  @doc "Duplicates a routine with all its exercises."
  def duplicate_routine(%Routine{} = routine) do
    routine = Repo.preload(routine, routine_exercises: :exercise)

    Repo.transaction(fn ->
      {:ok, new_routine} =
        create_routine(%{name: "#{routine.name} (Cópia)", notes: routine.notes})

      Enum.each(routine.routine_exercises, fn re ->
        Repo.insert!(%RoutineExercise{
          routine_id: new_routine.id,
          exercise_id: re.exercise_id,
          position: re.position,
          target_sets: re.target_sets
        })
      end)

      new_routine
    end)
  end

  defp next_position(routine_id) do
    from(re in RoutineExercise,
      where: re.routine_id == ^routine_id,
      select: coalesce(max(re.position), -1)
    )
    |> Repo.one()
    |> Kernel.+(1)
  end
end
