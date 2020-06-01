defmodule Artemis.DeleteComment do
  use Artemis.Context

  alias Artemis.DeleteManyAssociatedReactions
  alias Artemis.GetComment
  alias Artemis.Repo

  def call!(id, params \\ %{}, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting comment")
      {:ok, result} -> result
    end
  end

  def call(id, params \\ %{}, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> delete_associated_reactions(user)
      |> delete_record
      |> Event.broadcast("comment:deleted", params, user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetComment.call(id, user)

  def delete_associated_reactions(record, user) do
    resource_type = "Comment"
    resource_id = record.id

    {:ok, _} = DeleteManyAssociatedReactions.call(resource_type, resource_id, user)

    record
  rescue
    _ -> record
  end

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
