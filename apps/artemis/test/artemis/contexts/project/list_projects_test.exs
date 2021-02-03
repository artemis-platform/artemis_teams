defmodule Artemis.ListProjectsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListProjects
  alias Artemis.Repo
  alias Artemis.Project

  setup do
    Repo.delete_all(Project)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no projects exist" do
      assert ListProjects.call(Mock.system_user()) == []
    end

    test "returns existing project" do
      project = insert(:project)

      projects = ListProjects.call(Mock.system_user())

      assert length(projects) == 1
      assert hd(projects).id == project.id
    end

    test "returns a list of projects" do
      count = 3
      insert_list(count, :project)

      projects = ListProjects.call(Mock.system_user())

      assert length(projects) == count
    end
  end

  describe "call - params" do
    setup do
      project = insert(:project)

      {:ok, project: project}
    end

    test "order" do
      insert_list(3, :project)

      params = %{order: "title"}
      ascending = ListProjects.call(params, Mock.system_user())

      params = %{order: "-title"}
      descending = ListProjects.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListProjects.call(params, Mock.system_user())
        |> Map.from_struct()
        |> Map.keys()

      pagination_keys = [
        :entries,
        :page_number,
        :page_size,
        :total_entries,
        :total_pages
      ]

      assert response_keys == pagination_keys
    end

    test "query - search" do
      insert(:project, title: "Four Six")
      insert(:project, title: "Four Two")
      insert(:project, title: "Five Six")

      user = Mock.system_user()
      projects = ListProjects.call(user)

      assert length(projects) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "Six"
      }

      projects = ListProjects.call(params, user)

      assert length(projects) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "four-"
      }

      projects = ListProjects.call(params, user)

      assert length(projects) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "our"
      }

      projects = ListProjects.call(params, user)

      assert length(projects) == 0
    end
  end

  describe "cache" do
    setup do
      ListProjects.reset_cache()
      ListProjects.call_with_cache(Mock.system_user())

      {:ok, []}
    end

    test "uses default simple cache key callback" do
      user = Mock.system_user()
      key = ListProjects.call_with_cache(user).key

      assert key == []
      assert length(key) == 0

      params = %{
        paginate: true
      }

      key = ListProjects.call_with_cache(params, user).key

      assert is_list(key)
      assert key == [params]
    end

    test "uses default context cache options" do
      defaults = Artemis.CacheInstance.default_cache_options()
      cache_options = Artemis.CacheInstance.get_cache_options(ListProjects)

      assert cache_options[:expiration] == Keyword.fetch!(defaults, :expiration)
      assert cache_options[:limit] == Keyword.fetch!(defaults, :limit)
    end

    test "returns a cached result" do
      initial_call = ListProjects.call_with_cache(Mock.system_user())

      assert initial_call.__struct__ == Artemis.CacheInstance.CacheEntry
      assert is_list(initial_call.data)
      assert initial_call.inserted_at != nil
      assert initial_call.key != nil

      cache_hit = ListProjects.call_with_cache(Mock.system_user())

      assert is_list(cache_hit.data)
      assert cache_hit.inserted_at != nil
      assert cache_hit.inserted_at == initial_call.inserted_at
      assert cache_hit.key != nil

      params = %{
        paginate: true
      }

      different_key = ListProjects.call_with_cache(params, Mock.system_user())

      assert different_key.data.__struct__ == Scrivener.Page
      assert is_list(different_key.data.entries)
      assert different_key.inserted_at != nil
      assert different_key.key != nil
    end
  end
end
