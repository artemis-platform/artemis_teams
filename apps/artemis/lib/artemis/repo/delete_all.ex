defmodule Artemis.Repo.DeleteAll do
  @moduledoc """
  Delete all application data from the database.

  Requires a verification phrase to be passed to prevent accidental execution.
  """

  @schemas [
    Artemis.AuthProvider,
    Artemis.Cloud,
    Artemis.Customer,
    Artemis.DataCenter,
    Artemis.Feature,
    Artemis.Incident,
    Artemis.Machine,
    Artemis.Permission,
    Artemis.Role,
    Artemis.User,
    Artemis.UserRole
  ]
  @verification_phrase "confirming-deletion-of-all-database-data"

  def call(verification_phrase) do
    with true <- enabled?(),
         true <- verification_phrase?(verification_phrase) do
      {:ok, delete_all()}
    else
      error -> error
    end
  end

  def verification_phrase, do: @verification_phrase

  defp enabled? do
    config =
      :artemis
      |> Application.fetch_env!(:actions)
      |> Keyword.fetch!(:repo_delete_all)
      |> Keyword.fetch!(:enabled)
      |> String.downcase()
      |> String.equivalent?("true")

    case config do
      false -> {:error, "Action not enabled in the application config"}
      true -> true
    end
  end

  defp verification_phrase?(verification_phrase) do
    case verification_phrase == @verification_phrase do
      false -> {:error, "Action requires valid verification phrase to be passed"}
      true -> true
    end
  end

  defp delete_all do
    Enum.map(@schemas, &Artemis.Repo.delete_all(&1))
  end
end
