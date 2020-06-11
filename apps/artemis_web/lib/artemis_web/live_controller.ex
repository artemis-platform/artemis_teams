defmodule ArtemisWeb.LiveController do
  @moduledoc """
  Adds common functionality to LiveViews called directly from the router with
  many live_actions
  """

  defmacro __using__(_options) do
    quote do
      import ArtemisWeb.Guardian.Helpers
      import ArtemisWeb.UserAccess

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
      def render(assigns) do
        Phoenix.View.render(ArtemisWeb.RecognitionView, "#{assigns.live_action}.html", assigns)
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
