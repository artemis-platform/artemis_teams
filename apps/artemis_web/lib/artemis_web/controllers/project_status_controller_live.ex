defmodule ArtemisWeb.ProjectStatusControllerLive do
  use ArtemisWeb.LiveView

  # LiveView Callbacks

  @impl true
  def mount(params, session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.ProjectStatusView, "index.html", assigns)
  end

  # GenServer Callbacks

  @impl true
  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
