defmodule Artemis.ProjectTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.EventAnswer
  alias Artemis.Project
  alias Artemis.Team

  @preload [:event_answers, :team, :teams]

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

  describe "associations - teams" do
    setup do
      teams = insert_list(3, :team)
      project = insert(:project, teams: teams)

      {:ok, project: Repo.preload(project, @preload)}
    end

    test "can update associations through record", %{project: project} do
      new_team = insert(:team)

      project =
        Project
        |> preload(^@preload)
        |> Repo.get(project.id)

      assert length(project.teams) == 3

      # Can append to existing teams

      {:ok, updated} =
        project
        |> Project.associations_changeset(%{teams: project.teams ++ [new_team]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.teams) == 4

      previous_team_ids =
        project.teams
        |> Enum.map(& &1.id)
        |> MapSet.new()

      updated_team_ids =
        updated.teams
        |> Enum.map(& &1.id)
        |> MapSet.new()

      assert MapSet.subset?(previous_team_ids, updated_team_ids)

      # Can replace existing teams

      {:ok, updated} =
        project
        |> Project.associations_changeset(%{teams: [new_team]})
        |> Repo.update()

      updated = Repo.preload(updated, @preload)

      assert length(updated.teams) == 1
    end

    test "deleting record does not delete associations", %{project: project} do
      assert Repo.get(Project, project.id) != nil
      assert length(project.teams) == 3

      Enum.map(project.teams, fn team ->
        team =
          Team
          |> preload([:projects])
          |> Repo.get(team.id)

        project_ids = Enum.map(team.projects, & &1.id)

        assert Enum.member?(project_ids, project.id)
      end)

      Repo.delete(project)

      assert Repo.get(Project, project.id) == nil

      Enum.map(project.teams, fn team ->
        team =
          Team
          |> preload([:projects])
          |> Repo.get(team.id)

        project_ids = Enum.map(team.projects, & &1.id)

        refute Enum.member?(project_ids, project.id)
      end)
    end
  end
end
