defmodule Artemis.UpdateTeamTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateTeam

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:team)

      assert_raise Artemis.Context.Error, fn ->
        UpdateTeam.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      team = insert(:team)
      params = %{}

      updated = UpdateTeam.call!(team, params, Mock.system_user())

      assert updated.name == team.name
    end

    test "updates a record when passed valid params" do
      team = insert(:team)
      params = params_for(:team)

      updated = UpdateTeam.call!(team, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      team = insert(:team)
      params = params_for(:team)

      updated = UpdateTeam.call!(team.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:team)

      {:error, _} = UpdateTeam.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      team = insert(:team)
      params = %{}

      {:ok, updated} = UpdateTeam.call(team, params, Mock.system_user())

      assert updated.name == team.name
    end

    test "updates a record when passed valid params" do
      team = insert(:team)
      params = params_for(:team)

      {:ok, updated} = UpdateTeam.call(team, params, Mock.system_user())

      assert updated.name == params.name
    end

    test "updates a record when passed an id and valid params" do
      team = insert(:team)
      params = params_for(:team)

      {:ok, updated} = UpdateTeam.call(team.id, params, Mock.system_user())

      assert updated.name == params.name
    end
  end

  describe "call - associations" do
    test "adds updatable associations and updates record values" do
      project = insert(:project)
      team = insert(:team)
      user = insert(:user)

      user_team_params = %{
        type: "admin",
        created_by_id: user.id,
        team_id: team.id,
        user_id: user.id
      }

      params = %{
        id: team.id,
        name: "Updated Name",
        projects: [
          project
        ],
        user_teams: [
          user_team_params
        ]
      }

      {:ok, updated} = UpdateTeam.call(team.id, params, Mock.system_user())

      assert updated.name == "Updated Name"
      assert updated.user_teams != []
      assert length(updated.user_teams) == 1
      assert length(updated.projects) == 1
    end

    test "removes associations when explicitly passed an empty value" do
      projects = insert_list(3, :project)

      team = insert(:team, projects: projects)

      insert_list(3, :user_team, team: team)

      team = Repo.preload(team, [:projects, :user_teams])

      assert length(team.projects) == 3
      assert length(team.user_teams) == 3

      # Keeps existing associations if the association key is not passed

      params = %{
        id: team.id,
        name: "New Name"
      }

      {:ok, updated} = UpdateTeam.call(team.id, params, Mock.system_user())

      assert length(updated.projects) == 3
      assert length(updated.user_teams) == 3

      # Only removes associations when the association key is explicitly passed

      params = %{
        id: team.id,
        projects: [],
        user_teams: []
      }

      {:ok, updated} = UpdateTeam.call(team.id, params, Mock.system_user())

      assert length(updated.projects) == 0
      assert length(updated.user_teams) == 0
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      team = insert(:team)
      params = params_for(:team)

      {:ok, updated} = UpdateTeam.call(team, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "team:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
