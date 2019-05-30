defmodule Artemis.DeleteStandup do
  use Artemis.Context

  alias Artemis.Standup
  alias Artemis.Repo

  def call!(id, user) do
    case call(id, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error deleting standup")
      {:ok, result} -> result
    end
  end

  def call(id, user) do
    id
    |> get_record
    |> delete_record
    |> Event.broadcast("standup:deleted", user)
  end

  def get_record(record) when is_map(record), do: record
  def get_record(id), do: Repo.get(Standup, id)

  defp delete_record(nil), do: {:error, "Record not found"}
  defp delete_record(record), do: Repo.delete(record)
end
