defmodule PhoenixgymWeb.Router do
  use PhoenixgymWeb, :router

  import PhoenixgymWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug PhoenixgymWeb.Plugs.PutLocale
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhoenixgymWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public auth routes: register and log-in (redirect to dashboard if already logged in)
  scope "/", PhoenixgymWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :current_user,
      on_mount: [{PhoenixgymWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
  end

  # Log-out (available when logged in; no auth required to call)
  scope "/", PhoenixgymWeb do
    pipe_through :browser

    delete "/users/log-out", UserSessionController, :delete
  end

  # Authenticated app routes: dashboard, exercises, routines, workout, profile, user settings
  scope "/", PhoenixgymWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{PhoenixgymWeb.UserAuth, :require_authenticated}] do
      # Dashboard
      live "/", DashboardLive.Index, :index

      # Exercises
      live "/exercises", ExerciseLive.Index, :index
      live "/exercises/new", ExerciseLive.New, :new
      live "/exercises/:id/edit", ExerciseLive.Edit, :edit
      live "/exercises/:id", ExerciseLive.Show, :show

      # Routines
      live "/routines", RoutineLive.Index, :index
      live "/routines/new", RoutineLive.Index, :new
      live "/routines/:id", RoutineLive.Show, :show
      live "/routines/:id/edit", RoutineLive.Edit, :edit

      # Workouts
      live "/workout/active", WorkoutLive.Active, :index
      live "/workout/history", WorkoutLive.History, :index
      live "/workout/:id", WorkoutLive.Show, :show

      # Profile
      live "/profile", ProfileLive.Index, :index

      # User settings
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    get "/profile/set_unit", ProfileController, :set_unit
    post "/profile/update_preferences", ProfileController, :update_preferences
    post "/users/update-password", UserSessionController, :update_password
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixgymWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phoenixgym, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhoenixgymWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
