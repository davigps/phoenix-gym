defmodule PhoenixgymWeb.DashboardLive.Index do
  use PhoenixgymWeb, :live_view

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
              <.icon name="hero-play" class="h-5 w-5" />
              Start Empty Workout
            </a>
          </div>
        </div>

        <%!-- This Week Stats --%>
        <div class="grid grid-cols-3 gap-2">
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">Workouts</div>
            <div class="stat-value text-xl">0</div>
            <div class="stat-desc">this week</div>
          </div>
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">Volume</div>
            <div class="stat-value text-xl">0</div>
            <div class="stat-desc">kg total</div>
          </div>
          <div class="stat bg-base-200 rounded-box p-3">
            <div class="stat-title text-xs">Sets</div>
            <div class="stat-value text-xl">0</div>
            <div class="stat-desc">completed</div>
          </div>
        </div>

        <p class="text-base-content/50 text-sm text-center py-8">
          Start your first workout to see stats here!
        </p>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
