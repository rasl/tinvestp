BEGIN;

CREATE TYPE "asset_type" AS ENUM (
  'bond', 'stock', 'deposit', 'currency', 'value', 'other'
);

CREATE TABLE "asset" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "type" asset_type NOT NULL,
  "ticker" text NOT NULL,
  "name" text NULL,
  "description" text NULL,
  "created" timestamptz NULL,
  "updated" timestamptz NULL
);

CREATE TABLE "asset_bond" (
  "asset_uuid" uuid PRIMARY KEY,
  "coupon" decimal(15,2),
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("asset_uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_stock" (
  "asset_uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("asset_uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_deposit" (
  "asset_uuid" uuid PRIMARY KEY,
  "percent" real,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("asset_uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_currency" (
  "asset_uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("asset_uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_other" (
  "asset_uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("asset_uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "account" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "asset_uuid" uuid NOT NULL,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY ("asset_uuid") REFERENCES "asset" ("uuid")
);

CREATE TABLE "exchange_rate" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "datetime" timestamptz NOT NULL,
  "asset_from_uuid" uuid NOT NULL,
  "asset_to_uuid" uuid NOT NULL,
  "exchange_rate_value" decimal(15,8) NOT NULL,
  CONSTRAINT "fk_asset_from_uuid" FOREIGN KEY("asset_from_uuid") REFERENCES "asset" ("uuid"),
  CONSTRAINT "fk_asset_to_uuid" FOREIGN KEY("asset_to_uuid") REFERENCES "asset" ("uuid")
);

CREATE TYPE transaction_type AS ENUM (
  'sell', 'buy', 'dividends', 'coupons', 'tax', 'commission'
);

CREATE TYPE transaction_operation AS ENUM(
  'income', 'outcome'
);

-- TODO P0 architecture: taxes, commissions, dividends, coupons, other when one asset is source other asset
CREATE TABLE "transaction" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "operation" transaction_operation NOT NULL,
  "type" transaction_type NOT NULL,
  "account_uuid" uuid NOT NULL,
  "quantity" decimal(15,2) NOT NULL,
  "datetime" timestamptz NOT NULL DEFAULT now(),
  "exchange_rate_uuid" uuid NOT NULL,
  CONSTRAINT "fk_account_uuid" FOREIGN KEY("account_uuid") REFERENCES "account" ("uuid"),
  CONSTRAINT "fk_exchange_rate_uuid" FOREIGN KEY("exchange_rate_uuid") REFERENCES "exchange_rate" ("uuid")
);

CREATE VIEW "asset_history" AS (
SELECT
transaction.uuid AS transaction_uuid, transaction.operation, transaction.type AS transaction_type, transaction.quantity,
account.uuid AS account_uuid,
asset.uuid AS asset_uuid, asset.ticker, asset.name, asset.description, asset.type AS asset_type,
exchange_rate.uuid AS exchage_rate_uuid, exchange_rate.exchange_rate_value, exchange_rate.datetime, exchange_rate.asset_from_uuid, exchange_rate.asset_to_uuid
FROM
transaction
LEFT JOIN account on (transaction.account_uuid = account.uuid)
LEFT JOIN asset on (account.asset_uuid = asset.uuid)
LEFT JOIN exchange_rate on (transaction.exchange_rate_uuid = exchange_rate.uuid)
);

-- TODO P1 (technical or architecture): need take choose other currencies $, EUR and etc.
CREATE VIEW "asset_rub" AS (
SELECT
uuid, type, ticker, name, description, created, updated
FROM asset
WHERE ticker = 'RUB'
LIMIT 1
);

-- SQL ANSI
CREATE VIEW "exchange_rate_last2" AS (
SELECT
    er1.uuid, er1.asset_from_uuid, er1.asset_to_uuid, er1.datetime, er1.exchange_rate_value
FROM exchange_rate er1
LEFT JOIN exchange_rate er2 on (
    er1.asset_from_uuid = er2.asset_from_uuid and er1.asset_to_uuid = er2.asset_to_uuid and er1.datetime < er2.datetime
    )
WHERE er2.uuid is NULL
);

-- Postgres feature row_number() over()
CREATE VIEW "exchange_rate_last" AS (
SELECT
er.uuid, er.datetime, er.asset_from_uuid, er.asset_to_uuid, er.exchange_rate_value
FROM (
SELECT
    ROW_NUMBER() OVER(PARTITION BY asset_from_uuid, asset_to_uuid ORDER BY datetime DESC) AS row_number, exchange_rate.*
FROM exchange_rate
) er
WHERE er.row_number = 1
);

CREATE VIEW "asset_result" AS (
SELECT
asset_uuid, asset_type, asset_name,
account_uuid,
buy_quantity, spent_on_buy,
sell_quantity, earned_on_sell,
remain_quantity, remain_quantity * exchange_rate_value_current AS remain_value,
earned_on_sell + remain_quantity * exchange_rate_value_current AS total_value,
earned_on_sell + remain_quantity * exchange_rate_value_current - spent_on_buy AS absolute_margin,
((earned_on_sell + remain_quantity * exchange_rate_value_current) / spent_on_buy - 1) * 100 AS percent_margin

FROM (

SELECT
asset_uuid, asset_type, asset_name,
account_uuid,
SUM(CASE WHEN transaction_type = 'buy' THEN transaction_quantity END) AS buy_quantity,
SUM(CASE WHEN transaction_type = 'sell' THEN transaction_quantity END) AS sell_quantity,
SUM(CASE
  WHEN transaction_operation = 'income' THEN transaction_quantity
  WHEN transaction_operation = 'outcome' THEN -transaction_quantity
END) as remain_quantity,

exchange_rate_value_current,
SUM(CASE WHEN transaction_type = 'buy' THEN transaction_quantity * exchange_rate_value  END) as spent_on_buy,
SUM(CASE WHEN transaction_type = 'sell' THEN transaction_quantity * exchange_rate_value  END) as earned_on_sell

FROM (

SELECT
t.uuid AS transaction_uuid, t.operation AS transaction_operation, t.type AS transaction_type, t.quantity AS transaction_quantity,
account.uuid AS account_uuid,
asset.uuid AS asset_uuid, asset.type AS asset_type, asset.name AS asset_name, asset.description AS asset_description,
erl.exchange_rate_value AS exchange_rate_value_current, erl.uuid AS exchange_rate_uuid, erl.asset_from_uuid AS exchange_rate_asset_from_uuid, erl.asset_to_uuid AS exchange_rate_asset_to_uuid,
er.exchange_rate_value AS exchange_rate_value
FROM transaction t
LEFT JOIN account  ON (t.account_uuid = account.uuid)
LEFT JOIN asset ON (asset.uuid = account.asset_uuid)
LEFT JOIN asset_rub ON (1=1)
LEFT JOIN exchange_rate_last erl ON (erl.asset_from_uuid=account.asset_uuid AND erl.asset_to_uuid=asset_rub.uuid)
LEFT JOIN exchange_rate er ON (t.exchange_rate_uuid = er.uuid)

) quantity_aggregation
GROUP BY asset_uuid, asset_type, asset_name, account_uuid, exchange_rate_value_current

) sum_aggregation
);

COMMIT;