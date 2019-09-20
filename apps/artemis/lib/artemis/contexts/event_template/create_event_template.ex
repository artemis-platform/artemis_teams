defmodule Artemis.CreateEventTemplate do
  use Artemis.Context

  alias Artemis.Repo
  alias Artemis.EventTemplate

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating event template")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("event-template:created", user)
    end)
  end

  defp insert_record(params) do
    %EventTemplate{}
    |> EventTemplate.changeset(params)
    |> Repo.insert()
  end
end
