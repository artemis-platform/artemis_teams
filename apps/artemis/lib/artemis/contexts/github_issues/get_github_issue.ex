defmodule Artemis.GetGithubIssue do
  def call!(organization, repository, id, user, options \\ []) do
    case call(organization, repository, id, user, options) do
      {:error, _} -> raise(Artemis.Context.Error, "Error getting github issue")
      {:ok, result} -> result
    end
  end

  def call(organization, repository, id, _user, _options \\ []) do
    organization
    |> get_record(repository, id)
  end

  defp get_record(organization, repository, id) do
    Artemis.Drivers.Github.GetRepoIssue.call(organization, repository, id)
  end
end
