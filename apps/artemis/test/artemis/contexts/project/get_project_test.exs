defmodule Artemis.GetProjectTest do
  use Artemis.DataCase

  import Artemis.Factories

  alias Artemis.GetProject

  setup do
    project = insert(:project)

    {:ok, project: project}
  end

  describe "call" do
    test "returns nil project not found" do
      invalid_id = 50_000_000

      assert GetProject.call(invalid_id, Mock.system_user()) == nil
    end

    test "finds project by id", %{project: project} do
      assert GetProject.call(project.id, Mock.system_user()).id == project.id
    end

    test "finds record by keyword list", %{project: project} do
      assert GetProject.call([title: project.title], Mock.system_user()).id == project.id
    end
  end

  describe "call!" do
    test "raises an exception project not found" do
      invalid_id = 50_000_000

      assert_raise Ecto.NoResultsError, fn ->
        GetProject.call!(invalid_id, Mock.system_user()) == nil
      end
    end

    test "finds project by id", %{project: project} do
      assert GetProject.call!(project.id, Mock.system_user()).id == project.id
    end
  end
end
