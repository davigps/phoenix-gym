defmodule PhoenixgymWeb.ProfileLive.Index do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Units

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
          <%!-- Display Name --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">Display Name</h2>
              <form
                id="profile-form"
                action="/profile/update_preferences"
                method="post"
                class="space-y-2"
              >
                <input type="hidden" name="_csrf_token" value={Phoenix.Controller.get_csrf_token()} />
                <input
                  type="text"
                  name="display_name"
                  value={@display_name}
                  placeholder="Your name"
                  class="input input-bordered w-full"
                />
                <button type="submit" class="btn btn-primary btn-sm">Save</button>
              </form>
            </div>
          </div>

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
                  <.link
                    navigate={~p"/profile/set_unit?unit=kg"}
                    class={["btn btn-sm join-item", @unit == "kg" && "btn-primary"]}
                  >
                    kg
                  </.link>
                  <.link
                    navigate={~p"/profile/set_unit?unit=lbs"}
                    class={["btn btn-sm join-item", @unit == "lbs" && "btn-primary"]}
                  >
                    lbs
                  </.link>
                </div>
              </div>
              <p class="text-xs text-base-content/60 mt-2">
                Sample: {Units.display_weight(Decimal.new("100"), @unit)}
              </p>
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
    display_name = Map.get(session, "display_name", "")

    socket =
      socket
      |> assign(:unit, unit)
      |> assign(:display_name, display_name)
      |> assign(:page_title, "Profile")

    {:ok, socket}
  end
end
