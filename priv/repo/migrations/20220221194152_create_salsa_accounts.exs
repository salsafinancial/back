defmodule SalsaCrm.Repo.Migrations.CreateSalsaAccounts do
  use Ecto.Migration

  def change do
    execute "CREATE SCHEMA IF NOT EXISTS salsa", "DROP SCHEMA salsa CASCADE"

    execute "
      CREATE TABLE IF NOT EXISTS salsa.accounts
      (
        uuid                    uuid          NOT NULL,
        id                      serial        NOT NULL,
        account_id              varchar(50),
        wallet                  varchar(50),
        status                  varchar(50),
        total_amount            numeric(32,4),
        future_payments         numeric(32,4),
        payments_made           numeric(32,4),
        currency_code           varchar(10),
        registered_at           timestamp with time zone,
        dashboard_data          jsonb,
        inserted_at             timestamp with time zone NOT NULL,
        updated_at              timestamp with time zone NOT NULL,
        PRIMARY KEY(uuid, wallet, inserted_at)
      )
      PARTITION BY LIST(wallet);
    ", "DROP TABLE IF EXISTS salsa.accounts CASCADE"
  end
end
