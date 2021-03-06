defmodule ArtemisLog.ListSessionsTest do
  use ArtemisLog.DataCase

  import ArtemisLog.Factories

  alias ArtemisLog.EventLog
  alias ArtemisLog.ListSessions
  alias ArtemisLog.Repo

  setup do
    Repo.delete_all(EventLog)

    {:ok, []}
  end

  describe "access permissions" do
    setup do
      insert_list(3, :event_log)

      {:ok, []}
    end

    test "returns empty list with no permissions" do
      user = Mock.user_without_permissions()
      insert(:event_log, user_id: user.id)

      params = %{"paginate" => false}
      result = ListSessions.call(params, user)

      assert length(result) == 0
    end

    test "requires access:self permission to return own record" do
      user = Mock.user_with_permission("sessions:access:self")
      insert(:event_log, user_id: user.id)

      params = %{"paginate" => false}
      result = ListSessions.call(params, user)

      assert length(result) == 1
    end

    test "requires access:all permission to return other records" do
      user = Mock.user_with_permission("sessions:access:all")

      params = %{"paginate" => false}
      result = ListSessions.call(params, user)
      total = Repo.all(EventLog)

      assert length(result) == length(total)
    end
  end

  describe "call" do
    test "always returns paginated results" do
      response_keys =
        ListSessions.call(Mock.system_user())
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

    test "returns empty list when no event logs exist" do
      assert ListSessions.call(Mock.system_user()).entries == []
    end

    test "returns existing event logs" do
      event_log = insert(:event_log)

      sessions = ListSessions.call(Mock.system_user())

      assert hd(sessions.entries).session_id == event_log.session_id
    end

    test "returns a list of event logs" do
      count = 3
      insert_list(count, :event_log)

      sessions = ListSessions.call(Mock.system_user())

      assert length(sessions.entries) == count
    end
  end

  describe "call - params" do
    setup do
      event_log = insert(:event_log)

      {:ok, event_log: event_log}
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListSessions.call(params, Mock.system_user())
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
      insert(:event_log, user_name: "John Smith", action: "create-user")
      insert(:event_log, user_name: "Jill Smith", action: "create-role")
      insert(:event_log, user_name: "John Doe", action: "update-user")

      user = Mock.system_user()
      %{entries: event_logs} = ListSessions.call(user)

      assert length(event_logs) == 4

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "smit"
      }

      %{entries: event_logs} = ListSessions.call(params, user)

      assert length(event_logs) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "create-"
      }

      %{entries: event_logs} = ListSessions.call(params, user)

      assert length(event_logs) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "mith"
      }

      %{entries: event_logs} = ListSessions.call(params, user)

      assert length(event_logs) == 0
    end
  end
end
