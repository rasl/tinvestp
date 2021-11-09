BEGIN;

CREATE TYPE "asset_type" AS ENUM (
  'bond', 'stock', 'deposit', 'currency', 'value', 'other'
);

CREATE TABLE "asset" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "asset_type" asset_type NOT NULL,
  "ticker" text NOT NULL,
  "name" text NULL,
  "description" text NULL,
  "created" timestamptz NULL,
  "updated" timestamptz NULL
);

CREATE TABLE "asset_bond" (
  "uuid" uuid PRIMARY KEY,
  "coupon" decimal(15,2),
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_stock" (
  "uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_deposit" (
  "uuid" uuid PRIMARY KEY,
  "percent" real,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid"
    FOREIGN KEY("uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_currency" (
  "uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_other" (
  "uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY("uuid") REFERENCES "asset" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "account" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "asset_uuid" uuid NOT NULL,
  CONSTRAINT "fk_asset_uuid" FOREIGN KEY ("asset_uuid") REFERENCES "asset" ("uuid")
);

CREATE TABLE "exchange_rate" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "datetime" timestamptz NOT NULL,
  "asset_uuid_from" uuid NOT NULL,
  "asset_uuid_to" uuid NOT NULL,
  "price" decimal(15,2) NOT NULL,
  CONSTRAINT "fk_asset_uuid_from" FOREIGN KEY("asset_uuid_from") REFERENCES "asset" ("uuid"),
  CONSTRAINT "fk_asset_uuid_to" FOREIGN KEY("asset_uuid_to") REFERENCES "asset" ("uuid")
);

CREATE TYPE transaction_type AS ENUM (
  'sell', 'buy', 'dividends', 'coupons', 'tax', 'commission'
);

CREATE TYPE transaction_operation AS ENUM(
  'income', 'outcome'
);

CREATE TABLE "transaction" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "operation" transaction_operation NOT NULL,
  "type" transaction_type NOT NULL,
  "account_uuid" uuid NOT NULL,
  "quantity" decimal(15,2) NOT NULL,
  "bid_price" uuid NOT NULL,
  CONSTRAINT "fk_account" FOREIGN KEY("account_uuid") REFERENCES "account" ("uuid"),
  CONSTRAINT "fk_exchange_rate" FOREIGN KEY("bid_price") REFERENCES "exchange_rate" ("uuid")
);

/**
-- TODO view
SELECT
volume_by_current_price + sell_volume - buy_volume AS absolute_margin,
(volume_by_current_price + sell_volume - buy_volume) / buy_volume * 100 AS percent_margin,
buy_quantity, buy_volume,
sell_quantity, sell_volume,
*
FROM (
SELECT
reminder_quantity, reminder_quantity * current_price AS volume_by_current_price,
*
FROM
(SELECT
-- TODO taxes, commissions, dividends, coupons, other (?)
-- TODO income, outcome types
array_agg((CASE WHEN transaction.type = 'sell' THEN transaction.quantity  END)),
SUM(CASE WHEN transaction.type = 'sell' THEN transaction.quantity END) AS sell_quantity,

array_agg((CASE WHEN transaction.type = 'buy' THEN transaction.quantity  END)),
SUM(CASE WHEN transaction.type = 'buy' THEN transaction.quantity END) AS buy_quantity,

array_agg((CASE WHEN transaction.type = 'buy' THEN transaction.quantity WHEN transaction.type = 'sell' THEN -transaction.quantity END)),
SUM(CASE WHEN transaction.type = 'buy' THEN transaction.quantity WHEN transaction.type = 'sell' THEN -transaction.quantity END) as reminder_quantity,

array_agg(CASE WHEN transaction.type = 'sell' THEN transaction.quantity * exchange_rate.price  END),
SUM(CASE WHEN transaction.type = 'sell' THEN transaction.quantity * exchange_rate.price  END) as sell_volume,

array_agg(CASE WHEN transaction.type = 'buy' THEN transaction.quantity * exchange_rate.price  END),
SUM(CASE WHEN transaction.type = 'buy' THEN transaction.quantity * exchange_rate.price  END) as buy_volume,

1 AS current_price, -- TODO current price = LAST PRICE by datetime

asset.uuid, asset.asset_type, asset.ticker, asset.name,
array_agg(transaction.uuid), array_agg(transaction.type), array_agg(transaction.quantity),
array_agg(exchange_rate.datetime), array_agg(exchange_rate.price), array_agg(exchange_rate.asset_uuid_from), array_agg(exchange_rate.asset_uuid_to)


FROM asset
INNER JOIN transaction ON (transaction.asset_uuid = asset.uuid)
LEFT JOIN exchange_rate ON (exchange_rate.uuid = transaction.bid_price)
GROUP BY asset.uuid
) sub
) subsub
*/

COMMIT;