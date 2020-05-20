defmodule Artemis.CreateUserRecognition do
  use Artemis.Context

  alias Artemis.Repo
  alias Artemis.UserRecognition

  def call!(params, user) do
    case call(params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error creating user recognition")
      {:ok, result} -> result
    end
  end

  def call(params, user) do
    with_transaction(fn ->
      params
      |> insert_record
      |> Event.broadcast("user-recognition:created", params, user)
    end)
  end

  defp insert_record(params) do
    %UserRecognition{}
    |> UserRecognition.changeset(params)
    |> Repo.insert()
  end
end
