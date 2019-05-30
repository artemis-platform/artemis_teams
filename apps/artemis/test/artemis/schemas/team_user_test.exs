defmodule Artemis.TeamUserTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Repo
  alias Artemis.Team
  alias Artemis.TeamUser
  alias Artemis.User

  @preload [:team, :user]

  describe "attributes - constraints" do
    test "entry must be unique for a given user and team" do
      team = insert(:team)
      user = insert(:user)
      existing = insert(:team_user, team: team, user: user)

      duplicate_params = %{
        type: existing.type,
        team_id: existing.team.id,
        user_id: existing.user.id
      }

      assert_raise Ecto.ConstraintError, fn ->
        %TeamUser{}
        |> TeamUser.changeset(duplicate_params)
        |> Repo.insert()
        insert(:team_user, type: existing.type, team: team, user: user)
      end

      valid_params = %{
        type: existing.type,
        team_id: existing.team.id,
        user_id: insert(:user).id
      }

      {:ok, _} =
        %TeamUser{}
        |> TeamUser.changeset(valid_params)
        |> Repo.insert()
    end
  end

  describe "associations - team" do
    setup do
      team_user = insert(:team_user)

      {:ok, team_user: Repo.preload(team_user, @preload)}
    end

    test "deleting association removes record", %{team_user: team_user} do
      assert Repo.get(Team, team_user.team.id) != nil

      Repo.delete!(team_user.team)

      assert Repo.get(Team, team_user.team.id) == nil
      assert Repo.get(TeamUser, team_user.id) == nil
    end

    test "deleting record does not remove association", %{team_user: team_user} do
      assert Repo.get(Team, team_user.team.id) != nil

      Repo.delete!(team_user)

      assert Repo.get(Team, team_user.team.id) != nil
      assert Repo.get(TeamUser, team_user.id) == nil
    end
  end

  describe "associations - user" do
    setup do
      team_user = insert(:team_user)

      {:ok, team_user: Repo.preload(team_user, @preload)}
    end

    test "deleting association removes record", %{team_user: team_user} do
      assert Repo.get(User, team_user.user.id) != nil

      Repo.delete!(team_user.user)

      assert Repo.get(User, team_user.user.id) == nil
      assert Repo.get(TeamUser, team_user.id) == nil
    end

    test "deleting record does not remove association", %{team_user: team_user} do
      assert Repo.get(User, team_user.user.id) != nil

      Repo.delete!(team_user)

      assert Repo.get(User, team_user.user.id) != nil
      assert Repo.get(TeamUser, team_user.id) == nil
    end
  end
end
