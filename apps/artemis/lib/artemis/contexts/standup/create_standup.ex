defmodule Artemis.CreateStandup do
  use Artemis.Context

  alias Artemis.Standup
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating standup")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("standup:created", user)
    end)
  end

  defp insert_record(params) do
    %Standup{}
    |> Standup.changeset(params)
    |> Repo.insert()
  end
end
