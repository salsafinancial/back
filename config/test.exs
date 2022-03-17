use Mix.Config

# Configure your database
config :salsa_crm, SalsaCrm.Repo,
  username: "postgres",
  password: "postgres",
  database: "salsa_crm_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :salsa_crm, SalsaCrmWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
