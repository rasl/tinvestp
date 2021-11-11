BEGIN;

INSERT INTO "asset" ("uuid", "type", "ticker", "name", "description", "created", "updated") VALUES
('2dee7cdb-0b00-4bc8-b0ab-e05a060522ce',	'deposit',	'',	'deposit',	NULL,	'2021-11-09 20:11:50.976296+00',	'2021-11-09 20:11:50.976296+00'),
('2689e5ba-c736-4596-874e-9c5e5b91e5fa',	'currency',	'RUB',	'ruble',	NULL,	'2021-11-09 20:12:20.606554+00',	'2021-11-09 20:12:20.606554+00'),
('f11000d7-37ed-4823-b95b-6fcaffc443ac',	'bond',	'',	'bond',	NULL,	'2021-11-09 20:13:03.524126+00',	'2021-11-09 20:13:03.524126+00'),
('23f30753-96b0-4c42-93db-84151638304c',	'stock',	'SBR',	'sber',	NULL,	'2021-11-10 22:41:40.128216+00',	'2021-11-10 22:41:40.128216+00');

INSERT INTO "account" ("uuid", "asset_uuid") VALUES
('8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	'2dee7cdb-0b00-4bc8-b0ab-e05a060522ce'),
('dbe79474-d296-4cb7-82d0-956b29b371db',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa'),
('d054d47b-8ba7-4dd0-a205-e94881da2cba',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa'),
('8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	'f11000d7-37ed-4823-b95b-6fcaffc443ac'),
('f0c6798c-d723-4479-aaae-adf3a7200faa',	'f11000d7-37ed-4823-b95b-6fcaffc443ac'),
('6fe60719-1501-4149-9c87-197c7307fdb9',	'23f30753-96b0-4c42-93db-84151638304c');

INSERT INTO "exchange_rate" ("uuid", "datetime", "asset_from_uuid", "asset_to_uuid", "exchange_rate_value") VALUES
('85e6fdf5-286f-4016-affd-8cdd6462b759',	'2021-11-09 20:16:15.941286+00',	'2dee7cdb-0b00-4bc8-b0ab-e05a060522ce',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1.00000000),
('9861a4bf-405a-401f-bcca-68c8991ac7a0',	'2021-11-09 20:16:58.55737+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1000.00000000),
('93a1db41-92df-466b-a44e-4d1b47a5118e',	'2021-11-09 20:17:26.341329+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1100.00000000),
('ca94630a-c556-44f0-ae13-2508de001a32',	'2021-11-09 20:18:01.327279+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1150.00000000),
('dcfc5161-7f30-440d-828b-18f510d195af',	'2021-11-09 20:38:49.11399+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1200.00000000),
('90aca52b-df67-40ab-a8da-b331a8ac3417',	'2021-11-09 20:38:49.11399+00',	'f11000d7-37ed-4823-b95b-6fcaffc443ac',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	1201.00000000),
('8c7d538a-80de-4ccc-b3c6-eb954ec809e4',	'2021-11-10 22:44:03.220695+00',	'23f30753-96b0-4c42-93db-84151638304c',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	340.00000000),
('6275fe18-2d3f-4fe2-89cb-455099a6d229',	'2021-11-10 22:45:03.220695+00',	'23f30753-96b0-4c42-93db-84151638304c',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	342.00000000),
('cb8d4406-2c7a-4a39-92cc-466fc3423f77',	'2021-11-10 22:45:03.70046+00',	'23f30753-96b0-4c42-93db-84151638304c',	'2689e5ba-c736-4596-874e-9c5e5b91e5fa',	339.00000000);

INSERT INTO "event" ("uuid", "type", "description", "reason_account_uuid") VALUES
('cb8d4406-2c7a-4a39-92cc-466fc3423f71',	'buy',	'put to deposit',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f72',	'sell',	'take from deposit',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f90',	'interest',	'interest from deposit',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f73',	'buy',	'buy bonds',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f74',	'sell',	'sell bonds',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f75',	'sell',	'sell bonds',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f76',	'buy',	'buy stock: sber',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f77',	'buy',	'sell stock: sber',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f78',	'dividends',	'dividends stock: sber',	'6fe60719-1501-4149-9c87-197c7307fdb9'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f79',	'commission',	'commission stock: sber',	'6fe60719-1501-4149-9c87-197c7307fdb9'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f80',	'tax',	'tax stock: sber',	'6fe60719-1501-4149-9c87-197c7307fdb9'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f81',	'coupons',	'coupons bonds',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f82',	'commission',	'commission bonds',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef'),
('cb8d4406-2c7a-4a39-92cc-466fc3423f83',	'tax',	'tax bonds',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef');

INSERT INTO "transaction" ("uuid", "operation", "event_uuid", "account_uuid", "quantity", "datetime", "exchange_rate_uuid") VALUES
('7ccaa190-0c8a-4d25-84be-1254ae801302',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f71',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	500000.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('ee4caf07-6377-4a84-ba7e-9ff42763753f',	'outcome',	'cb8d4406-2c7a-4a39-92cc-466fc3423f72',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	10.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('7ccaa190-0c8a-4d25-84be-1254ae801322',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f90',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	555.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('1cd56f4b-13ca-4deb-96ec-5f0ba1cc396d',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f73',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	5.00,	'2021-11-09 20:38:49.11399+00',	'9861a4bf-405a-401f-bcca-68c8991ac7a0'),
('751a309c-a761-4ab9-8e47-66c3ce561b45',	'outcome',	'cb8d4406-2c7a-4a39-92cc-466fc3423f74',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	1.00,	'2021-11-09 20:38:49.11399+00',	'93a1db41-92df-466b-a44e-4d1b47a5118e'),
('a0e80054-ab51-4f42-820c-8a33ef7c2c61',	'outcome',	'cb8d4406-2c7a-4a39-92cc-466fc3423f75',	'8b8777e6-0e9d-47a2-b6f8-7b3b8919eeef',	2.00,	'2021-11-09 20:38:49.11399+00',	'ca94630a-c556-44f0-ae13-2508de001a32'),
('649033ba-a6d8-479f-b2fa-7a31e753faa1',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f76',	'6fe60719-1501-4149-9c87-197c7307fdb9',	10.00,	'2021-11-10 22:46:22.078756+00',	'8c7d538a-80de-4ccc-b3c6-eb954ec809e4'),
('8c5a7cbd-8688-45ea-9805-182039e6ddfc',	'outcome',	'cb8d4406-2c7a-4a39-92cc-466fc3423f77',	'6fe60719-1501-4149-9c87-197c7307fdb9',	5.00,	'2021-11-10 22:46:22.078756+00',	'6275fe18-2d3f-4fe2-89cb-455099a6d229'),
('7ccaa190-0c8a-4d25-84be-1254ae801312',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f78',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	222.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('7ccaa190-0c8a-4d25-84be-1254ae801303',	'outcome',	'cb8d4406-2c7a-4a39-92cc-466fc3423f79',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	22.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('7ccaa190-0c8a-4d25-84be-1254ae801304',	'outcome',	'cb8d4406-2c7a-4a39-92cc-466fc3423f80',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	2.20,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('7ccaa190-0c8a-4d25-84be-1254ae801305',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f81',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	333.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('7ccaa190-0c8a-4d25-84be-1254ae801306',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f82',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	33.00,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759'),
('7ccaa190-0c8a-4d25-84be-1254ae801307',	'income',	'cb8d4406-2c7a-4a39-92cc-466fc3423f83',	'8d8fde97-d609-4d0f-bed5-73d1a91d70e0',	3.30,	'2021-11-09 20:38:49.11399+00',	'85e6fdf5-286f-4016-affd-8cdd6462b759');

COMMIT;