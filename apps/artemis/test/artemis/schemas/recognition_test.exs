defmodule Artemis.RecognitionTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Recognition
  alias Artemis.Repo
  alias Artemis.UserRecognition

  @preload [:user_recognitions, :users]

  describe "associations - user recognitions" do
    setup do
      recognition =
        :recognition
        |> insert
        |> with_user_recognitions

      {:ok, recognition: Repo.preload(recognition, @preload)}
    end

    test "update associations", %{recognition: recognition} do
      new_user = insert(:user)
      new_user_recognition = insert(:user_recognition, recognition: recognition, user: new_user)

      assert length(recognition.users) == 3

      {:ok, updated} =
        recognition
        |> Recognition.associations_changeset(%{user_recognitions: [new_user_recognition]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.users) == 1
      assert updated.users == [new_user]
    end

    test "deleting association does not remove record", %{recognition: recognition} do
      assert Repo.get(Recognition, recognition.id) != nil
      assert length(recognition.user_recognitions) == 3

      Enum.map(recognition.user_recognitions, &Repo.delete(&1))

      recognition =
        Recognition
        |> preload(^@preload)
        |> Repo.get(recognition.id)

      assert Repo.get(Recognition, recognition.id) != nil
      assert length(recognition.user_recognitions) == 0
    end

    test "deleting record removes associations", %{recognition: recognition} do
      assert Repo.get(Recognition, recognition.id) != nil
      assert length(recognition.user_recognitions) == 3

      Repo.delete(recognition)

      assert Repo.get(Recognition, recognition.id) == nil

      Enum.map(recognition.user_recognitions, fn user_recognition ->
        assert Repo.get(UserRecognition, user_recognition.id) == nil
      end)
    end
  end
end