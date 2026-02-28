defmodule PhoenixgymWeb.RoutineLive.Show do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Routines
  import PhoenixgymWeb.GymComponents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:routines}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="navbar-start">
            <a href="/routines" class="btn btn-ghost btn-sm">
              <.icon name="hero-arrow-left" class="h-4 w-4" />
            </a>
          </div>
          <div class="navbar-center">
            <span class="font-semibold">{@routine.name}</span>
          </div>
          <div class="navbar-end">
            <a href={"/routines/#{@routine.id}/edit"} class="btn btn-ghost btn-sm">
              {gettext("Edit")}
            </a>
          </div>
        </div>

        <div class="p-4 space-y-4">
          <p :if={@routine.notes} class="text-base-content/70 text-sm">{@routine.notes}</p>

          <%!-- Start Workout Button --%>
          <button phx-click="start_workout" class="btn btn-primary w-full">
            <.icon name="hero-play" class="h-5 w-5" /> {gettext("Start Workout")}
          </button>

          <%!-- Exercise List --%>
          <div>
            <h2 class="font-semibold mb-2">
              {gettext("%{count} Exercises", count: length(@routine.routine_exercises))}
            </h2>
            <div class="space-y-2">
              <div
                :for={re <- @routine.routine_exercises}
                class="flex items-center gap-3 p-3 bg-base-200 rounded-lg"
              >
                <div class="flex-1">
                  <p class="font-medium">{re.exercise.name}</p>
                  <p class="text-sm text-base-content/60">
                    {gettext("%{count} sets", count: re.target_sets)}
                  </p>
                </div>
              </div>
            </div>
          </div>

          <%!-- Actions --%>
          <div class="flex gap-2 pt-4">
            <button phx-click="duplicate" class="btn btn-ghost btn-sm flex-1">
              <.icon name="hero-document-duplicate" class="h-4 w-4" /> {gettext("Duplicate")}
            </button>
            <button phx-click="delete" class="btn btn-error btn-sm flex-1">
              <.icon name="hero-trash" class="h-4 w-4" /> {gettext("Delete")}
            </button>
          </div>
        </div>

        <.confirm_modal
          id="delete-routine-modal"
          title={gettext("Delete Routine")}
          message={gettext("Are you sure you want to delete this routine? This cannot be undone.")}
          confirm_event="confirm_delete"
          confirm_label={gettext("Delete")}
          confirm_class="btn-error"
        />
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    routine = Routines.get_routine!(id)

    socket =
      socket
      |> assign(:routine, routine)
      |> assign(:page_title, routine.name)

    {:ok, socket}
  end

  @impl true
  def handle_event("start_workout", _params, socket) do
    case Phoenixgym.Workouts.start_workout_from_routine(socket.assigns.routine) do
      {:ok, _workout} ->
        {:noreply, push_navigate(socket, to: "/workout/active")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to start workout"))}
    end
  end

  @impl true
  def handle_event("duplicate", _params, socket) do
    case Routines.duplicate_routine(socket.assigns.routine) do
      {:ok, new_routine} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Routine duplicated!"))
         |> push_navigate(to: "/routines/#{new_routine.id}/edit")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to duplicate routine"))}
    end
  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:noreply,
     socket
     |> push_event("js-exec", %{to: "#delete-routine-modal", attr: "showModal"})}
  end

  @impl true
  def handle_event("confirm_delete", _params, socket) do
    case Routines.delete_routine(socket.assigns.routine) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Routine deleted"))
         |> push_navigate(to: "/routines")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, gettext("Failed to delete routine"))}
    end
  end
end
