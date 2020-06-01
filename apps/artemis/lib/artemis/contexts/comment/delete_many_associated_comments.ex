defmodule Artemis.DeleteManyAssociatedComments do
  use Artemis.Context

  import Ecto.Query

  alias Artemis.Comment
  alias Artemis.DeleteManyAssociatedReactions
  alias Artemis.Repo

  def call!(resource_type, resource_id \\ nil, user) do
    case call(resource_type, resource_id, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting many associated comments")
      {:ok, result} -> result
      result -> result
    end
  end

  def call(resource_type, resource_id \\ nil, user) do
    case delete(resource_type, resource_id, user) do
      {:error, message} -> {:error, message}
      {:ok, {total, _}} -> {:ok, %{total: total}}
    end
  end

  defp delete(resource_type, resource_id, user) do
    with_transaction(fn ->
      associated_records = list_records(resource_type, resource_id)
      associated_ids = Enum.map(associated_records, & &1.id)

      Enum.map(associated_ids, fn associated_id ->
        {:ok, _} = DeleteManyAssociatedReactions.call("Comment", associated_id, user)
      end)

      delete_records(associated_ids)
    end)
  end

  defp list_records(resource_type, resource_id) do
    Comment
    |> where([c], c.resource_type == ^resource_type)
    |> maybe_where_resource_id(resource_id)
    |> Repo.all()
  end

  defp delete_records(comment_ids) do
    Comment
    |> where([c], c.id in ^comment_ids)
    |> Repo.delete_all()
  end

  defp maybe_where_resource_id(query, nil), do: query

  defp maybe_where_resource_id(query, resource_id) when is_integer(resource_id) do
    maybe_where_resource_id(query, Integer.to_string(resource_id))
  end

  defp maybe_where_resource_id(query, resource_id) do
    where(query, [c], c.resource_id == ^resource_id)
  end
end
