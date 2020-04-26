defmodule ArtemisWeb.ViewHelper.Pagination do
  use Phoenix.HTML

  @doc """
  Generates pagination
  """
  def render_pagination(conn, data, options \\ [])

  def render_pagination(conn, %Scrivener.Page{} = data, options) do
    total_pages = Map.get(data, :total_pages, 1)
    args = Keyword.get(options, :args, [])
    params = Keyword.get(options, :params, [])

    query_params =
      conn.query_params
      |> Artemis.Helpers.keys_to_atoms()
      |> Map.delete(:page)
      |> Enum.into([])

    params = Keyword.merge(query_params, params)

    assigns = [
      args: args,
      conn: conn,
      data: data,
      links: [],
      params: params,
      type: "scrivener"
    ]

    case total_pages > 1 do
      true -> Phoenix.View.render(ArtemisWeb.LayoutView, "pagination.html", assigns)
      false -> nil
    end
  end

  @doc """
  Returns the current request path and query params.

  Takes an optional second parameter, a map of query params to be merged with
  existing values.
  """
  def get_path_with_query_params(conn, new_params \\ %{}) do
    new_params = Artemis.Helpers.keys_to_strings(new_params)
    current_params = Artemis.Helpers.keys_to_strings(conn.query_params)
    merged_query_params = Artemis.Helpers.deep_merge(current_params, new_params)

    query_string = Plug.Conn.Query.encode(merged_query_params)
    path = "#{conn.request_path}?#{query_string}"

    path
  end
end
