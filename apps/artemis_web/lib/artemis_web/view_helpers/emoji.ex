defmodule ArtemisWeb.ViewHelper.Emoji do
  use Phoenix.HTML

  @doc """
  Renders an emoji from a short name value
  """
  def render_emoji(short_name) when is_bitstring(short_name) do
    short_name
    |> String.trim(":")
    |> Exmoji.find_by_short_name()
    |> hd()
    |> Exmoji.EmojiChar.render()
  end

  @doc """
  Renders an emoji wrapped in a span tag
  """
  def render_emoji_html(short_name) do
    class = "emoji emoji-#{short_name}"
    emoji = render_emoji(short_name)

    content_tag(:span, emoji, class: class)
  end
end
