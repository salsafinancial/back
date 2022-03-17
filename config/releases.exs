# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

config :salsa_crm, SalsaCrm.Repo,
  # ssl: true,
  url: System.get_env("DATABASE_URL"),
  pool_size: 5

secret_key_base =
  System.get_env("SECRET_KEY_BASE") || "hXUasY8OhNnc1hSaY1ZAyDz4rwBS/b5tMuzU0+w10O1oj+RHbpI2o8/f2CGC7LPv"

config :salsa_crm, SalsaCrmWeb.Endpoint,
http: [
  port: 4564
],
secret_key_base: secret_key_base,
server: true

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :salsa_crm, SalsaCrmWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
