defmodule Artemis.ListTeamUsersTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListTeamUsers
  alias Artemis.Repo
  alias Artemis.TeamUser

  setup do
    Repo.delete_all(TeamUser)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no team users exist" do
      assert ListTeamUsers.call(Mock.system_user()) == []
    end

    test "returns existing team users" do
      team_user = insert(:team_user)

      assert ListTeamUsers.call(Mock.system_user()) == [team_user]
    end

    test "returns a list of team users" do
      count = 3
      insert_list(count, :team_user)

      team_users = ListTeamUsers.call(Mock.system_user())

      assert length(team_users) == count
    end
  end

  describe "call - params" do
    setup do
      team_user = insert(:team_user)

      {:ok, team_user: team_user}
    end

    test "order" do
      insert_list(3, :team_user)

      params = %{order: "user_id"}
      ascending = ListTeamUsers.call(params, Mock.system_user())

      params = %{order: "-user_id"}
      descending = ListTeamUsers.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListTeamUsers.call(params, Mock.system_user())
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
