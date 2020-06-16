defmodule ArtemisWeb.Router do
  use ArtemisWeb, :router

  require Ueberauth

  pipeline :browser do
    plug :accepts, ["html", "csv"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {ArtemisWeb.LayoutView, :root}
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
  end

  pipeline :require_auth do
    plug ArtemisWeb.Plug.ClientCredentials
    plug ArtemisWeb.Plug.BroadcastRequest
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", ArtemisWeb do
    pipe_through :browser
    pipe_through :read_auth

    scope "/auth" do
      get "/new", AuthController, :new
      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
      post "/:provider/callback", AuthController, :callback
      delete "/logout", AuthController, :delete
    end

    scope "/" do
      pipe_through :require_auth

      get "/", HomeController, :index

      # Application Config

      resources "/application-config", ApplicationConfigController, only: [:index, :show]

      # Docs

      resources "/docs", WikiPageController do
        get "/comments", WikiPageController, :index_comment, as: :comment
        post "/comments", WikiPageController, :create_comment, as: :comment
        get "/comments/:id/edit", WikiPageController, :edit_comment, as: :comment
        patch "/comments/:id", WikiPageController, :update_comment, as: :comment
        put "/comments/:id", WikiPageController, :update_comment, as: :comment
        delete "/comments/:id", WikiPageController, :delete_comment, as: :comment

        resources "/revisions", WikiRevisionController, only: [:index, :show, :delete], as: :revision

        put "/tags", WikiPageTagController, :update, as: :tag
      end

      get "/docs/:id/:slug", WikiPageController, :show

      # Event Logs

      resources "/event-logs", EventLogController, only: [:index, :show]

      # Events

      resources "/events", EventController do
        resources "/instances", EventInstanceController, as: :instance, except: [:new, :create] do
          post "/notifications", EventInstanceNotificationController, :create, as: :notification
        end

        resources "/integrations", EventIntegrationController, as: :integration
        resources "/questions", EventQuestionController, as: :question
        resources "/reports", EventReportController, as: :report, only: [:index]
      end

      # Features

      post "/features/bulk-actions", FeatureController, :index_bulk_actions
      get "/features/event-logs", FeatureController, :index_event_log_list
      get "/features/event-logs/:id", FeatureController, :index_event_log_details

      resources "/features", FeatureController do
        get "/event-logs", FeatureController, :show_event_log_list, as: :event_log
        get "/event-logs/:id", FeatureController, :show_event_log_details, as: :event_log
      end

      # HTTP Requests

      resources "/http-request-logs", HttpRequestLogController, only: [:index, :show]

      # Permissions

      post "/permissions/bulk-actions", PermissionController, :index_bulk_actions
      get "/permissions/event-logs", PermissionController, :index_event_log_list
      get "/permissions/event-logs/:id", PermissionController, :index_event_log_details

      resources "/permissions", PermissionController do
        get "/event-logs", PermissionController, :show_event_log_list, as: :event_log
        get "/event-logs/:id", PermissionController, :show_event_log_details, as: :event_log
      end

      # Projects

      resources "/projects", ProjectController

      # Recognitions

      resources "/recognitions", RecognitionController, only: [:index]

      live "/recognitions/new", RecognitionShowLive, :new
      live "/recognitions/:id", RecognitionShowLive, :show
      live "/recognitions/:id/comments/:comment_id/edit", RecognitionShowLive, :edit_comment
      live "/recognitions/:id/delete", RecognitionShowLive, :delete
      live "/recognitions/:id/edit", RecognitionShowLive, :edit

      # Roles

      post "/roles/bulk-actions", RoleController, :index_bulk_actions
      get "/roles/event-logs", RoleController, :index_event_log_list
      get "/roles/event-logs/:id", RoleController, :index_event_log_details

      resources "/roles", RoleController do
        get "/event-logs", RoleController, :show_event_log_list, as: :event_log
        get "/event-logs/:id", RoleController, :show_event_log_details, as: :event_log
      end

      # Search

      resources "/search", SearchController, only: [:index]

      # Sessions

      resources "/sessions", SessionController, only: [:index, :show]

      # System Tasks

      get "/system-tasks/event-logs", SystemTaskController, :index_event_log_list
      get "/system-tasks/event-logs/:id", SystemTaskController, :index_event_log_details

      resources "/system-tasks", SystemTaskController, only: [:index, :new, :create]

      # Tags

      post "/tags/bulk-actions", TagController, :index_bulk_actions
      get "/tags/event-logs", TagController, :index_event_log_list
      get "/tags/event-logs/:id", TagController, :index_event_log_details

      resources "/tags", TagController do
        get "/event-logs", TagController, :show_event_log_list, as: :event_log
        get "/event-logs/:id", TagController, :show_event_log_details, as: :event_log
      end

      # Teams

      get "/teams/event-logs", TeamController, :index_event_log_list
      get "/teams/event-logs/:id", TeamController, :index_event_log_details

      resources "/teams", TeamController do
        get "/event-logs", TeamController, :show_event_log_list, as: :event_log
        get "/event-logs/:id", TeamController, :show_event_log_details, as: :event_log
        resources "/members", TeamMemberController, as: :member
      end

      # Users

      post "/users/bulk-actions", UserController, :index_bulk_actions
      get "/users/event-logs", UserController, :index_event_log_list
      get "/users/event-logs/:id", UserController, :index_event_log_details

      resources "/users", UserController do
        resources "/anonymization", UserAnonymizationController, as: :anonymization, only: [:create]
        resources "/impersonation", UserImpersonationController, as: :impersonation, only: [:create]
        get "/event-logs", UserController, :show_event_log_list, as: :event_log
        get "/event-logs/:id", UserController, :show_event_log_details, as: :event_log
      end
    end
  end
end
