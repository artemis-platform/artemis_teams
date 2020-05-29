defmodule ArtemisWeb.RecognitionCardComponent do
  use Phoenix.LiveComponent

  # LiveView Callbacks

  @impl true
  def render(assigns) do
    Phoenix.View.render(ArtemisWeb.RecognitionView, "show/_card.html", assigns)
  end
end
