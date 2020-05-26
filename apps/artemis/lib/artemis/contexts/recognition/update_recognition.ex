defmodule Artemis.UpdateRecognition do
  use Artemis.Context
  use Assoc.Updater, repo: Artemis.Repo

  alias Artemis.GetRecognition
  alias Artemis.GetUserRecognition
  alias Artemis.Helpers.Markdown
  alias Artemis.Repo
  alias Artemis.Recognition

  def call!(id, params, user) do
    case call(id, params, user) do
      {:error, _} -> raise(Artemis.Context.Error, "Error updating recognition")
      {:ok, result} -> result
    end
  end

  def call(id, params, user) do
    with_transaction(fn ->
      params = get_updated_params(id, params, user)

      id
      |> get_record(user)
      |> update_record(params)
      |> update_associations(params)
      |> Event.broadcast("recognition:updated", params, user)
    end)
  end

  defp get_updated_params(id, params, user) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> Map.put("id", id)
    |> maybe_add_existing_user_recognitions(user)
  end

  defp maybe_add_existing_user_recognitions(%{"id" => id, "user_recognitions" => user_recognitions} = params, user) do
    with_existing_user_recognitions =
      Enum.reduce(user_recognitions, [], fn user_recognition_params, acc ->
        existing_record =
          user_recognition_params
          |> Artemis.Helpers.keys_to_strings()
          |> Map.put_new("recognition_id", id)
          |> get_user_recognition(user)

        case existing_record do
          nil -> [user_recognition_params | acc]
          _ -> [existing_record | acc]
        end
      end)

    Map.put(params, "user_recognitions", with_existing_user_recognitions)
  end

  defp maybe_add_existing_user_recognitions(params, _user), do: params

  defp get_user_recognition(%{"recognition_id" => recognition_id, "user_id" => user_id}, user) do
    params = [recognition_id: recognition_id, user_id: user_id]

    GetUserRecognition.call(params, user)
  end

  defp get_user_recognition(_params, _user), do: nil

  def get_record(%{id: id}, user), do: get_record(id, user)
  def get_record(id, user), do: GetRecognition.call(id, user)

  defp update_record(nil, _params), do: {:error, "Record not found"}

  defp update_record(record, params) do
    params = update_params(record, params)

    record
    |> Recognition.changeset(params)
    |> Repo.update()
  end

  defp update_params(_record, params) do
    params
    |> Artemis.Helpers.keys_to_strings()
    |> maybe_update_description_html()
  end

  defp maybe_update_description_html(%{"description" => description} = params) do
    value = Markdown.to_html!(description)

    Map.put(params, "description_html", value)
  end

  defp maybe_update_description_html(params), do: params
end
