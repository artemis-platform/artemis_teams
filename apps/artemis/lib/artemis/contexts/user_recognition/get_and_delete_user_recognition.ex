defmodule Artemis.GetAndDeleteUserRecognition do
  use Artemis.Context

  alias Artemis.DeleteUserRecognition
  alias Artemis.GetUserRecognition

  def call(user_id, recognition_id, params, creator) do
    params
    |> Map.put("recognition_id", recognition_id)
    |> Map.put("user_id", user_id)
    |> call(creator)
  end

  def call(params, creator) do
    params = Artemis.Helpers.keys_to_strings(params)

    case get_record(params, creator) do
      nil -> :not_found
      record -> DeleteUserRecognition.call(record.id, params, creator)
    end
  end

  defp get_record(params, creator) when is_map(params) do
    values =
      params
      |> Map.take(["recognition_id", "user_id"])
      |> Artemis.Helpers.keys_to_atoms()
      |> Enum.into([])

    GetUserRecognition.call(values, creator)
  end

  defp get_record(id, creator) do
    GetUserRecognition.call(id, creator)
  end
end
