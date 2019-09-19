defmodule ArtemisWeb.Config.Navigation do
  import ArtemisWeb.UserAccess

  alias ArtemisWeb.Router.Helpers, as: Routes

  @doc """
  List of possible nav items. Each entry should define:

  - label: user facing label for the nav item
  - path: function that takes `conn` as the first argument and returns a string path
  - verify: function that takes the `current_user` as the first argument and returns a boolean
  """
  def get_nav_items do
    Enum.reverse(
      "Event Log": [
        [
          label: "View Event Logs",
          path: &Routes.event_log_path(&1, :index),
          verify: &has?(&1, "event-logs:list")
        ]
      ],
      Features: [
        [
          label: "List Features",
          path: &Routes.feature_path(&1, :index),
          verify: &has?(&1, "features:list")
        ],
        [
          label: "Create New Feature",
          path: &Routes.feature_path(&1, :new),
          verify: &has?(&1, "features:create")
        ]
      ],
      "HTTP Request Logs": [
        [
          label: "View HTTP Request Logs",
          path: &Routes.http_request_log_path(&1, :index),
          verify: &has?(&1, "http-request-logs:list")
        ]
      ],
      Permissions: [
        [
          label: "List Permissions",
          path: &Routes.permission_path(&1, :index),
          verify: &has?(&1, "permissions:list")
        ],
        [
          label: "Create New Permission",
          path: &Routes.permission_path(&1, :new),
          verify: &has?(&1, "permissions:create")
        ]
      ],
      Roles: [
        [
          label: "List Roles",
          path: &Routes.role_path(&1, :index),
          verify: &has?(&1, "roles:list")
        ],
        [
          label: "Create New Role",
          path: &Routes.role_path(&1, :new),
          verify: &has?(&1, "roles:create")
        ]
      ],
      Sessions: [
        [
          label: "View Sessions",
          path: &Routes.session_path(&1, :index),
          verify: &has?(&1, "sessions:list")
        ]
      ],
      Tags: [
        [
          label: "List Tags",
          path: &Routes.tag_path(&1, :index),
          verify: &has?(&1, "tags:list")
        ],
        [
          label: "Create New Tag",
          path: &Routes.tag_path(&1, :new),
          verify: &has?(&1, "tags:create")
        ]
      ],
      Teams: [
        [
          label: "List Teams",
          path: &Routes.team_path(&1, :index),
          verify: &has?(&1, "teams:list")
        ],
        [
          label: "Create New Team",
          path: &Routes.team_path(&1, :new),
          verify: &has?(&1, "teams:create")
        ]
      ],
      Users: [
        [
          label: "List Users",
          path: &Routes.user_path(&1, :index),
          verify: &has?(&1, "users:list")
        ],
        [
          label: "Create New User",
          path: &Routes.user_path(&1, :new),
          verify: &has?(&1, "users:create")
        ]
      ]
    )
  end
end
