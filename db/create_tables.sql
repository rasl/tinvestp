CREATE TYPE "asset_type" AS ENUM (
  'bond', 'stock', 'deposit', 'currency', 'value', 'other'
);

CREATE TABLE "assets" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "asset_type" asset_type NOT NULL,
  "tiker" text NOT NULL,
  "name" text NULL,
  "description" text NULL,
  "created" timestamptz NULL,
  "updated" timestamptz NULL
);

CREATE TABLE "asset_bonds" (
  "uuid" uuid PRIMARY KEY,
  "cupon" decimal(15,2),
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid"
    FOREIGN KEY("uuid") REFERENCES "assets" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_stocks" (
  "uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid"
    FOREIGN KEY("uuid") REFERENCES "assets" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_deposits" (
  "uuid" uuid PRIMARY KEY,
  "percent" real,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid"
    FOREIGN KEY("uuid") REFERENCES "assets" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_currency" (
  "uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid"
    FOREIGN KEY("uuid") REFERENCES "assets" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "asset_others" (
  "uuid" uuid PRIMARY KEY,
  "created" timestamptz null,
  "updated" timestamptz null,
  CONSTRAINT "fk_asset_uuid"
    FOREIGN KEY("uuid") REFERENCES "assets" ("uuid") ON DELETE CASCADE
);

CREATE TABLE "exchange_rates" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "datetime" timestamptz NOT NULL,
  "asset_uuid_from" uuid NOT NULL,
  "asset_uuid_to" uuid NOT NULL,
  "price" decimal(15,2) NOT NULL,
  CONSTRAINT "fk_asset_uuid_from"
    FOREIGN KEY("asset_uuid_from") REFERENCES "assets" ("uuid"),
  CONSTRAINT "fk_asset_uuid_to"
    FOREIGN KEY("asset_uuid_to") REFERENCES "assets" ("uuid")
);

CREATE TYPE transaction_type AS ENUM (
  'sell', 'buy', 'devidends', 'cupons', 'tax', 'commission'
);

CREATE TYPE transaction_result AS ENUM(
  'income', 'outcome'
);

CREATE TABLE "transactions" (
  "uuid" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "type" transaction_type NOT NULL,
  "asset_uuid" uuid NOT NULL,
  "quantity" decimal(15,2) NOT NULL,
  "bid_price" uuid NOT NULL,
  CONSTRAINT "fk_asset"
    FOREIGN KEY("asset_uuid") REFERENCES "assets" ("uuid"),
  CONSTRAINT "fk_exchange_rate"
    FOREIGN KEY("bid_price") REFERENCES "exchange_rates" ("uuid")
);

/**
-- TODO view
SELECT
volume_by_current_price + sell_volume - buy_volume AS absolutle_margin,
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
-- TODO taxs, commissions, devidends, cupons, other (?)
-- TODO income, outcome types
array_agg((CASE WHEN transactions.type = 'sell' THEN transactions.quantity  END)),
SUM(CASE WHEN transactions.type = 'sell' THEN transactions.quantity END) AS sell_quantity,

array_agg((CASE WHEN transactions.type = 'buy' THEN transactions.quantity  END)),
SUM(CASE WHEN transactions.type = 'buy' THEN transactions.quantity END) AS buy_quantity,

array_agg((CASE WHEN transactions.type = 'buy' THEN transactions.quantity WHEN transactions.type = 'sell' THEN -transactions.quantity END)),
SUM(CASE WHEN transactions.type = 'buy' THEN transactions.quantity WHEN transactions.type = 'sell' THEN -transactions.quantity END) as reminder_quantity,

array_agg(CASE WHEN transactions.type = 'sell' THEN transactions.quantity * exchange_rates.price  END),
SUM(CASE WHEN transactions.type = 'sell' THEN transactions.quantity * exchange_rates.price  END) as sell_volume,

array_agg(CASE WHEN transactions.type = 'buy' THEN transactions.quantity * exchange_rates.price  END),
SUM(CASE WHEN transactions.type = 'buy' THEN transactions.quantity * exchange_rates.price  END) as buy_volume,

1 AS current_price, -- TODO current price = LAST PRICE by datetime

assets.uuid, assets.asset_type, assets.tiker, assets.name,
array_agg(transactions.uuid), array_agg(transactions.type), array_agg(transactions.quantity),
array_agg(exchange_rates.datetime), array_agg(exchange_rates.price), array_agg(exchange_rates.asset_uuid_from), array_agg(exchange_rates.asset_uuid_to)


FROM assets
INNER JOIN transactions ON (transactions.asset_uuid = assets.uuid)
LEFT JOIN exchange_rates ON (exchange_rates.uuid = transactions.bid_price)
GROUP BY assets.uuid
) sub
) subsub
*/
