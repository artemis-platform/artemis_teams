defmodule Artemis.GetRecognition do
  import Ecto.Query

  alias Artemis.Recognition
  alias Artemis.Repo

  @default_preload [:created_by, :users]

  def call!(value, user, options \\ []) do
    get_record(value, user, options, &Repo.get_by!/2)
  end

  def call(value, user, options \\ []) do
    get_record(value, user, options, &Repo.get_by/2)
  end

  defp get_record(value, user, options, get_by) when not is_list(value) do
    get_record([id: value], user, options, get_by)
  end

  defp get_record(value, _user, options, get_by) do
    Recognition
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(value)
  end
end
