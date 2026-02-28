defmodule PhoenixgymWeb.Router do
  use PhoenixgymWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhoenixgymWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixgymWeb do
    pipe_through :browser

    # Dashboard
    live "/", DashboardLive.Index, :index

    # Exercises
    live "/exercises", ExerciseLive.Index, :index
    live "/exercises/new", ExerciseLive.New, :new
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
    get "/profile/set_unit", ProfileController, :set_unit
    post "/profile/update_preferences", ProfileController, :update_preferences
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixgymWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:phoenixgym, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhoenixgymWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
