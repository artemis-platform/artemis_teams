defmodule Artemis.CreateReaction do
  use Artemis.Context

  alias Artemis.Reaction
  alias Artemis.Repo

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating reaction")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("reaction:created", user)
    end)
  end

  defp insert_record(params) do
    params = create_params(params)

    %Reaction{}
    |> Reaction.changeset(params)
    |> Repo.insert()
  end

  defp create_params(params) do
    Artemis.Helpers.keys_to_strings(params)
  end
end
