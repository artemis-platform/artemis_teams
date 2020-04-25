defmodule Artemis.Repo.GenerateFillerData do
  import Artemis.Factories

  alias Artemis.GetSystemUser
  alias Artemis.Repo
  alias Artemis.Role

  @moduledoc """
  Generate consistent data for development, QA, test, and demo environments.

  Requires a verification phrase to be passed to prevent accidental execution.
  """

  @verification_phrase "confirming-generation-of-filler-data"

  def call(verification_phrase) do
    with true <- enabled?(),
         true <- verification_phrase?(verification_phrase) do
      {:ok, generate_data()}
    else
      error -> error
    end
  end

  def verification_phrase, do: @verification_phrase

  defp enabled? do
    config =
      :artemis
      |> Application.fetch_env!(:actions)
      |> Keyword.fetch!(:repo_generate_filler_data)
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

  defp generate_data do
    system_user = GetSystemUser.call!()

    generate_roles(system_user)
    generate_users(system_user)

    :ok
  end

  defp generate_roles(system_user) do
    roles = [
      %{name: "Organization Admin", slug: "organization-admin"}
    ]

    Enum.map(roles, fn params ->
      case Artemis.GetRole.call([slug: params.slug], system_user) do
        nil -> Artemis.CreateRole.call!(params, system_user)
        record -> record
      end
    end)
  end

  defp generate_users(system_user) do
    users = insert_list(30, :user)
    default_role = Repo.get_by(Role, slug: "default")

    Enum.map(users, fn user ->
      insert(:user_role, created_by: system_user, role: default_role, user: user)
    end)

    users
  end
end
