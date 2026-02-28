defmodule PhoenixgymWeb.WorkoutLive.Active do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Workouts
  alias Phoenixgym.Exercises

  @rest_timer_default 90

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:workout}>
      <div class="flex flex-col">
        <%= if @workout do %>
          <%!-- Active Workout Header --%>
          <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
            <div class="navbar-start">
              <button phx-click="discard" class="btn btn-ghost btn-sm text-error">
                <.icon name="hero-x-mark" class="h-4 w-4" />
              </button>
            </div>
            <div class="navbar-center">
              <span
                class="font-mono text-sm"
                id="elapsed-timer"
                phx-hook="WorkoutTimer"
                data-started-at={DateTime.to_unix(@workout.started_at)}
              >
                00:00:00
              </span>
            </div>
            <div class="navbar-end">
              <button phx-click="finish" class="btn btn-primary btn-sm">
                Finish
              </button>
            </div>
          </div>

          <%!-- Rest Timer Bar --%>
          <div :if={@rest_timer} class="px-4 py-2 bg-base-200 border-b border-base-300">
            <div class="flex items-center gap-3">
              <.icon name="hero-clock" class="h-4 w-4 text-primary shrink-0" />
              <div class="flex-1">
                <div class="flex justify-between text-xs mb-1">
                  <span class="font-medium">Rest</span>
                  <span class="font-mono">{format_rest(@rest_timer.remaining)}s</span>
                </div>
                <progress
                  class="progress progress-primary w-full"
                  value={@rest_timer.remaining}
                  max={@rest_timer.total}
                >
                </progress>
              </div>
              <button phx-click="skip_rest_timer" class="btn btn-ghost btn-xs">
                Skip
              </button>
            </div>
          </div>

          <%!-- Workout Notes --%>
          <div class="px-4 pt-3">
            <input
              type="text"
              placeholder="Workout notes..."
              value={@workout.notes}
              phx-blur="update_notes"
              name="notes"
              class="input input-ghost w-full text-sm"
            />
          </div>

          <%!-- Exercise Sections --%>
          <div class="p-4 space-y-6">
            <div :for={{item, idx} <- Enum.with_index(@exercises)} class="space-y-2">
              <%!-- Exercise Header --%>
              <div class="flex items-center justify-between">
                <div>
                  <h3 class="font-semibold">{item.exercise.name}</h3>
                  <span class="badge badge-sm badge-ghost">{item.exercise.primary_muscle}</span>
                </div>
                <div class="flex gap-1">
                  <button
                    :if={idx > 0}
                    phx-click="move_exercise_up"
                    phx-value-id={item.workout_exercise.id}
                    class="btn btn-ghost btn-xs"
                    aria-label="Move up"
                  >
                    <.icon name="hero-chevron-up" class="h-3 w-3" />
                  </button>
                  <button
                    :if={idx < length(@exercises) - 1}
                    phx-click="move_exercise_down"
                    phx-value-id={item.workout_exercise.id}
                    class="btn btn-ghost btn-xs"
                    aria-label="Move down"
                  >
                    <.icon name="hero-chevron-down" class="h-3 w-3" />
                  </button>
                </div>
              </div>

              <%!-- Previous Sets Reference --%>
              <div
                :if={item.previous_sets != []}
                class="text-xs text-base-content/50 flex gap-2 flex-wrap"
              >
                <span class="font-medium">Last:</span>
                <span :for={s <- item.previous_sets}>
                  {if s.weight, do: "#{Decimal.round(s.weight, 1)}kg", else: "—"}×{s.reps || "—"}
                </span>
              </div>

              <%!-- Sets Table --%>
              <div class="overflow-x-auto">
                <table class="table table-xs w-full">
                  <thead>
                    <tr>
                      <th class="w-8">#</th>
                      <th class="w-16">Type</th>
                      <th>kg</th>
                      <th>Reps</th>
                      <th class="w-8">✓</th>
                      <th class="w-8"></th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      :for={set <- item.sets}
                      class={[set.is_completed && "bg-success/20 text-success"]}
                    >
                      <td>{set.set_number}</td>
                      <td>
                        <select
                          class="select select-xs select-ghost w-14"
                          phx-change="update_set_type"
                          phx-value-id={set.id}
                          name="set_type"
                        >
                          <option value="warmup" selected={set.set_type == "warmup"}>W</option>
                          <option value="normal" selected={set.set_type == "normal"}>N</option>
                          <option value="drop" selected={set.set_type == "drop"}>D</option>
                        </select>
                      </td>
                      <td>
                        <input
                          type="number"
                          min="0"
                          step="0.5"
                          value={if set.weight, do: Decimal.to_string(set.weight), else: ""}
                          phx-blur="update_set"
                          phx-value-id={set.id}
                          phx-value-field="weight"
                          name="weight"
                          class="input input-xs input-ghost w-16"
                          placeholder="0"
                        />
                      </td>
                      <td>
                        <input
                          type="number"
                          min="0"
                          value={set.reps || ""}
                          phx-blur="update_set"
                          phx-value-id={set.id}
                          phx-value-field="reps"
                          name="reps"
                          class="input input-xs input-ghost w-14"
                          placeholder="0"
                        />
                      </td>
                      <td>
                        <input
                          type="checkbox"
                          checked={set.is_completed}
                          phx-click="toggle_complete"
                          phx-value-id={set.id}
                          class="checkbox checkbox-xs checkbox-success"
                        />
                      </td>
                      <td>
                        <button
                          phx-click="remove_set"
                          phx-value-id={set.id}
                          class="btn btn-ghost btn-xs text-error"
                          aria-label="Remove set"
                        >
                          <.icon name="hero-x-mark" class="h-3 w-3" />
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>

              <button
                phx-click="add_set"
                phx-value-workout-exercise-id={item.workout_exercise.id}
                class="btn btn-ghost btn-xs w-full gap-1"
              >
                <.icon name="hero-plus" class="h-3 w-3" /> Add Set
              </button>
            </div>

            <%!-- Add Exercise --%>
            <button phx-click="show_picker" class="btn btn-outline w-full gap-2">
              <.icon name="hero-plus" class="h-4 w-4" /> Add Exercise
            </button>
          </div>

          <%!-- Exercise Picker Modal --%>
          <dialog id="exercise-picker" class={["modal modal-bottom", @show_picker && "modal-open"]}>
            <div class="modal-box p-0 h-[80vh] flex flex-col">
              <div class="p-4 border-b border-base-300">
                <div class="flex justify-between items-center mb-3">
                  <h3 class="font-bold">Add Exercise</h3>
                  <button phx-click="hide_picker" class="btn btn-ghost btn-sm">
                    <.icon name="hero-x-mark" class="h-4 w-4" />
                  </button>
                </div>
                <input
                  type="text"
                  phx-keyup="picker_search"
                  phx-debounce="200"
                  name="picker_search"
                  placeholder="Search exercises..."
                  class="input input-bordered w-full"
                />
              </div>
              <div class="flex-1 overflow-y-auto divide-y divide-base-200">
                <button
                  :for={exercise <- @picker_exercises}
                  class="flex items-center gap-3 p-3 hover:bg-base-200 w-full text-left"
                  phx-click="add_exercise"
                  phx-value-id={exercise.id}
                >
                  <div class="flex-1">
                    <p class="font-medium">{exercise.name}</p>
                    <p class="text-sm text-base-content/60">
                      {String.capitalize(exercise.primary_muscle || "")} · {exercise.equipment}
                    </p>
                  </div>
                </button>
              </div>
            </div>
            <form method="dialog" class="modal-backdrop">
              <button phx-click="hide_picker">close</button>
            </form>
          </dialog>

          <%!-- Discard Confirmation Modal --%>
          <dialog
            id="discard-modal"
            class={["modal modal-bottom sm:modal-middle", @show_discard_modal && "modal-open"]}
          >
            <div class="modal-box">
              <h3 class="font-bold text-lg">Discard Workout?</h3>
              <p class="py-4 text-base-content/70">
                All progress will be lost. This cannot be undone.
              </p>
              <div class="modal-action">
                <button phx-click="cancel_discard" class="btn btn-ghost">Keep Going</button>
                <button phx-click="confirm_discard" class="btn btn-error">Discard</button>
              </div>
            </div>
          </dialog>
        <% else %>
          <%!-- No Active Workout --%>
          <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-4">
            <span class="font-semibold text-lg">Workout</span>
          </div>

          <div class="flex flex-col items-center justify-center py-16 px-4 text-center">
            <.icon name="hero-bolt" class="h-16 w-16 text-primary mb-4" />
            <h2 class="text-xl font-bold mb-2">Ready to train?</h2>
            <p class="text-base-content/60 mb-6">Start a new workout or pick from your routines</p>

            <button phx-click="start_empty" class="btn btn-primary w-full max-w-sm mb-3">
              <.icon name="hero-play" class="h-5 w-5" /> Start Empty Workout
            </button>

            <a href="/routines" class="btn btn-outline w-full max-w-sm">
              <.icon name="hero-clipboard-document-list" class="h-5 w-5" /> Choose Routine
            </a>
          </div>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    workout = Workouts.get_in_progress_workout()

    socket =
      if workout do
        workout = Workouts.get_workout!(workout.id)
        load_workout_state(socket, workout)
      else
        socket
        |> assign(:workout, nil)
        |> assign(:exercises, [])
      end

    socket =
      socket
      |> assign(:show_picker, false)
      |> assign(:show_discard_modal, false)
      |> assign(:rest_timer, nil)
      |> assign(:picker_exercises, Exercises.list_exercises())
      |> assign(:page_title, "Workout")

    {:ok, socket}
  end

  defp load_workout_state(socket, workout) do
    exercises =
      Enum.map(workout.workout_exercises, fn we ->
        previous_sets = Workouts.get_previous_sets(we.exercise_id, workout.id)

        %{
          workout_exercise: we,
          exercise: we.exercise,
          sets: we.workout_sets,
          previous_sets: previous_sets
        }
      end)

    socket
    |> assign(:workout, workout)
    |> assign(:exercises, exercises)
  end

  @impl true
  def handle_event("start_empty", _params, socket) do
    case Workouts.start_workout() do
      {:ok, workout} ->
        workout = Workouts.get_workout!(workout.id)
        {:noreply, load_workout_state(socket, workout)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to start workout")}
    end
  end

  @impl true
  def handle_event("finish", _params, socket) do
    case Workouts.finish_workout(socket.assigns.workout) do
      {:ok, workout} ->
        Phoenixgym.Records.compute_and_save_prs(workout)

        {:noreply,
         socket
         |> put_flash(:info, "Workout completed!")
         |> push_navigate(to: "/workout/#{workout.id}")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to finish workout")}
    end
  end

  @impl true
  def handle_event("discard", _params, socket) do
    {:noreply, assign(socket, show_discard_modal: true)}
  end

  @impl true
  def handle_event("confirm_discard", _params, socket) do
    case Workouts.discard_workout(socket.assigns.workout) do
      {:ok, _} ->
        {:noreply,
         socket
         |> assign(:workout, nil)
         |> assign(:exercises, [])
         |> assign(:rest_timer, nil)
         |> assign(:show_discard_modal, false)
         |> put_flash(:info, "Workout discarded")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to discard workout")}
    end
  end

  @impl true
  def handle_event("cancel_discard", _params, socket) do
    {:noreply, assign(socket, show_discard_modal: false)}
  end

  @impl true
  def handle_event("update_notes", %{"value" => notes}, socket) do
    Workouts.update_workout(socket.assigns.workout, %{notes: notes})
    {:noreply, assign(socket, workout: %{socket.assigns.workout | notes: notes})}
  end

  @impl true
  def handle_event("add_set", %{"workout-exercise-id" => we_id}, socket) do
    we_id = String.to_integer(we_id)
    exercise_item = Enum.find(socket.assigns.exercises, &(&1.workout_exercise.id == we_id))

    if exercise_item do
      next_num = length(exercise_item.sets) + 1
      {:ok, _set} = Workouts.create_workout_set(we_id, next_num)
      workout = Workouts.get_workout!(socket.assigns.workout.id)
      {:noreply, load_workout_state(socket, workout)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("remove_set", %{"id" => set_id}, socket) do
    set = Workouts.get_workout_set!(String.to_integer(set_id))
    Workouts.delete_workout_set(set)
    workout = Workouts.get_workout!(socket.assigns.workout.id)
    {:noreply, load_workout_state(socket, workout)}
  end

  @impl true
  def handle_event("toggle_complete", %{"id" => set_id}, socket) do
    set = Workouts.get_workout_set!(String.to_integer(set_id))
    new_completed = !set.is_completed
    Workouts.update_workout_set(set, %{is_completed: new_completed})
    workout = Workouts.get_workout!(socket.assigns.workout.id)

    socket = load_workout_state(socket, workout)

    socket =
      if new_completed do
        timer = %{remaining: @rest_timer_default, total: @rest_timer_default}
        Process.send_after(self(), :rest_tick, 1000)
        assign(socket, rest_timer: timer)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_set", %{"id" => set_id, "field" => field, "value" => value}, socket) do
    set = Workouts.get_workout_set!(String.to_integer(set_id))
    Workouts.update_workout_set(set, %{field => value})
    workout = Workouts.get_workout!(socket.assigns.workout.id)
    {:noreply, load_workout_state(socket, workout)}
  end

  @impl true
  def handle_event("update_set_type", %{"id" => set_id, "set_type" => set_type}, socket) do
    set = Workouts.get_workout_set!(String.to_integer(set_id))
    Workouts.update_workout_set(set, %{set_type: set_type})
    workout = Workouts.get_workout!(socket.assigns.workout.id)
    {:noreply, load_workout_state(socket, workout)}
  end

  @impl true
  def handle_event("skip_rest_timer", _params, socket) do
    {:noreply, assign(socket, rest_timer: nil)}
  end

  @impl true
  def handle_event("move_exercise_up", %{"id" => we_id}, socket) do
    we =
      Enum.find(socket.assigns.exercises, &(&1.workout_exercise.id == String.to_integer(we_id)))

    if we do
      Workouts.move_workout_exercise_up(we.workout_exercise, socket.assigns.workout.id)
      workout = Workouts.get_workout!(socket.assigns.workout.id)
      {:noreply, load_workout_state(socket, workout)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("move_exercise_down", %{"id" => we_id}, socket) do
    we =
      Enum.find(socket.assigns.exercises, &(&1.workout_exercise.id == String.to_integer(we_id)))

    if we do
      Workouts.move_workout_exercise_down(we.workout_exercise, socket.assigns.workout.id)
      workout = Workouts.get_workout!(socket.assigns.workout.id)
      {:noreply, load_workout_state(socket, workout)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("show_picker", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_picker, true)
     |> assign(:picker_exercises, Exercises.list_exercises())}
  end

  @impl true
  def handle_event("hide_picker", _params, socket) do
    {:noreply, assign(socket, show_picker: false)}
  end

  @impl true
  def handle_event("picker_search", %{"value" => search}, socket) do
    exercises = Exercises.list_exercises(search: search)
    {:noreply, assign(socket, picker_exercises: exercises)}
  end

  @impl true
  def handle_event("add_exercise", %{"id" => exercise_id}, socket) do
    workout = socket.assigns.workout
    position = Workouts.next_exercise_position(workout.id)

    case Workouts.create_workout_exercise(workout.id, String.to_integer(exercise_id), position) do
      {:ok, we} ->
        Workouts.create_workout_set(we.id, 1)
        workout = Workouts.get_workout!(workout.id)
        {:noreply, socket |> load_workout_state(workout) |> assign(show_picker: false)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to add exercise")}
    end
  end

  @impl true
  def handle_info(:rest_tick, socket) do
    case socket.assigns.rest_timer do
      nil ->
        {:noreply, socket}

      %{remaining: 0} ->
        {:noreply, assign(socket, rest_timer: nil)}

      %{remaining: n, total: total} ->
        Process.send_after(self(), :rest_tick, 1000)
        {:noreply, assign(socket, rest_timer: %{remaining: n - 1, total: total})}
    end
  end

  defp format_rest(seconds), do: Integer.to_string(seconds)
end
