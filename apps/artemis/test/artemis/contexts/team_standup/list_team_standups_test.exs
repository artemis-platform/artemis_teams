defmodule Artemis.ListTeamStandupsTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.ListTeamStandups
  alias Artemis.Repo
  alias Artemis.Standup

  setup do
    Repo.delete_all(Standup)

    {:ok, []}
  end

  describe "call" do
    test "returns empty list when no teams exist" do
      assert ListTeamStandups.call(Mock.system_user()) == []
    end

    test "returns existing team standup" do
      standup = insert(:standup)

      result = ListTeamStandups.call(Mock.system_user())

      assert hd(result).date == standup.date
    end

    test "returns a list of team standups" do
      date1 = ~D[2019-01-01]
      insert(:standup, date: date1)
      insert(:standup, date: date1)
      insert(:standup, date: date1)

      date2 = ~D[2019-01-02]
      insert(:standup, date: date2)
      insert(:standup, date: date2)

      result = ListTeamStandups.call(Mock.system_user())

      assert length(result) == 2
      assert hd(result).date == date1
      assert hd(result).count == 3
    end
  end

  describe "call - params" do
    setup do
      insert(:standup, date: ~D[2019-01-01])
      insert(:standup, date: ~D[2019-01-02])

      {:ok, []}
    end

    test "filters - team_id" do
      standup = insert(:standup)

      params = %{filters: %{team_id: standup.team_id}}
      result = ListTeamStandups.call(params, Mock.system_user())

      assert length(result) == 1
    end

    test "order" do
      params = %{order: "date"}
      ascending = ListTeamStandups.call(params, Mock.system_user())

      params = %{order: "-date"}
      descending = ListTeamStandups.call(params, Mock.system_user())

      assert ascending == Enum.reverse(descending)
    end
  end
end
