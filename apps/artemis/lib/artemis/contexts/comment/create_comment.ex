defmodule Artemis.CreateComment do
  use Artemis.Context

  alias Artemis.Comment
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating comment")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("comment:created", user)
    end)
  end

  defp insert_record(params) do
    params = create_params(params)

    %Comment{}
    |> Comment.changeset(params)
    |> Repo.insert()
  end

  defp create_params(params) do
    params = Artemis.Helpers.keys_to_strings(params)

    html =
      case Map.get(params, "body") do
        nil -> nil
        body -> Markdown.to_html!(body)
      end

    Map.put(params, "body_html", html)
  end
end
