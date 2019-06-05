defmodule Artemis.StandupTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Repo
  alias Artemis.Standup
  alias Artemis.Team
  alias Artemis.User

  @preload [:team, :user]

  describe "attributes - constraints" do
    test "date must be unique for a given user and team" do
      team = insert(:team)
      user = insert(:user)
      existing = insert(:standup, team: team, user: user)

      duplicate_params = %{
        date: existing.date,
        team_id: existing.team.id,
        user_id: existing.user.id
      }

      assert_raise Ecto.ConstraintError, fn ->
        %Standup{}
        |> Standup.changeset(duplicate_params)
        |> Repo.insert()

        insert(:standup, date: existing.date, team: team, user: user)
      end

      valid_params = %{
        date: existing.date,
        team_id: existing.team.id,
        user_id: insert(:user).id
      }

      {:ok, _} =
        %Standup{}
        |> Standup.changeset(valid_params)
        |> Repo.insert()
    end
  end

  describe "associations - team" do
    setup do
      standup = insert(:standup)

      {:ok, standup: Repo.preload(standup, @preload)}
    end

    test "deleting association removes record", %{standup: standup} do
      assert Repo.get(Team, standup.team.id) != nil

      Repo.delete!(standup.team)

      assert Repo.get(Team, standup.team.id) == nil
      assert Repo.get(Standup, standup.id) == nil
    end

    test "deleting record does not remove association", %{standup: standup} do
      assert Repo.get(Team, standup.team.id) != nil

      Repo.delete!(standup)

      assert Repo.get(Team, standup.team.id) != nil
      assert Repo.get(Standup, standup.id) == nil
    end
  end

  describe "associations - user" do
    setup do
      standup = insert(:standup)

      {:ok, standup: Repo.preload(standup, @preload)}
    end

    test "deleting association removes record", %{standup: standup} do
      assert Repo.get(User, standup.user.id) != nil

      Repo.delete!(standup.user)

      assert Repo.get(User, standup.user.id) == nil
      assert Repo.get(Standup, standup.id) == nil
    end

    test "deleting record does not remove association", %{standup: standup} do
      assert Repo.get(User, standup.user.id) != nil

      Repo.delete!(standup)

      assert Repo.get(User, standup.user.id) != nil
      assert Repo.get(Standup, standup.id) == nil
    end
  end
end
