defmodule Artemis.TeamTest do
  use Artemis.DataCase
  use ExUnit.Case, async: true

  import Ecto.Repo
  import Artemis.Factories

  alias Artemis.Team

  describe "attributes - constraints" do
    test "slug must be unique" do
      existing = insert(:team)

      assert_raise Ecto.ConstraintError, fn ->
        insert(:team, slug: existing.slug)
      end
    end
  end

  describe "queries - active?" do
    test "returns false when not active" do
      team = insert(:team)

      assert Team.active?(team) == false
    end

    test "returns true when active" do
      team = insert(:team, active: true)

      assert Team.active?(team) == true
    end
  end
end
