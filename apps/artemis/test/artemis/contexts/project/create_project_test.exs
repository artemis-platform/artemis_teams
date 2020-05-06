defmodule Artemis.CreateProjectTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.CreateProject

  describe "call!" do
    test "returns error when params are empty" do
      assert_raise Artemis.Context.Error, fn ->
        CreateProject.call!(%{}, Mock.system_user())
      end
    end

    test "creates a project when passed valid params" do
      team = insert(:team)

      params = params_for(:project, team: team)

      project = CreateProject.call!(params, Mock.system_user())

      assert project.title == params.title
    end
  end

  describe "call" do
    test "returns error when params are empty" do
      {:error, changeset} = CreateProject.call(%{}, Mock.system_user())

      assert errors_on(changeset).title == ["can't be blank"]
    end

    test "creates a project when passed valid params" do
      team = insert(:team)

      params = params_for(:project, team: team)

      {:ok, project} = CreateProject.call(params, Mock.system_user())

      assert project.title == params.title
    end

    test "supports markdown" do
      team = insert(:team)

      params = params_for(:project, description: "# Test", team: team)

      {:ok, project} = CreateProject.call(params, Mock.system_user())

      assert project.description == params.description
      assert project.description_html == "<h1>Test</h1>\n"
    end
  end

  describe "broadcasts" do
    test "publishes event and record" do
      ArtemisPubSub.subscribe(Artemis.Event.get_broadcast_topic())

      team = insert(:team)

      params = params_for(:project, team: team)

      {:ok, project} = CreateProject.call(params, Mock.system_user())

      assert_received %Phoenix.Socket.Broadcast{
        event: "project:created",
        payload: %{
          data: ^project
        }
      }
    end
  end
end
