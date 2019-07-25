defmodule Artemis.CloudantPage do
  defstruct [
    :bookmark_next,
    :bookmark_previous,
    :total_entries,
    :total_pages,
    entries: [],
    is_last_page: true
  ]
end
