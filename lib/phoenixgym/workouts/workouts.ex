defmodule Phoenixgym.Workouts do
  import Ecto.Query
  alias Phoenixgym.Repo
  alias Phoenixgym.Records
  alias Phoenixgym.Workouts.{Workout, WorkoutExercise, WorkoutSet}

  @doc "Returns completed workouts ordered by most recent."
  def list_workouts(opts \\ []) do
    status = Keyword.get(opts, :status, "completed")

    Workout
    |> where([w], w.status == ^status)
    |> order_by([w], desc: w.started_at)
    |> Repo.all()
  end

  @doc "Returns completed workouts ordered by finished_at descending, with pagination.
  Preloads workout_exercises and exercise to avoid N+1 when rendering history."
  def list_completed_workouts_with_exercises(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)

    query =
      Workout
      |> where([w], w.status == "completed")
      |> order_by([w], desc: w.finished_at, desc: w.id)
      |> limit(^limit)
      |> offset(^offset)

    query
    |> Repo.all()
    |> Repo.preload(workout_exercises: :exercise)
    |> Enum.map(fn w ->
      %{w | workout_exercises: Enum.sort_by(w.workout_exercises, & &1.position)}
    end)
  end

  @doc "Returns completed workouts ordered by finished_at descending, with pagination."
  def list_completed_workouts(opts \\ []) do
    limit = Keyword.get(opts, :limit, 20)
    offset = Keyword.get(opts, :offset, 0)

    Workout
    |> where([w], w.status == "completed")
    |> order_by([w], desc: w.finished_at, desc: w.id)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  @doc "Gets the current in-progress workout, if any."
  def get_in_progress_workout do
    Workout
    |> where([w], w.status == "in_progress")
    |> order_by([w], desc: w.inserted_at)
    |> limit(1)
    |> Repo.one()
  end

  @doc "Gets a workout with all associations preloaded."
  def get_workout!(id) do
    Workout
    |> Repo.get!(id)
    |> Repo.preload(
      workout_exercises: {
        from(we in WorkoutExercise, order_by: we.position),
        [:exercise, workout_sets: from(ws in WorkoutSet, order_by: ws.set_number)]
      }
    )
  end

  @doc "Starts a new empty workout."
  def start_workout(attrs \\ %{}) do
    attrs =
      Map.merge(
        %{"started_at" => DateTime.utc_now(), "status" => "in_progress", "name" => "Workout"},
        attrs
      )

    %Workout{}
    |> Workout.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Starts a workout from a routine, pre-populating exercises and sets."
  def start_workout_from_routine(routine) do
    routine = Repo.preload(routine, routine_exercises: [:exercise])

    Repo.transaction(fn ->
      {:ok, workout} =
        start_workout(%{
          "routine_id" => routine.id,
          "name" => routine.name
        })

      Enum.each(routine.routine_exercises, fn re ->
        {:ok, we} =
          create_workout_exercise(workout.id, re.exercise_id, re.position)

        Enum.each(1..re.target_sets, fn set_num ->
          create_workout_set(we.id, set_num)
        end)
      end)

      get_workout!(workout.id)
    end)
  end

  @doc "Finishes a workout, computing stats and marking PRs."
  def finish_workout(%Workout{} = workout) do
    workout =
      Repo.preload(
        workout,
        [workout_exercises: [workout_sets: []]],
        force: true
      )

    finished_at = DateTime.utc_now()
    started_at = workout.started_at
    duration = DateTime.diff(finished_at, started_at)

    completed_sets =
      workout.workout_exercises
      |> Enum.flat_map(& &1.workout_sets)
      |> Enum.filter(& &1.is_completed)

    total_sets = length(completed_sets)
    total_reps = Enum.sum(Enum.map(completed_sets, &(&1.reps || 0)))

    total_volume =
      completed_sets
      |> Enum.reduce(Decimal.new(0), fn set, acc ->
        weight = set.weight || Decimal.new(0)
        reps = set.reps || 0
        Decimal.add(acc, Decimal.mult(weight, Decimal.new(reps)))
      end)

    {:ok, updated} =
      workout
      |> Workout.changeset(%{
        status: "completed",
        finished_at: finished_at,
        duration_seconds: duration,
        total_sets: total_sets,
        total_reps: total_reps,
        total_volume: total_volume
      })
      |> Repo.update()

    Records.compute_and_save_prs(updated)
    {:ok, updated}
  end

  @doc "Discards an in-progress workout."
  def discard_workout(%Workout{} = workout) do
    workout
    |> Workout.changeset(%{status: "discarded"})
    |> Repo.update()
  end

  @doc "Updates workout notes."
  def update_workout(%Workout{} = workout, attrs) do
    workout
    |> Workout.changeset(attrs)
    |> Repo.update()
  end

  @doc "Deletes a workout."
  def delete_workout(%Workout{} = workout) do
    Repo.delete(workout)
  end

  # --- WorkoutExercise ---

  def create_workout_exercise(workout_id, exercise_id, position) do
    %WorkoutExercise{}
    |> WorkoutExercise.changeset(%{
      workout_id: workout_id,
      exercise_id: exercise_id,
      position: position
    })
    |> Repo.insert()
  end

  def next_exercise_position(workout_id) do
    from(we in WorkoutExercise,
      where: we.workout_id == ^workout_id,
      select: coalesce(max(we.position), -1)
    )
    |> Repo.one()
    |> Kernel.+(1)
  end

  def delete_workout_exercise(%WorkoutExercise{} = we) do
    Repo.delete(we)
  end

  @doc "Swaps the position of two adjacent workout exercises (moves `we` down one slot)."
  def move_workout_exercise_down(%WorkoutExercise{} = we, workout_id) do
    next =
      from(w in WorkoutExercise,
        where: w.workout_id == ^workout_id and w.position > ^we.position,
        order_by: w.position,
        limit: 1
      )
      |> Repo.one()

    if next do
      Repo.transaction(fn ->
        Repo.update_all(from(w in WorkoutExercise, where: w.id == ^we.id),
          set: [position: next.position]
        )

        Repo.update_all(from(w in WorkoutExercise, where: w.id == ^next.id),
          set: [position: we.position]
        )
      end)
    else
      {:ok, :already_last}
    end
  end

  @doc "Swaps the position of two adjacent workout exercises (moves `we` up one slot)."
  def move_workout_exercise_up(%WorkoutExercise{} = we, workout_id) do
    prev =
      from(w in WorkoutExercise,
        where: w.workout_id == ^workout_id and w.position < ^we.position,
        order_by: [desc: w.position],
        limit: 1
      )
      |> Repo.one()

    if prev do
      Repo.transaction(fn ->
        Repo.update_all(from(w in WorkoutExercise, where: w.id == ^we.id),
          set: [position: prev.position]
        )

        Repo.update_all(from(w in WorkoutExercise, where: w.id == ^prev.id),
          set: [position: we.position]
        )
      end)
    else
      {:ok, :already_first}
    end
  end

  @doc "Gets the previous completed sets for an exercise (from last workout)."
  def get_previous_sets(exercise_id, current_workout_id) do
    last_workout_exercise =
      from(we in WorkoutExercise,
        join: w in Workout,
        on: w.id == we.workout_id,
        where: we.exercise_id == ^exercise_id,
        where: w.id != ^current_workout_id,
        where: w.status == "completed",
        order_by: [desc: w.finished_at],
        limit: 1,
        select: we.id
      )
      |> Repo.one()

    if last_workout_exercise do
      from(ws in WorkoutSet,
        where: ws.workout_exercise_id == ^last_workout_exercise,
        where: ws.is_completed == true,
        order_by: ws.set_number
      )
      |> Repo.all()
    else
      []
    end
  end

  # --- WorkoutSet ---

  def create_workout_set(workout_exercise_id, set_number, attrs \\ %{}) do
    attrs =
      Map.merge(
        %{workout_exercise_id: workout_exercise_id, set_number: set_number},
        attrs
      )

    %WorkoutSet{}
    |> WorkoutSet.changeset(attrs)
    |> Repo.insert()
  end

  def update_workout_set(%WorkoutSet{} = set, attrs) do
    set
    |> WorkoutSet.changeset(attrs)
    |> Repo.update()
  end

  def delete_workout_set(%WorkoutSet{} = set) do
    Repo.delete(set)
  end

  def get_workout_set!(id), do: Repo.get!(WorkoutSet, id)
end
