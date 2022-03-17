# Salsa Back

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

# Environment Variables

These variables must be executed for microservice startup.

  * **DATABASE_URL:** The url of the database location. The format of this is: ecto://user:password@Domain/Database.
  * **HOST:** The host of the back.
  * **PORT:** The execution port. Default is 3100.
  * **RELEASE_COOKIE:** Release cookie, unique text string to ensure execution and access to the machine.