defmodule PhoenixgymWeb.WorkoutLive.History do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Workouts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:history}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-4">
          <span class="font-semibold text-lg">History</span>
        </div>

        <div class="p-4 space-y-3">
          <div :if={@workouts == []}>
            <div class="flex flex-col items-center justify-center py-16 text-center">
              <.icon name="hero-clock" class="h-12 w-12 text-base-content/30 mb-4" />
              <h3 class="font-semibold text-lg">No workouts yet</h3>
              <p class="text-base-content/60 text-sm mt-1">
                Complete your first workout to see it here
              </p>
              <a href="/workout/active" class="btn btn-primary mt-4">
                <.icon name="hero-play" class="h-4 w-4" />
                Start Workout
              </a>
            </div>
          </div>

          <a
            :for={workout <- @workouts}
            href={"/workout/#{workout.id}"}
            class="card bg-base-200 shadow-sm block"
          >
            <div class="card-body p-4">
              <div class="flex justify-between items-start">
                <div>
                  <h3 class="font-semibold">{workout.name || "Workout"}</h3>
                  <p class="text-sm text-base-content/60">
                    {format_datetime(workout.started_at)}
                  </p>
                </div>
                <.icon name="hero-chevron-right" class="h-5 w-5 text-base-content/40 mt-1" />
              </div>
              <div class="flex gap-4 mt-2 text-sm text-base-content/70">
                <span :if={workout.duration_seconds} class="flex items-center gap-1">
                  <.icon name="hero-clock" class="h-4 w-4" />
                  {format_duration(workout.duration_seconds)}
                </span>
                <span :if={workout.total_volume} class="flex items-center gap-1">
                  <.icon name="hero-bolt" class="h-4 w-4" />
                  {format_volume(workout.total_volume)} kg
                </span>
                <span :if={workout.total_sets} class="flex items-center gap-1">
                  <.icon name="hero-squares-2x2" class="h-4 w-4" />
                  {workout.total_sets} sets
                </span>
              </div>
            </div>
          </a>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    workouts = Workouts.list_workouts(status: "completed")

    socket =
      socket
      |> assign(:workouts, workouts)
      |> assign(:page_title, "History")

    {:ok, socket}
  end

  defp format_datetime(nil), do: ""

  defp format_datetime(dt) do
    Calendar.strftime(dt, "%b %-d, %Y · %-I:%M %p")
  end

  defp format_duration(nil), do: ""

  defp format_duration(seconds) do
    h = div(seconds, 3600)
    m = div(rem(seconds, 3600), 60)
    if h > 0, do: "#{h}h #{m}m", else: "#{m}m"
  end

  defp format_volume(nil), do: "0"
  defp format_volume(vol), do: Decimal.round(vol, 1) |> Decimal.to_string()
end
