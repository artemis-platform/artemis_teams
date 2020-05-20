defmodule Artemis.DeleteRecognition do
  use Artemis.Context

  alias Artemis.GetRecognition
  alias Artemis.Repo

  def call!(id, params \\ %{}, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting recognition")
      {:ok, result} -> result
    end
  end

  def call(id, params \\ %{}, user) do
    id
    |> get_record(user)
    |> delete_record
    |> Event.broadcast("recognition:deleted", params, user)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetRecognition.call(id, user)

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
