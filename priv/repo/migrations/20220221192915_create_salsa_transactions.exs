defmodule SalsaCrm.Repo.Migrations.CreateSalsaTransactions do
  use Ecto.Migration

  def change do
    execute "CREATE SCHEMA IF NOT EXISTS salsa", "DROP SCHEMA salsa CASCADE"

    execute "
      CREATE TABLE IF NOT EXISTS salsa.transactions
      (
        uuid                    uuid          NOT NULL,
        id                      serial        NOT NULL,
        code                    varchar(150),
        type                    varchar(50),
        account_id              varchar(50),
        source_id               varchar(50),
        recipient_id            varchar(50),
        amount                  numeric(32,4),
        value_type              varchar(20),
        currency_code           varchar(10),
        apy                     float,
        rewards                 numeric(32,4),
        date                    timestamp with time zone,
        period                  integer,
        next_payment            date,
        date_payment            timestamp with time zone,
        status                  varchar(50),
        notes                   text,
        description_transfer    text,
        misc_data               jsonb,
        inserted_at             timestamp with time zone NOT NULL,
        updated_at              timestamp with time zone NOT NULL,
        PRIMARY KEY(uuid, currency_code, inserted_at)
      )
      PARTITION BY LIST(currency_code);
    ", "DROP TABLE IF EXISTS salsa.transactions CASCADE"
  end
end
