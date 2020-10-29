defmodule Artemis.UpdateProjectTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.UpdateProject

  describe "call!" do
    test "raises an exception when id not found" do
      invalid_id = 50_000_000
      params = params_for(:project)

      assert_raise Artemis.Context.Error, fn ->
        UpdateProject.call!(invalid_id, params, Mock.system_user())
      end
    end

    test "returns successfully when params are empty" do
      project = insert(:project)
      params = %{}

      updated = UpdateProject.call!(project, params, Mock.system_user())

      assert updated.title == project.title
    end

    test "updates a record when passed valid params" do
      project = insert(:project)
      params = params_for(:project)

      updated = UpdateProject.call!(project, params, Mock.system_user())

      assert updated.title == params.title
    end

    test "updates a record when passed an id and valid params" do
      project = insert(:project)
      params = params_for(:project)

      updated = UpdateProject.call!(project.id, params, Mock.system_user())

      assert updated.title == params.title
    end
  end

  describe "call" do
    test "returns an error when id not found" do
      invalid_id = 50_000_000
      params = params_for(:project)

      {:error, _} = UpdateProject.call(invalid_id, params, Mock.system_user())
    end

    test "returns successfully when params are empty" do
      project = insert(:project)
      params = %{}

      {:ok, updated} = UpdateProject.call(project, params, Mock.system_user())

      assert updated.title == project.title
    end

    test "updates a record when passed valid params" do
      project = insert(:project)
      params = params_for(:project)

      {:ok, updated} = UpdateProject.call(project, params, Mock.system_user())

      assert updated.title == params.title
    end

    test "updates a record when passed an id and valid params" do
      project = insert(:project)
      params = params_for(:project)

      {:ok, updated} = UpdateProject.call(project.id, params, Mock.system_user())

      assert updated.title == params.title
    end

    test "supports markdown" do
      project = insert(:project)
      params = params_for(:project, description: "# Test")

      {:ok, updated} = UpdateProject.call(project.id, params, Mock.system_user())

      assert updated.description == params.description
      assert updated.description_html == "<h1>Test</h1>\n"
    end
  end

  describe "call - associations" do
    test "adds updatable associations and updates record values" do
      team = insert(:team)
      project = insert(:project)

      params = %{
        id: project.id,
        title: "Updated Title",
        teams: [
          team
        ]
      }

      {:ok, updated} = UpdateProject.call(project.id, params, Mock.system_user())

      assert updated.title == "Updated Title"
      assert length(updated.teams) == 1
    end

    test "removes associations when explicitly passed an empty value" do
      teams = insert_list(3, :team)

      project = insert(:project, teams: teams)

      assert length(project.teams) == 3

      # Keeps existing associations if the association key is not passed

      params = %{
        id: project.id,
        title: "New Title"
      }

      {:ok, updated} = UpdateProject.call(project.id, params, Mock.system_user())

      assert length(updated.teams) == 3

      # Only removes associations when the association key is explicitly passed

      params = %{
        id: project.id,
        teams: []
      }

      {:ok, updated} = UpdateProject.call(project.id, params, Mock.system_user())

      assert length(updated.teams) == 0
    end
  end

  describe "broadcast" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      project = insert(:project)
      params = params_for(:project)

      {:ok, updated} = UpdateProject.call(project, params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "project:updated",
        payload: %{
          data: ^updated
        }
      }
    end
  end
end
