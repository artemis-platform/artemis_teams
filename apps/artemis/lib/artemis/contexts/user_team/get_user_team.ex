defmodule Artemis.GetUserTeam do
  use Artemis.Context

  import Ecto.Query

  alias Artemis.Repo
  alias Artemis.UserTeam

  @default_preload [:created_by, :team, :user]

  def call!(value, _user, options \\ []) do
    get_record(value, options, &Repo.get_by!/2)
  end

  def call(value, _user, options \\ []) do
    get_record(value, options, &Repo.get_by/2)
  end

  defp get_record(value, options, get_by) when not is_list(value) do
    get_record([id: value], options, get_by)
  end

  defp get_record(value, options, get_by) do
    UserTeam
    |> select_query(UserTeam, options)
    |> preload(^Keyword.get(options, :preload, @default_preload))
    |> get_by.(value)
  end
end
