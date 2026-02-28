defmodule PhoenixgymWeb.DashboardLive.Index do
  use PhoenixgymWeb, :live_view

  import PhoenixgymWeb.GymComponents, only: [volume_chart: 1]

  alias Phoenixgym.Stats
  alias Phoenixgym.Records
  alias Phoenixgym.Routines
  alias Phoenixgym.Units

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:dashboard} current_scope={@current_scope}>
      <div class="p-4 space-y-4">
        <h1 class="text-2xl font-bold">{gettext("PhoenixGym")}</h1>

        <%!-- Quick Start --%>
        <div class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">{gettext("Quick Start")}</h2>
            <a href="/workout/active" class="btn btn-primary w-full">
              <.icon name="hero-play" class="h-5 w-5" /> {gettext("Start Empty Workout")}
            </a>
            <div :if={@quick_start_routines != []} class="mt-2 space-y-1">
              <p class="text-xs text-base-content/60">{gettext("Or start from a routine:")}</p>
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
            <div class="stat-title text-xs">{gettext("Workouts")}</div>
            <div class="stat-value text-xl">{@workouts_this_week}</div>
            <div class="stat-desc">{gettext("this week")}</div>
          </div>
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">{gettext("Volume")}</div>
            <div class="stat-value text-xl">{format_volume(@volume_this_week, @unit)}</div>
            <div class="stat-desc">{gettext("%{unit} total", unit: @unit)}</div>
          </div>
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">{gettext("Sets")}</div>
            <div class="stat-value text-xl">{@sets_this_week}</div>
            <div class="stat-desc">{gettext("completed")}</div>
          </div>
        </div>

        <%!-- Streak --%>
        <div :if={@streak_count > 0} class="flex items-center gap-2 p-3 bg-base-200 rounded-box">
          <.icon name="hero-fire" class="h-5 w-5 text-primary" />
          <span class="font-medium">{gettext("%{count} day streak", count: @streak_count)}</span>
        </div>

        <%!-- Weekly Volume Chart --%>
        <div class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">{gettext("Weekly Volume")}</h2>
            <.volume_chart data={@weekly_volume} />
          </div>
        </div>

        <%!-- Top Muscle Groups --%>
        <div :if={@top_muscle_groups != []} class="card bg-base-200">
          <div class="card-body p-4">
            <h2 class="card-title text-base">{gettext("Top Muscle Groups")}</h2>
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
            <h2 class="card-title text-base">{gettext("Recent PRs")}</h2>
            <ul class="space-y-1">
              <li :for={pr <- @recent_prs} class="flex justify-between items-center text-sm">
                <span>{pr.exercise.name}</span>
                <span class="font-medium text-primary">
                  {pr_label(pr.record_type)}: {format_pr_value(pr, @unit)}
                </span>
              </li>
            </ul>
          </div>
        </div>

        <p :if={@workouts_this_week == 0} class="text-base-content/50 text-sm text-center py-8">
          {gettext("Start your first workout to see stats here!")}
        </p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    unit = Map.get(session, "unit", "kg")

    socket =
      socket
      |> assign(:unit, unit)
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

  defp format_volume(nil, _unit), do: "0"

  defp format_volume(vol, "kg") when is_struct(vol, Decimal),
    do: Decimal.round(vol, 1) |> Decimal.to_string()

  defp format_volume(vol, "lbs") when is_struct(vol, Decimal) do
    vol |> Decimal.to_float() |> Units.kg_to_lbs() |> Float.round(1) |> to_string()
  end

  defp format_volume(_, _), do: "0"

  defp format_muscle(nil), do: gettext("Other")
  defp format_muscle("full_body"), do: gettext("Full Body")
  defp format_muscle(m), do: String.capitalize(m)

  defp pr_label("max_weight"), do: gettext("Max")
  defp pr_label("max_reps"), do: gettext("Reps")
  defp pr_label("estimated_1rm"), do: gettext("1RM")
  defp pr_label("max_volume_set"), do: gettext("Set vol")
  defp pr_label("max_volume_session"), do: gettext("Session vol")
  defp pr_label(t), do: t

  defp format_pr_value(pr, unit) do
    if pr.record_type == "max_reps" do
      gettext("%{count} reps", count: Decimal.to_integer(pr.value))
    else
      Units.display_weight(pr.value, unit)
    end
  end
end
