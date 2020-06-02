defmodule Artemis.ReactionTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Reaction
  alias Artemis.User

  @preload [:user]

  describe "associations - user" do
    setup do
      reaction = insert(:reaction)

      {:ok, reaction: Repo.preload(reaction, @preload)}
    end

    test "updating association does not change record", %{reaction: reaction} do
      user = Repo.get(User, reaction.user.id)

      assert user != nil
      assert user.name != "Updated Name"

      params = %{name: "Updated Name"}

      {:ok, user} =
        user
        |> User.changeset(params)
        |> Repo.update()

      assert user != nil
      assert user.name == "Updated Name"

      assert Repo.get(Reaction, reaction.id).user_id == user.id
    end

    test "deleting association nilifies record", %{reaction: reaction} do
      assert Repo.get(User, reaction.user.id) != nil

      Repo.delete!(reaction.user)

      assert Repo.get(User, reaction.user.id) == nil
      assert Repo.get(Reaction, reaction.id).user_id == nil
    end

    test "deleting record does not remove association", %{reaction: reaction} do
      assert Repo.get(User, reaction.user.id) != nil

      Repo.delete!(reaction)

      assert Repo.get(User, reaction.user.id) != nil
      assert Repo.get(Reaction, reaction.id) == nil
    end
  end
end
