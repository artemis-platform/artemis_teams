defmodule ArtemisWeb.Router do
  use ArtemisWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html", "csv"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :read_auth do
    plug :fetch_session
    plug Guardian.Plug.Pipeline, module: ArtemisWeb.Guardian, error_handler: ArtemisWeb.Guardian.ErrorHandler
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug ArtemisWeb.Plug.BroadcastRequest
  end

  pipeline :require_auth do
    plug ArtemisWeb.Plug.ClientCredentials
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", ArtemisWeb do
    pipe_through :browser
    pipe_through :read_auth

    get "/", HomeController, :index

    scope "/auth" do
      get "/new", AuthController, :new
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
      post "/:provider/callback", AuthController, :callback
      delete "/logout", AuthController, :delete
    end

    scope "/" do
      pipe_through :require_auth

      resources "/standups", StandupController
      resources "/teams", TeamController do
        resources "/standups", TeamStandupController, only: [:index, :show], as: :standup
        resources "/users", TeamUserController, as: :user
      end
    end

    scope "/site" do
      pipe_through :require_auth

      get "/", SiteController, :index

      resources "/event-logs", EventLogController, only: [:index, :show]
      resources "/features", FeatureController
      resources "/permissions", PermissionController
      resources "/roles", RoleController
      resources "/search", SearchController, only: [:index]

      resources "/users", UserController do
        resources "/impersonation", UserImpersonationController, as: "impersonation", only: [:create]
      end
    end
  end
end
