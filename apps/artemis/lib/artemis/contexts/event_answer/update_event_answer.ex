defmodule Artemis.UpdateEventAnswer do
  use Artemis.Context

  alias Artemis.EventAnswer
  alias Artemis.GetEventAnswer
  alias Artemis.Repo

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating event answer")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      id
      |> get_record(user)
      |> update_record(params)
      |> Event.broadcast("event-answer:updated", params, user)
    end)
  end

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetEventAnswer.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    record
    |> EventAnswer.changeset(params)
    |> Repo.update()
  end
end
