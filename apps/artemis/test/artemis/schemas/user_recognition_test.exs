defmodule Artemis.UserRecognitionTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Repo
  alias Artemis.Recognition
  alias Artemis.UserRecognition
  alias Artemis.User

  @preload [:recognition, :user]

  describe "associations - recognition" do
    setup do
      user_recognition = insert(:user_recognition)

      {:ok, user_recognition: Repo.preload(user_recognition, @preload)}
    end

    test "deleting association removes record", %{user_recognition: user_recognition} do
      assert Repo.get(Recognition, user_recognition.recognition.id) != nil

      Repo.delete!(user_recognition.recognition)

      assert Repo.get(Recognition, user_recognition.recognition.id) == nil
      assert Repo.get(UserRecognition, user_recognition.id) == nil
    end

    test "deleting record does not remove association", %{user_recognition: user_recognition} do
      assert Repo.get(Recognition, user_recognition.recognition.id) != nil

      Repo.delete!(user_recognition)

      assert Repo.get(Recognition, user_recognition.recognition.id) != nil
      assert Repo.get(UserRecognition, user_recognition.id) == nil
    end
  end

  describe "associations - user" do
    setup do
      user_recognition = insert(:user_recognition)

      {:ok, user_recognition: Repo.preload(user_recognition, @preload)}
    end

    test "deleting association removes record", %{user_recognition: user_recognition} do
      assert Repo.get(User, user_recognition.user.id) != nil

      Repo.delete!(user_recognition.user)

      assert Repo.get(User, user_recognition.user.id) == nil
      assert Repo.get(UserRecognition, user_recognition.id) == nil
    end

    test "deleting record does not remove association", %{user_recognition: user_recognition} do
      assert Repo.get(User, user_recognition.user.id) != nil

      Repo.delete!(user_recognition)

      assert Repo.get(User, user_recognition.user.id) != nil
      assert Repo.get(UserRecognition, user_recognition.id) == nil
    end
  end
end
