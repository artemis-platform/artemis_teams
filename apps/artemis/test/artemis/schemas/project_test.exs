defmodule Artemis.ProjectTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventAnswer
  alias Artemis.Project
  alias Artemis.Team

  @preload [:event_answers, :team]

  describe "attributes - constraints" do
    test "required associations" do
      params = params_for(:project)

      {:error, changeset} =
        %Project{}
        |> Project.changeset(params)
        |> Repo.insert()

      assert errors_on(changeset) == %{team_id: ["can't be blank"]}
    end
  end

  describe "associations - event answers" do
    setup do
      project = insert(:project)

      insert_list(3, :event_answer, project: project)

      {:ok, project: Repo.preload(project, @preload)}
    end

    test "cannot update associations through parent", %{project: project} do
      new_event_answer = insert(:event_answer, project: project)

      project =
        Project
        |> preload(^@preload)
        |> Repo.get(project.id)

      assert length(project.event_answers) == 4

      {:ok, updated} =
        project
        |> Project.changeset(%{event_answers: [new_event_answer]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.event_answers) == 4
    end

    test "deleting association does not remove record", %{project: project} do
      assert Repo.get(Project, project.id) != nil
      assert length(project.event_answers) == 3

      Enum.map(project.event_answers, &Repo.delete(&1))

      project =
        Project
        |> preload(^@preload)
        |> Repo.get(project.id)

      assert Repo.get(Project, project.id) != nil
      assert length(project.event_answers) == 0
    end

    test "deleting record deletes associations", %{project: project} do
      assert Repo.get(Project, project.id) != nil
      assert length(project.event_answers) == 3

      Enum.map(project.event_answers, fn event_answer ->
        assert Repo.get(EventAnswer, event_answer.id).project_id == project.id
      end)

      Repo.delete(project)

      assert Repo.get(Project, project.id) == nil

      Enum.map(project.event_answers, fn event_answer ->
        assert Repo.get(EventAnswer, event_answer.id) == nil
      end)
    end
  end

  describe "associations - team" do
    setup do
      project = insert(:project)

      {:ok, project: Repo.preload(project, @preload)}
    end

    test "deleting association removes record", %{project: project} do
      assert Repo.get(Team, project.team.id) != nil

      Repo.delete!(project.team)

      assert Repo.get(Team, project.team.id) == nil
      assert Repo.get(Project, project.id) == nil
    end

    test "deleting record does not remove association", %{project: project} do
      assert Repo.get(Team, project.team.id) != nil

      Repo.delete!(project)

      assert Repo.get(Team, project.team.id) != nil
      assert Repo.get(Project, project.id) == nil
    end
  end
end
