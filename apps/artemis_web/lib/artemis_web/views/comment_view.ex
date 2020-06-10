defmodule ArtemisWeb.CommentView do
  use ArtemisWeb, :view

  @doc """
  Verifies user has permission to update comment
  """
  def update_comments?(record, user) do
    comment_user_id = Artemis.Helpers.deep_get(record, [:user, :id])
    owner? = comment_user_id == user.id

    cond do
      has_all?(user, ["comments:update", "comments:access:all"]) -> true
      has_all?(user, ["comments:update", "comments:access:self"]) && owner? -> true
      true -> false
    end
  end

  @doc """
  Verifies user has permission to delete comment
  """
  def delete_comments?(record, user) do
    comment_user_id = Artemis.Helpers.deep_get(record, [:user, :id])
    owner? = comment_user_id == user.id

    cond do
      has_all?(user, ["comments:delete", "comments:access:all"]) -> true
      has_all?(user, ["comments:delete", "comments:access:self"]) && owner? -> true
      true -> false
    end
  end

  @doc """
  Render comment cards with Phoenix LiveView
  """
  def live_render_comment_cards(conn, assigns \\ []) do
    id = "comment-cards"

    session =
      assigns
      |> Enum.into(%{})
      |> Map.put_new(:path, Map.get(conn, :request_path))
      |> Map.put_new(:user, current_user(conn))
      |> Artemis.Helpers.keys_to_strings()

    live_render(conn, ArtemisWeb.CommentCardsLive, id: id, session: session)
  end

  @doc """
  Checks if user is has permissions to update record
  """
  def can_update_comment?(%Plug.Conn{} = conn, record) do
    conn
    |> current_user()
    |> can_update_comment?(record)
  end

  def can_update_comment?(user, record) do
    owner? = record.user_id == user.id

    cond do
      has_all?(user, ["comments:update", "comments:access:all"]) -> true
      has_all?(user, ["comments:update", "comments:access:self"]) && owner? -> true
      true -> false
    end
  end

  @doc """
  Checks if user is has permissions to delete record
  """
  def can_delete_comment?(%Plug.Conn{} = conn, record) do
    conn
    |> current_user()
    |> can_delete_comment?(record)
  end

  def can_delete_comment?(user, record) do
    owner? = record.user_id == user.id

    cond do
      has_all?(user, ["comments:delete", "comments:access:all"]) -> true
      has_all?(user, ["comments:delete", "comments:access:self"]) && owner? -> true
      true -> false
    end
  end
end
