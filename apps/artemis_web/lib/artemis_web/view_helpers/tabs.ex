defmodule ArtemisWeb.ViewHelper.Tabs do
  use Phoenix.HTML

  @moduledoc """
  Helper functions for rendering tabs
  """

  @doc """
  Render data tabs
  """
  def render_data_tabs(conn, tabs, options \\ []) do
    assigns = [
      conn: conn,
      content: Keyword.get(options, :do),
      tabs: tabs
    ]

    Phoenix.View.render(ArtemisWeb.LayoutView, "data_tabs.html", assigns)
  end
end
