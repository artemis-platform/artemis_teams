defmodule Artemis.UpdateReaction do
  use Artemis.Context

  alias Artemis.Reaction
  alias Artemis.GetReaction
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating reaction")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> Event.broadcast("reaction:updated", user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetReaction.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    params = update_params(record, params)

    record
    |> Reaction.changeset(params)
    |> Repo.update()
  end

  defp update_params(_record, params) do
    params = Artemis.Helpers.keys_to_strings(params)

    case Map.get(params, "body") do
      nil -> params
      body -> Map.put(params, "body_html", Markdown.to_html!(body))
    end
  end
end
