defmodule Artemis.CreateEventAnswer do
  use Artemis.Context

  alias Artemis.EventAnswer
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating event answer")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("event-answer:created", params, user)
    end)
  end

  defp insert_record(params) do
    %EventAnswer{}
    |> EventAnswer.changeset(params)
    |> Repo.insert()
  end
end
