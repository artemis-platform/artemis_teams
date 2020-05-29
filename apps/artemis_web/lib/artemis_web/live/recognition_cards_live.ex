defmodule ArtemisWeb.RecognitionCardsLive do
  use ArtemisWeb.LiveView

  # LiveView Callbacks

  @impl true
  def mount(_params, session, socket) do
    user = Map.get(session, "user")
    recognitions = Map.get(session, "recognitions")

    assigns =
      socket
      |> assign(:recognitions, recognitions)
      |> assign(:user, user)

    {:ok, assigns}
  end

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "show/_cards.html", assigns)
  end
end
