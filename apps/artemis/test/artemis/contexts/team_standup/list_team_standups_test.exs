defmodule Artemis.ListTeamsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListTeamStandups
  alias Artemis.Repo
  alias Artemis.Team

  setup do
    {:ok, []}
  end

  describe "call" do
    test "returns a summary" do
      date = "2019-01-01"
      insert(:standup, date: date)
      insert(:standup, date: date)
      insert(:standup, date: date)

      date = "2019-01-02"
      insert(:standup, date: date)
      insert(:standup, date: date)

      assert ListTeamStandups.call(Mock.system_user()) == []
    end
  end

  # describe "call" do
  #   test "returns empty list when no teams exist" do
  #     assert ListTeams.call(Mock.system_user()) == []
  #   end

  #   test "returns existing team" do
  #     team = insert(:team)

  #     assert ListTeams.call(Mock.system_user()) == [team]
  #   end

  #   test "returns a list of teams" do
  #     count = 3
  #     insert_list(count, :team)

  #     teams = ListTeams.call(Mock.system_user())

  #     assert length(teams) == count
  #   end
  # end

  # describe "call - params" do
  #   setup do
  #     team = insert(:team)

  #     {:ok, team: team}
  #   end

  #   test "order" do
  #     insert_list(3, :team)

  #     params = %{order: "name"}
  #     ascending = ListTeams.call(params, Mock.system_user())

  #     params = %{order: "-name"}
  #     descending = ListTeams.call(params, Mock.system_user())

  #     assert ascending == Enum.reverse(descending)
  #   end

  #   test "paginate" do
  #     params = %{
  #       paginate: true
  #     }

  #     response_keys =
  #       ListTeams.call(params, Mock.system_user())
  #       |> Map.from_struct()
  #       |> Map.keys()

  #     pagination_keys = [
  #       :entries,
  #       :page_number,
  #       :page_size,
  #       :total_entries,
  #       :total_pages
  #     ]

  #     assert response_keys == pagination_keys
  #   end

  #   test "query - search" do
  #     insert(:team, name: "John Smith", slug: "john-smith")
  #     insert(:team, name: "Jill Smith", slug: "jill-smith")
  #     insert(:team, name: "John Doe", slug: "john-doe")

  #     user = Mock.system_user()
  #     teams = ListTeams.call(user)

  #     assert length(teams) == 4

  #     # Succeeds when given a word part of a larger phrase

  #     params = %{
  #       query: "smit"
  #     }

  #     teams = ListTeams.call(params, user)

  #     assert length(teams) == 2

  #     # Succeeds with partial value when it is start of a word

  #     params = %{
  #       query: "john-"
  #     }

  #     teams = ListTeams.call(params, user)

  #     assert length(teams) == 2

  #     # Fails with partial value when it is not the start of a word

  #     params = %{
  #       query: "mith"
  #     }

  #     teams = ListTeams.call(params, user)

  #     assert length(teams) == 0
  #   end
  # end
end
