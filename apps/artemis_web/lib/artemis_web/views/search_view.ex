defmodule ArtemisWeb.SearchView do
  use ArtemisWeb, :view

  alias ArtemisWeb.Router.Helpers, as: Routes

  @search_links %{
    "teams" => [
      label: "Teams",
      path: &Routes.team_path/3
    ],
    "wiki_pages" => [
      label: "Documentation",
      path: &Routes.wiki_page_path/3
    ],
    "event_templates" => [
      label: "Events",
      path: &Routes.event_path/3
    ],
    "event_questions" => [
      label: "Event Questions"
    ],
    "event_answers" => [
      label: "Event Answers"
    ],
    "event_integrations" => [
      label: "Event Integrations"
    ],
    "features" => [
      label: "Features",
      path: &Routes.feature_path/3
    ],
    "permissions" => [
      label: "Permissions",
      path: &Routes.permission_path/3
    ],
    "projects" => [
      label: "Projects"
    ],
    "recognitions" => [
      label: "Recognitions",
      path: &Routes.recognition_path/3
    ],
    "roles" => [
      label: "Roles",
      path: &Routes.role_path/3
    ],
    "users" => [
      label: "Users",
      path: &Routes.user_path/3
    ]
  }

  def search_results?(%{total_entries: total_entries}), do: total_entries > 0

  def search_results?(data) do
    Enum.any?(data, fn {_, resource} ->
      Map.get(resource, :total_entries) > 0
    end)
  end

  def search_anchor(key), do: "anchor-#{key}"

  def search_label(key) do
    @search_links
    |> Map.get(key, [])
    |> Keyword.get(:label)
  end

  def search_total(data) do
    Map.get(data, :total_entries)
  end

  def search_link(conn, data, key) do
    label = "View " <> search_matches_text(data)

    path =
      @search_links
      |> Map.get(key, [])
      |> Keyword.get(:path)

    if path do
      to = path.(conn, :index, current_query_params(conn))

      action(label, to: to)
    end
  end

  def search_matches_text(data) do
    total = search_total(data)

    ngettext("%{total} Match", "%{total} Matches", total, total: total)
  end

  def search_entries(data) do
    data
    |> Map.get(:entries)
    |> Enum.map(&search_entry(&1))
  end

  defp search_entry(%Artemis.EventAnswer{} = data) do
    %{
      title: "#{data.date} - #{data.event_question.title} - #{data.user.name}",
      permission: "event-answers:show",
      link: fn conn ->
        Routes.event_instance_path(conn, :show, data.event_question.event_template_id, Date.to_iso8601(data.date))
      end
    }
  end

  defp search_entry(%Artemis.EventIntegration{} = data) do
    %{
      title: ArtemisWeb.EventIntegrationView.render_event_integration_name(data),
      permission: "event-integrations:show",
      link: fn conn -> Routes.event_integration_path(conn, :show, data.event_template_id, data) end
    }
  end

  defp search_entry(%Artemis.EventQuestion{} = data) do
    %{
      title: data.title,
      permission: "event-questions:show",
      link: fn conn -> Routes.event_question_path(conn, :show, data.event_template, data) end
    }
  end

  defp search_entry(%Artemis.EventTemplate{} = data) do
    %{
      title: data.title,
      permission: "event-templates:show",
      link: fn conn -> Routes.event_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.Feature{} = data) do
    %{
      title: data.slug,
      permission: "features:show",
      link: fn conn -> Routes.feature_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.Permission{} = data) do
    %{
      title: data.slug,
      permission: "permissions:show",
      link: fn conn -> Routes.permission_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.Project{} = data) do
    %{
      title: data.title,
      permission: "projects:show",
      link: fn conn -> Routes.project_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.Recognition{} = data) do
    %{
      title: raw(data.description_html),
      permission: "recognitions:show",
      link: fn conn -> Routes.recognition_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.Role{} = data) do
    %{
      title: data.slug,
      permission: "roles:show",
      link: fn conn -> Routes.role_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.Team{} = data) do
    %{
      title: data.name,
      permission: "teams:show",
      link: fn conn -> Routes.team_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.User{} = data) do
    %{
      title: data.name,
      permission: "users:show",
      link: fn conn -> Routes.user_path(conn, :show, data) end
    }
  end

  defp search_entry(%Artemis.WikiPage{} = data) do
    %{
      title: data.title,
      permission: "wiki-pages:show",
      link: fn conn -> Routes.wiki_page_path(conn, :show, data) end
    }
  end

  def search_entries_total(data) do
    data
    |> search_entries()
    |> length()
  end

  # Helpers

  defp current_query_params(conn) do
    Enum.into(conn.query_params, [])
  end
end
