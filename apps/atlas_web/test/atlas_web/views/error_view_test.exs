defmodule AtlasWeb.ErrorViewTest do
  use AtlasWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 401.html" do
    assert render_to_string(AtlasWeb.ErrorView, "401.html", []) =~ "Unauthorized"
  end

  test "renders 403.html" do
    assert render_to_string(AtlasWeb.ErrorView, "403.html", []) =~ "Forbidden"
  end

  test "renders 404.html" do
    assert render_to_string(AtlasWeb.ErrorView, "404.html", []) =~ "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(AtlasWeb.ErrorView, "500.html", []) =~ "Internal Server Error"
  end
end
