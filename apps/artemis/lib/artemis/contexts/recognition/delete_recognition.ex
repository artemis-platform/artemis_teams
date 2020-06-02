defmodule Artemis.DeleteRecognition do
  use Artemis.Context

  import Ecto.Query

  alias Artemis.DeleteManyAssociatedComments
  alias Artemis.DeleteManyAssociatedReactions
  alias Artemis.Recognition
  alias Artemis.Repo

  def call!(id, params \\ %{}, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting recognition")
      {:ok, result} -> result
    end
  end

  def call(id, params \\ %{}, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> delete_associated_comments(user)
      |> delete_associated_reactions(user)
      |> delete_record
      |> Event.broadcast("recognition:deleted", params, user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)

  def get_record(id, user) do
    Recognition
    |> restrict_access(user)
    |> Repo.get(id)
  end

  defp restrict_access(query, user) do
    cond do
      has?(user, "recognitions:access:all") -> query
      has?(user, "recognitions:access:self") -> where(query, [r], r.created_by_id == ^user.id)
      true -> where(query, [r], is_nil(r.id))
    end
  end

  def delete_associated_comments(record, user) do
    resource_type = "Recognition"
    resource_id = record.id

    {:ok, _} = DeleteManyAssociatedComments.call(resource_type, resource_id, user)

    record
  rescue
    _ -> record
  end

  def delete_associated_reactions(record, user) do
    resource_type = "Recognition"
    resource_id = record.id

    {:ok, _} = DeleteManyAssociatedReactions.call(resource_type, resource_id, user)

    record
  rescue
    _ -> record
  end

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
