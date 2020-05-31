defmodule ArtemisWeb.ProjectControllerTest do
  use ArtemisWeb.ConnCase

  import Artemis.Factories

  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  setup %{conn: conn} do
    {:ok, conn: sign_in(conn)}
  end

  describe "index" do
    test "lists all projects", %{conn: conn} do
      conn = get(conn, Routes.project_path(conn, :index))
      assert html_response(conn, 200) =~ "Projects"
    end
  end

  describe "new project" do
    test "renders new form", %{conn: conn} do
      conn = get(conn, Routes.project_path(conn, :new))
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  describe "create project" do
    test "redirects to show when data is valid", %{conn: conn} do
      team = insert(:team)

      params = params_for(:project, team: team)

      conn = post(conn, Routes.project_path(conn, :create), project: params)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.project_path(conn, :show, id)

      conn = get(conn, Routes.project_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Title"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.project_path(conn, :create), project: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Project"
    end
  end

  describe "show" do
    setup [:create_record]

    test "shows project", %{conn: conn, record: record} do
      conn = get(conn, Routes.project_path(conn, :show, record))
      assert html_response(conn, 200) =~ "Title"
    end
  end

  describe "edit project" do
    setup [:create_record]

    test "renders form for editing chosen project", %{conn: conn, record: record} do
      conn = get(conn, Routes.project_path(conn, :edit, record))
      assert html_response(conn, 200) =~ "Edit Team Project"
    end
  end

  describe "update project" do
    setup [:create_record]

    test "redirects when data is valid", %{conn: conn, record: record} do
      conn = put(conn, Routes.project_path(conn, :update, record), project: @update_attrs)
      assert redirected_to(conn) == Routes.project_path(conn, :show, record)

      conn = get(conn, Routes.project_path(conn, :show, record))
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, record: record} do
      conn = put(conn, Routes.project_path(conn, :update, record), project: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Team Project"
    end
  end

  describe "delete project" do
    setup [:create_record]

    test "deletes chosen project", %{conn: conn, record: record} do
      conn = delete(conn, Routes.project_path(conn, :delete, record))
      assert redirected_to(conn) == Routes.project_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.project_path(conn, :show, record))
      end
    end
  end

  defp create_record(_) do
    record = insert(:project)

    {:ok, record: record}
  end
end
