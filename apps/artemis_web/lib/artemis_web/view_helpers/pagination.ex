defmodule ArtemisWeb.ViewHelper.Pagination do
  use Phoenix.HTML

  @doc """
  Generates pagination
  """
  def render_pagination(conn_or_assigns, data, options \\ [])

  def render_pagination(%Plug.Conn{} = conn, data, options) do
    assigns = %{
      conn: conn,
      query_params: conn.query_params,
      request_path: conn.request_path
    }

    render_pagination(assigns, data, options)
  end

  def render_pagination(%Phoenix.LiveView.Socket{} = socket, data, options) do
    assigns = %{
      socket: socket,
      query_params: Keyword.get(options, :query_params),
      request_path: Keyword.get(options, :request_path)
    }

    render_pagination(assigns, data, options)
  end

  def render_pagination(assigns, %Scrivener.Page{} = data, options) do
    conn_or_socket = Map.get(assigns, :conn_or_socket) || Map.get(assigns, :conn) || Map.get(assigns, :socket)
    query_params = Map.get(assigns, :query_params)
    request_path = Map.get(assigns, :request_path)

    total_pages = Map.get(data, :total_pages, 1)
    args = Keyword.get(options, :args, [])
    params = Keyword.get(options, :params, [])

    query_params =
      query_params
      |> Artemis.Helpers.keys_to_atoms()
      |> Map.delete(:page)
      |> Enum.into([])

    params = Keyword.merge(query_params, params)

    assigns = [
      args: args,
      conn_or_socket: conn_or_socket,
      data: data,
      links: [],
      params: params,
      query_params: query_params,
      request_path: request_path,
      type: "scrivener"
    ]

    case total_pages > 1 do
      true -> Phoenix.View.render(ArtemisWeb.LayoutView, "pagination.html", assigns)
      false -> nil
    end
  end

  def render_pagination(_, _, _), do: nil

  @doc """
  Creates a pagination struct with the given entries
  """
  def paginate(entries) when is_list(entries) do
    size = length(entries)

    %Scrivener.Page{
      entries: entries,
      page_number: 1,
      page_size: size,
      total_entries: size,
      total_pages: 1
    }
  end

  def paginate(entry), do: paginate([entry])

  @doc """
  Returns the current request path and query params.

  Takes an optional second parameter, a map of query params to be merged with
  existing values.
  """
  def get_path_with_query_params(conn_or_assigns, new_params \\ %{})

  def get_path_with_query_params(%Plug.Conn{} = conn, new_params) do
    assigns = %{
      conn: conn,
      query_params: conn.query_params,
      request_path: conn.request_path
    }

    get_path_with_query_params(assigns, new_params)
  end

  def get_path_with_query_params(assigns, new_params) do
    query_params = Map.get(assigns, :query_params)
    request_path = Map.get(assigns, :request_path)

    new_params = Artemis.Helpers.keys_to_strings(new_params)
    current_params = Artemis.Helpers.keys_to_strings(query_params)
    merged_query_params = Artemis.Helpers.deep_merge(current_params, new_params)

    query_string = Plug.Conn.Query.encode(merged_query_params)
    path = "#{request_path}?#{query_string}"

    path
  end
end
