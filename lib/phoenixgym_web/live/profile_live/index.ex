defmodule PhoenixgymWeb.ProfileLive.Index do
  use PhoenixgymWeb, :live_view

  alias Phoenixgym.Units

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} active_tab={:profile} current_scope={@current_scope}>
      <div class="flex flex-col">
        <%!-- Header --%>
        <div class="navbar bg-base-100 border-b border-base-300 sticky top-0 z-40 min-h-14 px-4">
          <span class="font-semibold text-lg">{gettext("Profile")}</span>
        </div>

        <div class="p-4 space-y-6">
          <%!-- Account (email + auth) --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">{gettext("Account")}</h2>
              <p :if={@current_scope && @current_scope.user} class="text-sm text-base-content/80">
                {@current_scope.user.email}
              </p>
              <div class="flex flex-col gap-2 mt-2">
                <.link
                  navigate={~p"/users/settings"}
                  class="btn btn-sm btn-outline justify-start"
                >
                  <.icon name="hero-cog-6-tooth" class="h-4 w-4" />
                  {gettext("Account settings")}
                </.link>
                <.link
                  href={~p"/users/log-out"}
                  method="delete"
                  class="btn btn-sm btn-outline btn-error justify-start text-error"
                  data-confirm={gettext("Are you sure you want to log out?")}
                >
                  <.icon name="hero-arrow-right-on-rectangle" class="h-4 w-4" />
                  {gettext("Log out")}
                </.link>
              </div>
            </div>
          </div>

          <%!-- Display Name --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">{gettext("Display Name")}</h2>
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
                  placeholder={gettext("Your name")}
                  class="input input-bordered w-full"
                />
                <button type="submit" class="btn btn-primary btn-sm">{gettext("Save")}</button>
              </form>
            </div>
          </div>

          <%!-- Theme --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">{gettext("Appearance")}</h2>
              <div class="flex items-center justify-between">
                <span class="text-sm">{gettext("Theme")}</span>
                <Layouts.theme_toggle />
              </div>
            </div>
          </div>

          <%!-- Unit Preference --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">{gettext("Units")}</h2>
              <div class="flex items-center justify-between">
                <span class="text-sm">{gettext("Weight Unit")}</span>
                <div class="join">
                  <.link
                    navigate={~p"/profile/set_unit?unit=kg"}
                    class={["btn btn-sm join-item", @unit == "kg" && "btn-primary"]}
                  >
                    {gettext("kg")}
                  </.link>
                  <.link
                    navigate={~p"/profile/set_unit?unit=lbs"}
                    class={["btn btn-sm join-item", @unit == "lbs" && "btn-primary"]}
                  >
                    {gettext("lbs")}
                  </.link>
                </div>
              </div>
              <p class="text-xs text-base-content/60 mt-2">
                {gettext("Sample: %{value}", value: Units.display_weight(Decimal.new("100"), @unit))}
              </p>
            </div>
          </div>

          <%!-- App Info --%>
          <div class="card bg-base-200">
            <div class="card-body p-4">
              <h2 class="card-title text-base">{gettext("About")}</h2>
              <div class="space-y-2 text-sm">
                <div class="flex justify-between">
                  <span class="text-base-content/60">{gettext("Version")}</span>
                  <span>1.0.0</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-base-content/60">{gettext("Built with")}</span>
                  <span>{gettext("Phoenix + LiveView")}</span>
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
      |> assign(:page_title, gettext("Profile"))

    {:ok, socket}
  end
end
