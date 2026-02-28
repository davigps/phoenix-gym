defmodule PhoenixgymWeb.ProfileLive.Index do
  use PhoenixgymWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:profile}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-4">
          <span class="font-semibold text-lg">Profile</span>
        </div>

        <div class="p-4 space-y-6">
          <%!-- Theme --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">Appearance</h2>
              <div class="flex items-center justify-between">
                <span class="text-sm">Theme</span>
                <Layouts.theme_toggle />
              </div>
            </div>
          </div>

          <%!-- Unit Preference --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">Units</h2>
              <div class="flex items-center justify-between">
                <span class="text-sm">Weight Unit</span>
                <div class="join">
                  <button
                    class={["btn btn-sm join-item", @unit == "kg" && "btn-primary"]}
                    phx-click="set_unit"
                    phx-value-unit="kg"
                  >
                    kg
                  </button>
                  <button
                    class={["btn btn-sm join-item", @unit == "lbs" && "btn-primary"]}
                    phx-click="set_unit"
                    phx-value-unit="lbs"
                  >
                    lbs
                  </button>
                </div>
              </div>
            </div>
          </div>

          <%!-- App Info --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">About</h2>
              <div class="space-y-2 text-sm">
                <div class="flex justify-between">
                  <span class="text-base-content/60">Version</span>
                  <span>1.0.0</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-base-content/60">Built with</span>
                  <span>Phoenix + LiveView</span>
                </div>
              </div>
            </div>
          </div>
        </div>
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
      |> assign(:page_title, "Profile")

    {:ok, socket}
  end

  @impl true
  def handle_event("set_unit", %{"unit" => unit}, socket) do
    {:noreply, assign(socket, unit: unit)}
  end
end
