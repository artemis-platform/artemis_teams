defmodule Artemis.Search do
  use Artemis.Context

  import Artemis.UserAccess

  @moduledoc """
  Search multiple resources for matching results

  ## New Resources

  To add a new resource, add an entry to the `get_searchable_resources/0`
  function below. This ensures the data will be queried and included in the
  results.

  To display the results, update any related display code,
  e.g.`ArtemisWeb.SearchView`.
  """

  @default_page_size 5

  def call(params, user) do
    params =
      params
      |> Artemis.Helpers.keys_to_strings()
      |> Map.put("paginate", true)
      |> Map.put_new("page_size", @default_page_size)

    case Map.get(params, "query") do
      nil -> %{}
      "" -> %{}
      _ -> search(params, user)
    end
  end

  # Config

  def get_searchable_resources do
    searchable_resources = %{
      "teams" => [
        enabled: true,
        function: fn params, user ->
          params
          |> Artemis.Helpers.keys_to_strings()
          |> Artemis.Helpers.deep_merge(%{"filters" => %{"user_id" => user.id}})
          |> Artemis.ListTeams.call(user)
        end,
        permissions: "teams:list"
      ],
      "event_answers" => [
        enabled: true,
        function: fn params, user ->
          params
          |> Artemis.Helpers.keys_to_strings()
          |> Artemis.Helpers.deep_merge(%{"filters" => %{"team_member_id" => user.id}})
          |> Artemis.ListEventAnswers.call(user)
        end,
        permissions: "event-answers:list"
      ],
      "event_questions" => [
        enabled: true,
        function: fn params, user ->
          params
          |> Artemis.Helpers.keys_to_strings()
          |> Artemis.Helpers.deep_merge(%{"filters" => %{"user_id" => user.id}})
          |> Artemis.ListEventQuestions.call(user)
        end,
        permissions: "event-questions:list"
      ],
      "event_templates" => [
        enabled: true,
        function: fn params, user ->
          params
          |> Artemis.Helpers.keys_to_strings()
          |> Artemis.Helpers.deep_merge(%{"filters" => %{"user_id" => user.id}})
          |> Artemis.ListEventTemplates.call(user)
        end,
        permissions: "event-templates:list"
      ],
      "event_integrations" => [
        enabled: false,
        function: &Artemis.ListEventIntegrations.call/2,
        permissions: "event-integrations:list"
      ],
      "projects" => [
        enabled: true,
        function: fn params, user ->
          params
          |> Artemis.Helpers.keys_to_strings()
          |> Artemis.Helpers.deep_merge(%{"filters" => %{"user_id" => user.id}})
          |> Artemis.ListProjects.call(user)
        end,
        permissions: "projects:list"
      ],
      "recognitions" => [
        enabled: true,
        function: &Artemis.ListRecognitions.call/2,
        permissions: "recognitions:list"
      ],
      "features" => [
        enabled: true,
        function: &Artemis.ListFeatures.call/2,
        permissions: "features:list"
      ],
      "permissions" => [
        enabled: true,
        function: &Artemis.ListPermissions.call/2,
        permissions: "permissions:list"
      ],
      "roles" => [
        enabled: true,
        function: &Artemis.ListRoles.call/2,
        permissions: "roles:list"
      ],
      "users" => [
        enabled: true,
        function: &Artemis.ListUsers.call/2,
        permissions: "users:list"
      ],
      "wiki_pages" => [
        enabled: true,
        function: &Artemis.ListWikiPages.call/2,
        permissions: "wiki-pages:list"
      ]
    }

    Enum.reduce(searchable_resources, %{}, fn {key, value}, acc ->
      case Keyword.get(value, :enabled, false) do
        true -> Map.put(acc, key, value)
        false -> acc
      end
    end)
  end

  # Helpers

  defp search(params, user) do
    resources = filter_resources_by_user_permissions(params, user)

    Enum.reduce(resources, %{}, fn {key, options}, acc ->
      function = Keyword.get(options, :function)
      value = function.(params, user)

      Map.put(acc, key, value)
    end)
  end

  defp filter_resources_by_user_permissions(params, user) do
    searchable_resources = get_searchable_resources()
    requested_keys = Map.get(params, "resources", Map.keys(searchable_resources))
    requested_resources = Map.take(searchable_resources, requested_keys)

    Enum.filter(requested_resources, fn {_key, options} ->
      permissions = Keyword.get(options, :permissions)

      has_all?(user, permissions)
    end)
  end
end
