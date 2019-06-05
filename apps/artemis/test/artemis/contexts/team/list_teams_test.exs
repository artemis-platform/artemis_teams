defmodule Artemis.ListTeamsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListTeams
  alias Artemis.Repo
  alias Artemis.Team

  setup do
    Repo.delete_all(Team)

    {:ok, []}
  end

  describe "access permissions" do
    setup do
      insert_list(3, :team)

      {:ok, []}
    end

    test "returns empty list with no permissions" do
      user = Mock.user_without_permissions()
      insert(:team_user, user: user)

      result = ListTeams.call(user)

      assert length(result) == 0
    end

    test "requires access:self permission to return own record" do
      user = Mock.user_with_permission("teams:access:associated")
      insert(:team_user, user: user)

      result = ListTeams.call(user)

      assert length(result) == 1
    end

    test "requires access:all permission to return other records" do
      user = Mock.user_with_permission("teams:access:all")

      result = ListTeams.call(user)
      total = Repo.all(Team)

      assert length(result) == length(total)
    end
  end

  describe "call" do
    test "returns empty list when no teams exist" do
      assert ListTeams.call(Mock.system_user()) == []
    end

    test "returns existing team" do
      team = insert(:team)

      result = ListTeams.call(Mock.system_user())

      assert hd(result).id == team.id
    end

    test "returns a list of teams" do
      count = 3
      insert_list(count, :team)

      teams = ListTeams.call(Mock.system_user())

      assert length(teams) == count
    end

    test "returns virtual fields" do
      insert(:team_user)

      result = ListTeams.call(Mock.system_user())

      assert hd(result).team_user_count == 1
    end
  end

  describe "call - params" do
    setup do
      team = insert(:team)

      {:ok, team: team}
    end

    test "filters - user_id" do
      _other_teams = insert_list(3, :team)

      user = insert(:user)
      team = insert(:team)

      insert(:team_user, team: team, user: user)

      params = %{filters: %{user_id: user.id}}
      result = ListTeams.call(params, Mock.system_user())

      assert length(result) == 1
    end

    test "order" do
      insert_list(3, :team)

      params = %{order: "name"}
      ascending = ListTeams.call(params, Mock.system_user())

      params = %{order: "-name"}
      descending = ListTeams.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end

    test "paginate" do
      params = %{
        paginate: true
      }

      response_keys =
        ListTeams.call(params, Mock.system_user())
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
      insert(:team, name: "Four Six", slug: "four-six")
      insert(:team, name: "Four Two", slug: "four-two")
      insert(:team, name: "Five Six", slug: "five-six")

      user = Mock.system_user()
      teams = ListTeams.call(user)

      assert length(teams) > 2

      # Succeeds when given a word part of a larger phrase

      params = %{
        query: "Six"
      }

      teams = ListTeams.call(params, user)

      assert length(teams) == 2

      # Succeeds with partial value when it is start of a word

      params = %{
        query: "four-"
      }

      teams = ListTeams.call(params, user)

      assert length(teams) == 2

      # Fails with partial value when it is not the start of a word

      params = %{
        query: "our"
      }

      teams = ListTeams.call(params, user)

      assert length(teams) == 0
    end
  end
end
