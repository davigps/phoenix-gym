defmodule PhoenixgymWeb.DashboardLive.Index do
  use PhoenixgymWeb, :live_view

  import PhoenixgymWeb.GymComponents, only: [volume_chart: 1]

  alias Phoenixgym.Stats
  alias Phoenixgym.Records
  alias Phoenixgym.Routines

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:dashboard}>
      <div class="p-4 space-y-4">
        <h1 class="text-2xl font-bold">PhoenixGym</h1>

        <%!-- Quick Start --%>
        <div class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">Quick Start</h2>
            <a href="/workout/active" class="btn btn-primary w-full">
              <.icon name="hero-play" class="h-5 w-5" /> Start Empty Workout
            </a>
            <div :if={@quick_start_routines != []} class="mt-2 space-y-1">
              <p class="text-xs text-base-content/60">Or start from a routine:</p>
              <a
                :for={routine <- @quick_start_routines}
                href={"/workout/active?from_routine=#{routine.id}"}
                class="btn btn-sm btn-outline w-full justify-start"
              >
                <.icon name="hero-clipboard-document-list" class="h-4 w-4" />
                {routine.name}
              </a>
            </div>
          </div>
        </div>

        <%!-- This Week Stats --%>
        <div class="grid grid-cols-3 gap-2">
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">Workouts</div>
            <div class="stat-value text-xl">{@workouts_this_week}</div>
            <div class="stat-desc">this week</div>
          </div>
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">Volume</div>
            <div class="stat-value text-xl">{format_volume(@volume_this_week)}</div>
            <div class="stat-desc">kg total</div>
          </div>
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">Sets</div>
            <div class="stat-value text-xl">{@sets_this_week}</div>
            <div class="stat-desc">completed</div>
          </div>
        </div>

        <%!-- Streak --%>
        <div :if={@streak_count > 0} class="flex items-center gap-2 p-3 bg-base-200 rounded-box">
          <.icon name="hero-fire" class="h-5 w-5 text-primary" />
          <span class="font-medium">{@streak_count} day streak</span>
        </div>

        <%!-- Weekly Volume Chart --%>
        <div class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">Weekly Volume</h2>
            <.volume_chart data={@weekly_volume} />
          </div>
        </div>

        <%!-- Top Muscle Groups --%>
        <div :if={@top_muscle_groups != []} class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">Top Muscle Groups</h2>
            <div class="flex flex-wrap gap-2">
              <span
                :for={{muscle, count} <- @top_muscle_groups}
                class="badge badge-lg badge-primary"
              >
                {format_muscle(muscle)} · {count}
              </span>
            </div>
          </div>
        </div>

        <%!-- Recent PRs --%>
        <div :if={@recent_prs != []} class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">Recent PRs</h2>
            <ul class="space-y-1">
              <li :for={pr <- @recent_prs} class="flex justify-between items-center text-sm">
                <span>{pr.exercise.name}</span>
                <span class="font-medium text-primary">
                  {pr_label(pr.record_type)}: {format_pr_value(pr)}
                </span>
              </li>
            </ul>
          </div>
        </div>

        <p :if={@workouts_this_week == 0} class="text-base-content/50 text-sm text-center py-8">
          Start your first workout to see stats here!
        </p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:weekly_volume, Stats.weekly_volume())
      |> assign(:workouts_this_week, Stats.workouts_this_week())
      |> assign(:volume_this_week, Stats.volume_this_week())
      |> assign(:sets_this_week, Stats.sets_this_week())
      |> assign(:streak_count, Stats.streak_count())
      |> assign(:top_muscle_groups, Stats.top_muscle_groups(5))
      |> assign(:recent_prs, Records.get_recent_prs(5))
      |> assign(:quick_start_routines, Routines.list_routines() |> Enum.take(3))

    {:ok, socket}
  end

  defp format_volume(nil), do: "0"

  defp format_volume(vol) when is_struct(vol, Decimal),
    do: Decimal.round(vol, 1) |> Decimal.to_string()

  defp format_volume(_), do: "0"

  defp format_muscle(nil), do: "Other"
  defp format_muscle("full_body"), do: "Full Body"
  defp format_muscle(m), do: String.capitalize(m)

  defp pr_label("max_weight"), do: "Max"
  defp pr_label("max_reps"), do: "Reps"
  defp pr_label("estimated_1rm"), do: "1RM"
  defp pr_label("max_volume_set"), do: "Set vol"
  defp pr_label("max_volume_session"), do: "Session vol"
  defp pr_label(t), do: t

  defp format_pr_value(pr) do
    if pr.record_type == "max_reps" do
      "#{Decimal.to_integer(pr.value)} reps"
    else
      "#{Decimal.round(pr.value, 1)} kg"
    end
  end
end
