defmodule ArtemisWeb.RecognitionController do
  use ArtemisWeb, :controller

  alias Artemis.CreateRecognition
  alias Artemis.Recognition
  alias Artemis.DeleteRecognition
  alias Artemis.GetRecognition
  alias Artemis.ListRecognitions
  alias Artemis.ListUsers
  alias Artemis.UpdateRecognition

  @preload [:users]

  def index(conn, params) do
    authorize(conn, "recognitions:list", fn ->
      user = current_user(conn)
      params = Map.put(params, :paginate, true)
      recognitions = ListRecognitions.call(params, user)

      assigns = [
        recognitions: recognitions
      ]

      render_format(conn, "index", assigns)
    end)
  end

  def new(conn, _params) do
    authorize(conn, "recognitions:create", fn ->
      recognition = %Recognition{users: []}
      changeset = Recognition.changeset(recognition)
      users = ListUsers.call(current_user(conn))

      assigns = [
        changeset: changeset,
        recognition: recognition,
        users: users
      ]

      render(conn, "new.html", assigns)
    end)
  end

  def create(conn, %{"recognition" => params}) do
    authorize(conn, "recognitions:create", fn ->
      user = current_user(conn)
      params = get_params(params, user)

      case CreateRecognition.call(params, user) do
        {:ok, recognition} ->
          conn
          |> put_flash(:info, "Recognition created successfully.")
          |> redirect(to: Routes.recognition_path(conn, :show, recognition))

        {:error, %Ecto.Changeset{} = changeset} ->
          recognition = %Recognition{users: []}
          users = ListUsers.call(user)

          assigns = [
            changeset: changeset,
            recognition: recognition,
            users: users
          ]

          render(conn, "new.html", assigns)
      end
    end)
  end

  def show(conn, %{"id" => id}) do
    authorize(conn, "recognitions:show", fn ->
      recognition = GetRecognition.call!(id, current_user(conn))

      render(conn, "show.html", recognition: recognition)
    end)
  end

  def edit(conn, %{"id" => id}) do
    authorize(conn, "recognitions:update", fn ->
      recognition = GetRecognition.call(id, current_user(conn), preload: @preload)
      changeset = Recognition.changeset(recognition)
      users = ListUsers.call(current_user(conn))

      assigns = [
        changeset: changeset,
        recognition: recognition,
        users: users
      ]

      render(conn, "edit.html", assigns)
    end)
  end

  def update(conn, %{"id" => id, "recognition" => params}) do
    authorize(conn, "recognitions:update", fn ->
      user = current_user(conn)
      params = get_params(params, user)

      case UpdateRecognition.call(id, params, user) do
        {:ok, recognition} ->
          conn
          |> put_flash(:info, "Recognition updated successfully.")
          |> redirect(to: Routes.recognition_path(conn, :show, recognition))

        {:error, %Ecto.Changeset{} = changeset} ->
          recognition = GetRecognition.call(id, user, preload: @preload)
          users = ListUsers.call(user)

          assigns = [
            changeset: changeset,
            recognition: recognition,
            users: users
          ]

          render(conn, "edit.html", assigns)
      end
    end)
  end

  def delete(conn, %{"id" => id} = params) do
    authorize(conn, "recognitions:delete", fn ->
      {:ok, _recognition} = DeleteRecognition.call(id, params, current_user(conn))

      conn
      |> put_flash(:info, "Recognition deleted successfully.")
      |> redirect(to: Routes.recognition_path(conn, :index))
    end)
  end

  # Helpers

  defp get_params(params, user) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put("created_by", user)
    |> Map.put("created_by_id", user.id)
    |> Map.put_new("users", [])
    |> maybe_add_user_recognitions()
  end

  defp maybe_add_user_recognitions(%{"users" => user_ids} = params) when is_list(user_ids) do
    user_recognitions = Enum.map(user_ids, &%{user_id: &1})

    Map.put(params, "user_recognitions", user_recognitions)
  end

  defp maybe_add_user_recognitions(params), do: params
end
