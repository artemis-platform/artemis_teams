defmodule ArtemisWeb.ViewHelper.Path do

  @doc """
  Returns the request path
  """
  def get_request_path(conn, options \\ []) do
    cond do
      path = Keyword.get(options, :path) -> path
      url = Keyword.get(options, :url) -> URI.parse(url).path
      true -> Map.get(conn, :request_path)
    end
  end
end
