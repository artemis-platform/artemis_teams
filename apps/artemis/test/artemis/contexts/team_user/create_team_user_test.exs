defmodule Artemis.CreateTeamUserTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateTeamUser

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateTeamUser.call!(%{}, Mock.system_user())
      end
    end

    test "creates a team user when passed valid params" do
      params = params_for(:team_user)

      team_user = CreateTeamUser.call!(params, Mock.system_user())

      assert team_user.type == params.type
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateTeamUser.call(%{}, Mock.system_user())

      assert errors_on(changeset).type == ["can't be blank"]
    end

    test "creates a team user when passed valid params" do
      params = params_for(:team_user)

      {:ok, team_user} = CreateTeamUser.call(params, Mock.system_user())

      assert team_user.type == params.type
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      {:ok, team_user} = CreateTeamUser.call(params_for(:team_user), Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "team-user:created",
        payload: %{
          data: ^team_user
        }
      }
    end
  end
end
