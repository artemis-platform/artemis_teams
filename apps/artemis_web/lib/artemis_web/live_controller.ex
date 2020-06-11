defmodule ArtemisWeb.LiveController do
  @moduledoc """
  Adds common functionality to LiveViews called directly from the router with
  many live_actions
  """

  defmacro __using__(_options) do
    quote do
      import ArtemisWeb.Guardian.Helpers
      import ArtemisWeb.UserAccess

      alias ArtemisWeb.Router.Helpers, as: Routes

      @impl true
      def mount(params, session, socket) do
        socket
        |> default_assigns(params, session)
        |> call_controller_mount_live_action()
      end

      @impl true
      def handle_params(params, url, socket) do
        assigns = [
          live_params: params,
          path: URI.parse(url).path,
          url: url
        ]

        {:noreply, assign(socket, assigns)}
      end

      @impl true
      def render(%{render_error: status_code} = assigns) do
        Phoenix.View.render(ArtemisWeb.ErrorView, "#{status_code}_live.html", assigns)
      end

      def render(assigns) do
        Phoenix.View.render(ArtemisWeb.RecognitionView, "#{assigns.live_action}.html", assigns)
      end

      # Authorization

      defp live_authorize(socket, permission, render_controller) do
        case has?(socket.assigns.user, permission) do
          true -> render_controller.()
          false -> {:ok, assign(socket, render_error: 403)}
        end
      end

      defp live_authorize_any(socket, permissions, render_controller) do
        case has_any?(socket.assigns.user, permissions) do
          true -> render_controller.()
          false -> {:ok, assign(socket, render_error: 403)}
        end
      end

      defp live_authorize_all(socket, permissions, render_controller) do
        case has_all?(socket.assigns.user, permissions) do
          true -> render_controller.()
          false -> {:ok, assign(socket, render_error: 403)}
        end
      end

      defp live_authorize_in_team(socket, team_id, render_controller) do
        case in_team?(socket.assigns.user, team_id) do
          true -> render_controller.()
          false -> {:ok, assign(socket, render_error: 403)}
        end
      end

      defp live_authorize_team_admin(socket, team_id, render_controller) do
        case team_admin?(socket.assigns.user, team_id) do
          true -> render_controller.()
          false -> {:ok, assign(socket, render_error: 403)}
        end
      end

      # Helpers

      defp default_assigns(socket, params, session) do
        user = current_user(session)

        socket
        |> assign(:live_params, params)
        |> assign(:live_session, session)
        |> assign(:user, user)
      end

      defp call_controller_mount_live_action(socket) do
        live_action(socket.assigns.live_action, socket, socket.assigns.live_params)
      end
    end
  end
end
