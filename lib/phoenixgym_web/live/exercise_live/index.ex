defmodule PhoenixgymWeb.ExerciseLive.Index do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Exercises
  alias Phoenixgym.Exercises.Exercise

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:exercises}>
      <div class="flex flex-col h-full">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="flex-1">
            <span class="font-semibold text-lg">Exercises</span>
          </div>
          <div class="flex-none">
            <a href="/exercises/new" class="btn btn-ghost btn-sm gap-1">
              <.icon name="hero-plus" class="h-4 w-4" />
              Custom
            </a>
          </div>
        </div>

        <%!-- Search & Filters --%>
        <div class="p-3 space-y-2 bg-base-100 border-b border-base-300">
          <form phx-change="search" phx-submit="search">
            <label class="input input-bordered flex items-center gap-2 w-full">
              <.icon name="hero-magnifying-glass" class="h-4 w-4 opacity-50" />
              <input
                type="text"
                name="search"
                value={@search}
                placeholder="Search exercises..."
                class="grow"
                phx-debounce="200"
              />
            </label>
          </form>

          <%!-- Muscle filter chips --%>
          <div class="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
            <button
              class={["btn btn-xs", @muscle_filter == "" && "btn-primary"]}
              phx-click="filter_muscle"
              phx-value-muscle=""
            >
              All
            </button>
            <button
              :for={muscle <- Exercise.muscles()}
              class={["btn btn-xs", @muscle_filter == muscle && "btn-primary"]}
              phx-click="filter_muscle"
              phx-value-muscle={muscle}
            >
              {String.capitalize(muscle)}
            </button>
          </div>

          <%!-- Equipment filter chips --%>
          <div class="flex gap-2 overflow-x-auto pb-1 scrollbar-hide">
            <button
              class={["btn btn-xs btn-ghost", @equipment_filter == "" && "btn-active"]}
              phx-click="filter_equipment"
              phx-value-equipment=""
            >
              Any equipment
            </button>
            <button
              :for={eq <- Exercise.equipment_types()}
              class={["btn btn-xs btn-ghost", @equipment_filter == eq && "btn-active"]}
              phx-click="filter_equipment"
              phx-value-equipment={eq}
            >
              {String.capitalize(eq)}
            </button>
          </div>
        </div>

        <%!-- Exercise List --%>
        <div class="flex-1 overflow-y-auto divide-y divide-base-200">
          <div :if={@exercises == []} class="p-8 text-center text-base-content/50">
            No exercises found
          </div>
          <a
            :for={exercise <- @exercises}
            href={"/exercises/#{exercise.id}"}
            class="flex items-center gap-3 p-3 hover:bg-base-200 transition-colors"
          >
            <div class="flex-1 min-w-0">
              <p class="font-medium truncate">{exercise.name}</p>
              <div class="flex gap-1 mt-0.5">
                <span class="badge badge-sm badge-ghost">
                  {String.capitalize(exercise.primary_muscle || "")}
                </span>
                <span class="badge badge-sm badge-outline">
                  {exercise.equipment}
                </span>
              </div>
            </div>
            <.icon name="hero-chevron-right" class="h-4 w-4 text-base-content/40 shrink-0" />
          </a>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    exercises = Exercises.list_exercises()

    socket =
      socket
      |> assign(:exercises, exercises)
      |> assign(:search, "")
      |> assign(:muscle_filter, "")
      |> assign(:equipment_filter, "")
      |> assign(:page_title, "Exercises")

    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    exercises =
      Exercises.list_exercises(
        search: search,
        primary_muscle: socket.assigns.muscle_filter,
        equipment: socket.assigns.equipment_filter
      )

    {:noreply, assign(socket, exercises: exercises, search: search)}
  end

  @impl true
  def handle_event("filter_muscle", %{"muscle" => muscle}, socket) do
    exercises =
      Exercises.list_exercises(
        search: socket.assigns.search,
        primary_muscle: muscle,
        equipment: socket.assigns.equipment_filter
      )

    {:noreply, assign(socket, exercises: exercises, muscle_filter: muscle)}
  end

  @impl true
  def handle_event("filter_equipment", %{"equipment" => equipment}, socket) do
    exercises =
      Exercises.list_exercises(
        search: socket.assigns.search,
        primary_muscle: socket.assigns.muscle_filter,
        equipment: equipment
      )

    {:noreply, assign(socket, exercises: exercises, equipment_filter: equipment)}
  end
end
