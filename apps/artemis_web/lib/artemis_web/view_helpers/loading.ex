defmodule ArtemisWeb.ViewHelper.Loading do
  use Phoenix.HTML

  @doc """
  Renders a card with a loading skeleton
  """
  def render_loading_card() do
    Phoenix.View.render(ArtemisWeb.LayoutView, "loading_card.html", [])
  end
end
