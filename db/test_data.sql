BEGIN;

INSERT INTO "asset" ("uuid", "asset_type", "ticker", "name", "description", "created", "updated") VALUES
('2dee7cdb-0b00-4bc8-b0ab-e05a060522ce',	'deposit',	'',	'deposit',	NULL,	'2021-11-09 20:11:50.976296+00',	'2021-11-09 20:11:50.976296+00'),
('2689e5ba-c736-4596-874e-9c5e5b91e5fa',	'currency',	'RUB',	'ruble',	NULL,	'2021-11-09 20:12:20.606554+00',	'2021-11-09 20:12:20.606554+00'),
('f11000d7-37ed-4823-b95b-6fcaffc443ac',	'bond',	'',	'bond',	NULL,	'2021-11-09 20:13:03.524126+00',	'2021-11-09 20:13:03.524126+00');

INSERT INTO "account" ("uuid", "asset_uuid") VALUES
('8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	'2dee7cdb-0b00-4bc8-b0ab-e05a060522ce'),
('dbe79474-d296-4cb7-82d0-956b29b371db',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa'),
('d054d47b-8ba7-4dd0-a205-e94881da2cba',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa'),
('8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	'f11000d7-37ed-4823-b95b-6fcaffc443ac'),
('f0c6798c-d723-4479-aaae-adf3a7200faa',	'f11000d7-37ed-4823-b95b-6fcaffc443ac');

INSERT INTO "exchange_rate" ("uuid", "datetime", "asset_uuid_from", "asset_uuid_to", "price") VALUES
('85e6fdf5-286f-4016-affd-8cdd6462b759',	'2021-11-09 20:16:15.941286+00',	'2dee7cdb-0b00-4bc8-b0ab-e05a060522ce',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1.00),
('9861a4bf-405a-401f-bcca-68c8991ac7a0',	'2021-11-09 20:16:58.55737+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1000.00),
('93a1db41-92df-466b-a44e-4d1b47a5118e',	'2021-11-09 20:17:26.341329+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1100.00),
('ca94630a-c556-44f0-ae13-2508de001a32',	'2021-11-09 20:18:01.327279+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1150.00),
('dcfc5161-7f30-440d-828b-18f510d195af',	'2021-11-09 20:38:49.11399+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1200.00);

INSERT INTO "transaction" ("uuid", "operation", "type", "account_uuid", "quantity", "bid_price") VALUES
('7ccaa190-0c8a-4d25-84be-1254ae801302',	'income',	'buy',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	500000.00,	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('ee4caf07-6377-4a84-ba7e-9ff42763753f',	'outcome',	'sell',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	10.00,	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('1cd56f4b-13ca-4deb-96ec-5f0ba1cc396d',	'income',	'buy',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	5.00,	'9861a4bf-405a-401f-bcca-68c8991ac7a0'),
('751a309c-a761-4ab9-8e47-66c3ce561b45',	'outcome',	'sell',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	1.00,	'93a1db41-92df-466b-a44e-4d1b47a5118e'),
('a0e80054-ab51-4f42-820c-8a33ef7c2c61',	'outcome',	'sell',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	2.00,	'ca94630a-c556-44f0-ae13-2508de001a32');

-- 2021-11-09 20:40:31.164169+00

COMMIT;