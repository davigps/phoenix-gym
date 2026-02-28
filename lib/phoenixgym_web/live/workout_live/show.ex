defmodule PhoenixgymWeb.WorkoutLive.Show do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Workouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:history}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-2">
          <div class="navbar-start">
            <a href="/workout/history" class="btn btn-ghost btn-sm">
              <.icon name="hero-arrow-left" class="h-4 w-4" />
            </a>
          </div>
          <div class="navbar-center">
            <span class="font-semibold">{@workout.name || "Workout"}</span>
          </div>
          <div class="navbar-end">
            <button phx-click="delete" class="btn btn-ghost btn-sm text-error">
              <.icon name="hero-trash" class="h-4 w-4" />
            </button>
          </div>
        </div>

        <div class="p-4 space-y-4">
          <%!-- Summary Stats --%>
          <div class="grid grid-cols-3 gap-2">
            <div class="stat bg-base-200 rounded-box p-3">
              <div class="stat-title text-xs">Duration</div>
              <div class="stat-value text-lg">{format_duration(@workout.duration_seconds)}</div>
            </div>
            <div class="stat bg-base-200 rounded-box p-3">
              <div class="stat-title text-xs">Volume</div>
              <div class="stat-value text-lg">{format_volume(@workout.total_volume)}</div>
              <div class="stat-desc">kg</div>
            </div>
            <div class="stat bg-base-200 rounded-box p-3">
              <div class="stat-title text-xs">Sets</div>
              <div class="stat-value text-lg">{@workout.total_sets || 0}</div>
            </div>
          </div>

          <p class="text-sm text-base-content/60">
            {format_datetime(@workout.started_at)}
          </p>

          <%!-- Exercise Sections --%>
          <div class="space-y-4">
            <div :for={we <- @workout.workout_exercises} class="space-y-2">
              <div class="flex items-center justify-between">
                <h3 class="font-semibold">{we.exercise.name}</h3>
                <span class="badge badge-sm badge-ghost">{we.exercise.primary_muscle}</span>
              </div>

              <div class="overflow-x-auto">
                <table class="table table-xs w-full">
                  <thead>
                    <tr>
                      <th>#</th>
                      <th>Type</th>
                      <th>Weight (kg)</th>
                      <th>Reps</th>
                      <th>RPE</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr :for={set <- we.workout_sets} class={[set.is_completed && "bg-success/10"]}>
                      <td>{set.set_number}</td>
                      <td>
                        <span class="badge badge-xs">
                          {String.upcase(String.at(set.set_type, 0))}
                        </span>
                      </td>
                      <td>{if set.weight, do: Decimal.round(set.weight, 1), else: "—"}</td>
                      <td>{set.reps || "—"}</td>
                      <td>{if set.rpe, do: Decimal.round(set.rpe, 1), else: "—"}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    workout = Workouts.get_workout!(id)

    socket =
      socket
      |> assign(:workout, workout)
      |> assign(:page_title, workout.name || "Workout")

    {:ok, socket}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    case Workouts.delete_workout(socket.assigns.workout) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Workout deleted")
         |> push_navigate(to: "/workout/history")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to delete workout")}
    end
  end

  defp format_datetime(nil), do: ""
  defp format_datetime(dt), do: Calendar.strftime(dt, "%B %-d, %Y at %-I:%M %p")

  defp format_duration(nil), do: "—"

  defp format_duration(seconds) do
    h = div(seconds, 3600)
    m = div(rem(seconds, 3600), 60)
    if h > 0, do: "#{h}h #{m}m", else: "#{m}m"
  end

  defp format_volume(nil), do: "0"
  defp format_volume(vol), do: Decimal.round(vol, 1) |> Decimal.to_string()
end
