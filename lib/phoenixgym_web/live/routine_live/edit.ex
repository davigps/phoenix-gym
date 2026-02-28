defmodule PhoenixgymWeb.RoutineLive.Edit do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Routines
  alias Phoenixgym.Exercises
  alias PhoenixgymWeb.CoreComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:routines}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="navbar-start">
            <a href={"/routines/#{@routine.id}"} class="btn btn-ghost btn-sm">
              <.icon name="hero-x-mark" class="h-4 w-4" />
            </a>
          </div>
          <div class="navbar-center">
            <span class="font-semibold">{gettext("Edit Routine")}</span>
          </div>
          <div class="navbar-end">
            <button phx-click="save" class="btn btn-primary btn-sm">{gettext("Save")}</button>
          </div>
        </div>

        <div class="p-4 space-y-4">
          <%!-- Name & Notes --%>
          <.form for={@form} phx-change="update_form" class="space-y-3">
            <input
              type="text"
              name="routine[name]"
              value={@form[:name].value}
              class="input input-bordered w-full font-semibold"
              placeholder={gettext("Routine name")}
            />
            <p :for={err <- @form[:name].errors} class="text-error text-sm mt-1">
              {CoreComponents.translate_error(err)}
            </p>
            <textarea
              name="routine[notes]"
              class="textarea textarea-bordered w-full"
              placeholder={gettext("Notes (optional)")}
              rows="2"
            >{@form[:notes].value}</textarea>
          </.form>

          <%!-- Exercises --%>
          <div>
            <h2 class="font-semibold mb-2">{gettext("Exercises")}</h2>
            <div
              :if={@routine.routine_exercises == []}
              class="text-base-content/50 text-sm text-center py-4"
            >
              {gettext("No exercises yet. Add some below!")}
            </div>
            <div class="space-y-2">
              <div
                :for={re <- @routine.routine_exercises}
                class="flex items-center gap-2 p-3 bg-base-200 rounded-lg"
              >
                <div class="flex flex-col gap-1">
                  <button
                    phx-click="move_up"
                    phx-value-id={re.exercise_id}
                    class="btn btn-ghost btn-xs p-0"
                  >
                    <.icon name="hero-chevron-up" class="h-3 w-3" />
                  </button>
                  <button
                    phx-click="move_down"
                    phx-value-id={re.exercise_id}
                    class="btn btn-ghost btn-xs p-0"
                  >
                    <.icon name="hero-chevron-down" class="h-3 w-3" />
                  </button>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="font-medium truncate">{re.exercise.name}</p>
                  <div class="flex items-center gap-2 mt-1">
                    <span class="text-sm text-base-content/60">{gettext("Sets:")}</span>
                    <input
                      type="number"
                      min="1"
                      max="20"
                      value={re.target_sets}
                      class="input input-bordered input-xs w-16"
                      phx-change="update_sets"
                      phx-value-id={re.id}
                      name="target_sets"
                    />
                  </div>
                </div>
                <button
                  phx-click="remove_exercise"
                  phx-value-id={re.id}
                  class="btn btn-ghost btn-sm text-error"
                >
                  <.icon name="hero-trash" class="h-4 w-4" />
                </button>
              </div>
            </div>
          </div>

          <%!-- Add Exercise Button --%>
          <button
            phx-click="show_picker"
            class="btn btn-outline w-full gap-2"
          >
            <.icon name="hero-plus" class="h-4 w-4" /> {gettext("Add Exercise")}
          </button>
        </div>

        <%!-- Exercise Picker Modal --%>
        <dialog id="exercise-picker" class={["modal modal-bottom", @show_picker && "modal-open"]}>
          <div class="modal-box p-0 h-[80vh] flex flex-col">
            <div class="p-4 border-b border-base-300">
              <div class="flex justify-between items-center mb-3">
                <h3 class="font-bold">{gettext("Add Exercise")}</h3>
                <button phx-click="hide_picker" class="btn btn-ghost btn-sm">
                  <.icon name="hero-x-mark" class="h-4 w-4" />
                </button>
              </div>
              <input
                type="text"
                phx-keyup="picker_search"
                phx-debounce="200"
                name="picker_search"
                placeholder={gettext("Search exercises...")}
                class="input input-bordered w-full"
              />
            </div>
            <div class="flex-1 overflow-y-auto divide-y divide-base-200">
              <button
                :for={exercise <- @picker_exercises}
                class="flex items-center gap-3 p-3 hover:bg-base-200 w-full text-left transition-colors"
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
            <button phx-click="hide_picker">{gettext("close")}</button>
          </form>
        </dialog>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    routine = Routines.get_routine!(id)
    exercises = Exercises.list_exercises()

    socket =
      socket
      |> assign(:routine, routine)
      |> assign(:form, to_form(Routines.change_routine(routine)))
      |> assign(:show_picker, false)
      |> assign(:picker_exercises, exercises)
      |> assign(:page_title, gettext("Edit %{name}", name: routine.name))

    {:ok, socket}
  end

  @impl true
  def handle_event("update_form", %{"routine" => params}, socket) do
    form = to_form(Routines.change_routine(socket.assigns.routine, params))
    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    params = extract_form_params(socket.assigns.form)

    case Routines.update_routine(socket.assigns.routine, params) do
      {:ok, _routine} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Routine saved!"))
         |> push_navigate(to: "/routines/#{socket.assigns.routine.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(Map.put(changeset, :action, :update)))}
    end
  end

  @impl true
  def handle_event("show_picker", _params, socket) do
    {:noreply, assign(socket, show_picker: true)}
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
    routine = socket.assigns.routine

    case Routines.add_exercise_to_routine(routine.id, String.to_integer(exercise_id)) do
      {:ok, _} ->
        updated_routine = Routines.get_routine!(routine.id)
        {:noreply, assign(socket, routine: updated_routine, show_picker: false)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to add exercise"))}
    end
  end

  @impl true
  def handle_event("remove_exercise", %{"id" => re_id}, socket) do
    routine = socket.assigns.routine
    re = Enum.find(routine.routine_exercises, &(to_string(&1.id) == re_id))

    if re do
      Routines.remove_exercise_from_routine(re)
      updated = Routines.get_routine!(routine.id)
      {:noreply, assign(socket, routine: updated)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("move_up", %{"id" => exercise_id}, socket) do
    Routines.move_exercise(socket.assigns.routine.id, String.to_integer(exercise_id), :up)
    updated = Routines.get_routine!(socket.assigns.routine.id)
    {:noreply, assign(socket, routine: updated)}
  end

  @impl true
  def handle_event("move_down", %{"id" => exercise_id}, socket) do
    Routines.move_exercise(socket.assigns.routine.id, String.to_integer(exercise_id), :down)
    updated = Routines.get_routine!(socket.assigns.routine.id)
    {:noreply, assign(socket, routine: updated)}
  end

  @impl true
  def handle_event("update_sets", %{"target_sets" => sets, "id" => re_id}, socket) do
    routine = socket.assigns.routine
    re = Enum.find(routine.routine_exercises, &(to_string(&1.id) == re_id))

    if re do
      Routines.update_routine_exercise(re, %{target_sets: String.to_integer(sets)})
      updated = Routines.get_routine!(routine.id)
      {:noreply, assign(socket, routine: updated)}
    else
      {:noreply, socket}
    end
  end

  defp extract_form_params(form) do
    %{
      "name" => form[:name].value,
      "notes" => form[:notes].value
    }
  end
end
