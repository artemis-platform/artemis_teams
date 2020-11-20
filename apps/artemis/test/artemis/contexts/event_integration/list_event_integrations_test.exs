defmodule Artemis.ListEventIntegrationsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.EventIntegration
  alias Artemis.ListEventIntegrations
  alias Artemis.Repo

  setup do
    Repo.delete_all(EventIntegration)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no event_integrations exist" do
      assert ListEventIntegrations.call(Mock.system_user()) == []
    end

    test "returns existing event_integration" do
      event_integration = insert(:event_integration)

      event_integrations = ListEventIntegrations.call(Mock.system_user())

      assert length(event_integrations) == 1
      assert hd(event_integrations).id == event_integration.id
    end

    test "returns a list of event_integrations" do
      count = 3
      insert_list(count, :event_integration)

      event_integrations = ListEventIntegrations.call(Mock.system_user())

      assert length(event_integrations) == count
    end
  end

  describe "call - params" do
    setup do
      event_integration = insert(:event_integration)

      {:ok, event_integration: event_integration}
    end

    test "filters - schedule_not" do
      Repo.delete_all(EventIntegration)

      with_schedule = insert_list(3, :event_integration)
      without_schedule = insert_list(2, :event_integration, schedule: nil)

      result = ListEventIntegrations.call(Mock.system_user())

      assert length(result) == length(with_schedule) + length(without_schedule)

      # With filter

      params = %{
        filters: %{
          schedule_not: nil
        }
      }

      result = ListEventIntegrations.call(params, Mock.system_user())

      assert length(result) == length(with_schedule)
    end

    test "order" do
      insert_list(3, :event_integration)

      params = %{order: "name"}
      ascending = ListEventIntegrations.call(params, Mock.system_user())

      params = %{order: "-name"}
      descending = ListEventIntegrations.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListEventIntegrations.call(params, Mock.system_user())
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
  end

  describe "cache" do
    setup do
      ListEventIntegrations.reset_cache()
      ListEventIntegrations.call_with_cache(Mock.system_user())

      {:ok, []}
    end

    test "uses default simple cache key callback" do
      user = Mock.system_user()
      key = ListEventIntegrations.call_with_cache(user).key

      assert key == []
      assert length(key) == 0

      params = %{
        paginate: true
      }

      key = ListEventIntegrations.call_with_cache(params, user).key

      assert is_list(key)
      assert key == [params]
    end

    test "uses default context cache options" do
      defaults = Artemis.CacheInstance.default_cachex_options()
      cachex_options = Artemis.CacheInstance.get_cachex_options(ListEventIntegrations)

      assert cachex_options[:expiration] == Keyword.fetch!(defaults, :expiration)
      assert cachex_options[:limit] == Keyword.fetch!(defaults, :limit)
    end

    test "returns a cached result" do
      initial_call = ListEventIntegrations.call_with_cache(Mock.system_user())

      assert initial_call.__struct__ == Artemis.CacheInstance.CacheEntry
      assert is_list(initial_call.data)
      assert initial_call.inserted_at != nil
      assert initial_call.key != nil

      cache_hit = ListEventIntegrations.call_with_cache(Mock.system_user())

      assert is_list(cache_hit.data)
      assert cache_hit.inserted_at != nil
      assert cache_hit.inserted_at == initial_call.inserted_at
      assert cache_hit.key != nil

      params = %{
        paginate: true
      }

      different_key = ListEventIntegrations.call_with_cache(params, Mock.system_user())

      assert different_key.data.__struct__ == Scrivener.Page
      assert is_list(different_key.data.entries)
      assert different_key.inserted_at != nil
      assert different_key.key != nil
    end
  end
end
