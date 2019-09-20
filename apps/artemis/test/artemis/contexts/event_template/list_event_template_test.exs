defmodule Artemis.ListEventTemplatesTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListEventTemplates
  alias Artemis.Repo
  alias Artemis.EventTemplate

  setup do
    Repo.delete_all(EventTemplate)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no event templates exist" do
      assert ListEventTemplates.call(Mock.system_user()) == []
    end

    test "returns existing event templates" do
      event_template = insert(:event_template)

      assert ListEventTemplates.call(Mock.system_user()) == [event_template]
    end

    test "returns a list of event templates" do
      count = 3
      insert_list(count, :event_template)

      event_templates = ListEventTemplates.call(Mock.system_user())

      assert length(event_templates) == count
    end
  end

  describe "call - params" do
    setup do
      event_template = insert(:event_template)

      {:ok, event_template: event_template}
    end

    test "order" do
      insert_list(3, :event_template)

      params = %{order: "team_id"}
      ascending = ListEventTemplates.call(params, Mock.system_user())

      params = %{order: "-team_id"}
      descending = ListEventTemplates.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListEventTemplates.call(params, Mock.system_user())
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
end
