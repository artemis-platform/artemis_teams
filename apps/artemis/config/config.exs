use Mix.Config

config :artemis,
  ecto_repos: [Artemis.Repo]

config :artemis, :actions,
  # NOTE: When adding action entries, also update `config/test.exs`
  github_issue_cache_warmer: [
    enabled: System.get_env("ARTEMIS_ACTION_GITHUB_ISSUE_CACHE_WARMER_ENABLED")
  ],
  ibm_cloud_iam_access_token: [
    enabled: System.get_env("ARTEMIS_ACTION_IBM_CLOUD_IAM_ACCESS_TOKEN_ENABLED")
  ],
  repo_delete_all: [
    enabled: System.get_env("ARTEMIS_ACTION_REPO_DELETE_ALL_ENABLED")
  ],
  repo_generate_filler_data: [
    enabled: System.get_env("ARTEMIS_ACTION_REPO_GENERATE_FILLER_DATA_ENABLED")
  ],
  repo_reset_on_interval: [
    enabled: System.get_env("ARTEMIS_ACTION_REPO_RESET_ON_INTERVAL_ENABLED"),
    interval: System.get_env("ARTEMIS_ACTION_REPO_RESET_ON_INTERVAL_HOURS")
  ]

config :artemis, Oban,
  repo: Artemis.Repo,
  plugins: [{Oban.Plugins.Pruner, max_age: 300}],
  queues: [default: 10],
  crontab: []

config :artemis, :users,
  root_user: %{
    name: System.get_env("ARTEMIS_ROOT_USER"),
    email: System.get_env("ARTEMIS_ROOT_EMAIL")
  },
  system_user: %{
    name: System.get_env("ARTEMIS_SYSTEM_USER"),
    email: System.get_env("ARTEMIS_SYSTEM_EMAIL")
  }

config :artemis, :github,
  repositories: [],
  token: System.get_env("ARTEMIS_GITHUB_TOKEN"),
  url: System.get_env("ARTEMIS_GITHUB_URL")

config :artemis, :ibm_cloud,
  iam_api_url: System.get_env("ARTEMIS_IBM_CLOUD_IAM_API_URL"),
  iam_api_keys: [
    ibm_cloud_iam_access_groups: System.get_env("ARTEMIS_IBM_CLOUD_IAM_API_KEY_IBM_CLOUD_IAM_ACCESS_GROUPS")
  ]

config :artemis, :interval_worker, default_log_limit: System.get_env("ARTEMIS_INTERVAL_WORKER_DEFAULT_LOG_LIMIT")

config :artemis, :zenhub,
  token: System.get_env("ARTEMIS_ZENHUB_TOKEN"),
  url: System.get_env("ARTEMIS_ZENHUB_URL")

config :config_tuples, distillery: false

config :slugger, separator_char: ?-
config :slugger, replacement_file: "lib/replacements.exs"

import_config "#{Mix.env()}.exs"
