import pytest
from updater.broker.tinkoff.parser import parse_assets, get_asset_type_from_broker_type, parse_transaction


@pytest.mark.parametrize(
    'input, expected_result',
    [
        ('Bond', 'bond'),
        ('Stock', 'stock'),
        ('Etf', 'etf'),
        ('unknown', None),
    ]
)
def test_get_asset_type_from_broker_type(input: str, expected_result: str) -> None:
    assert get_asset_type_from_broker_type(input) == expected_result


@pytest.mark.parametrize(
    'input, expected_result',
    [
        (
            {
                "figi": "BBG004730JJ5",
                "ticker": "MOEX",
                "isin": "RU000A0JR4A1",
                "minPriceIncrement": 0.01,
                "lot": 10,
                "currency": "RUB",
                "name": "Московская Биржа",
                "type": "Stock"
            },
            {
                'asset_type': 'stock',
                'ticker': 'MOEX',
                'figi': 'BBG004730JJ5',
                'isin': 'RU000A0JR4A1',
                'name': 'Московская Биржа',
                'description': None,
            }
        )
    ]
)
def test_parse_assets(input: dict, expected_result: dict) -> None:
    input = {
        "trackingId": "7a0f3882d65628b9",
        "payload": {
            "instruments": [
                {
                    "figi": "BBG004730JJ5",
                    "ticker": "MOEX",
                    "isin": "RU000A0JR4A1",
                    "minPriceIncrement": 0.01,
                    "lot": 10,
                    "currency": "RUB",
                    "name": "Московская Биржа",
                    "type": "Stock"
                },
            ]
        }}
    asset_expected_result = {
        'asset_type': 'stock',
        'ticker': 'MOEX',
        'figi': 'BBG004730JJ5',
        'isin': 'RU000A0JR4A1',
        'name': 'Московская Биржа',
        'description': None,
    }
    assets_actual_result, accounts_actual_result = parse_assets(input)
    account_expected_result = {
        'asset_uuid': assets_actual_result['BBG004730JJ5']['uuid']
    }

    del assets_actual_result['BBG004730JJ5']['uuid']
    del assets_actual_result['BBG004730JJ5']['created']
    del assets_actual_result['BBG004730JJ5']['updated']
    assert assets_actual_result['BBG004730JJ5'] == asset_expected_result

    del accounts_actual_result['BBG004730JJ5']['uuid']
    assert accounts_actual_result['BBG004730JJ5'] == account_expected_result


def test_parse_transaction_buy() -> None:
    input_broker_operation = {
        "operationType": "Buy",
        "date": "2021-11-10T21:01:07.79+03:00",
        "isMarginCall": False,
        "instrumentType": "Stock",
        "figi": "BBG004S68829",
        "quantity": 1,
        "quantityExecuted": 1,
        "price": 494,
        "payment": -494,
        "currency": "RUB",
        "commission": {
            "currency": "RUB",
            "value": -0.2
        },
        "trades": [
            {
                "tradeId": "4617352039",
                "date": "2021-11-10T21:01:07.79+03:00",
                "quantity": 1,
                "price": 494
            }
        ],
        "status": "Done",
        "id": "27191692220"
    }
    input_broker_assets = {
        "BBG004S68829": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG004S68829": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'outcome',
        'event_uuid': event['uuid'],
        'account_uuid': '11111111-1111-1111-1111-111111111111',
        'quantity': 1,
        'datetime': "2021-11-10T21:01:07.79+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-10T21:01:07.79+03:00",
        'asset_from_uuid': '00000000-0000-0000-0000-000000000000',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 494,
    }
    del event['uuid']
    assert event == {
        'type': 'buy',
        'description': '',
        'source_account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111'
    }


def test_parse_transaction_broker_commission() -> None:
    input_broker_operation = {
        "operationType": "BrokerCommission",
        "date": "2021-11-10T21:01:08.79+03:00",
        "isMarginCall": False,
        "instrumentType": "Stock",
        "figi": "BBG004S68829",
        "quantity": 0,
        "quantityExecuted": 0,
        "payment": -0.2,
        "currency": "RUB",
        "status": "Done",
        "id": "1876311927"
    }
    input_broker_assets = {
        "BBG004S68829": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG004S68829": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'outcome',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 0.2,
        'datetime': "2021-11-10T21:01:08.79+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-10T21:01:08.79+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'commission',
        'description': '',
        'source_account_uuid': '11111111-1111-1111-1111-111111111111',
    }


def test_parse_transaction_coupon() -> None:
    input_broker_operation = {
        "operationType": "Coupon",
        "date": "2021-11-15T06:00:00+03:00",
        "isMarginCall": False,
        "instrumentType": "Bond",
        "figi": "BBG00RP6D594",
        "payment": 27.42,
        "currency": "RUB",
        "status": "Done",
        "id": "1891186745"
    }
    input_broker_assets = {
        "BBG00RP6D594": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG00RP6D594": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'income',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 27.42,
        'datetime': "2021-11-15T06:00:00+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-15T06:00:00+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'coupon',
        'description': '',
        'source_account_uuid': '11111111-1111-1111-1111-111111111111',
    }


def test_parse_transaction_part_repayment() -> None:
    input_broker_operation = {
        "operationType": "PartRepayment",
        "date": "2021-11-15T06:00:00+03:00",
        "isMarginCall": False,
        "instrumentType": "Bond",
        "figi": "BBG00HZ418L3",
        "payment": 3E+2,
        "currency": "RUB",
        "status": "Done",
        "id": "1891182668"
    }
    input_broker_assets = {
        "BBG00HZ418L3": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG00HZ418L3": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'income',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 3E+2,
        'datetime': "2021-11-15T06:00:00+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-15T06:00:00+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'other',
        'description': '',
        'source_account_uuid': '11111111-1111-1111-1111-111111111111',
    }


def test_parse_transaction_dividend() -> None:
    input_broker_operation = {
        "operationType": "Dividend",
        "date": "2021-11-05T06:00:00+03:00",
        "isMarginCall": False,
        "instrumentType": "Stock",
        "figi": "BBG004S68B31",
        "payment": 263.7,
        "currency": "RUB",
        "status": "Done",
        "id": "1841616089"
    }
    input_broker_assets = {
        "BBG004S68B31": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG004S68B31": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'income',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 263.7,
        'datetime': "2021-11-05T06:00:00+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-05T06:00:00+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'dividend',
        'description': '',
        'source_account_uuid': '11111111-1111-1111-1111-111111111111',
    }


def test_parse_transaction_tax_dividend() -> None:
    input_broker_operation = {
        "operationType": "TaxDividend",
        "date": "2021-11-05T06:00:00+03:00",
        "isMarginCall": False,
        "instrumentType": "Stock",
        "figi": "BBG004S68B31",
        "payment": -32,
        "currency": "RUB",
        "status": "Done",
        "id": "1841615748"
    }
    input_broker_assets = {
        "BBG004S68B31": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG004S68B31": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'outcome',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 32,
        'datetime': "2021-11-05T06:00:00+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-05T06:00:00+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'tax',
        'description': '',
        'source_account_uuid': '11111111-1111-1111-1111-111111111111',
    }


def test_parse_transaction_service_commission() -> None:
    input_broker_operation = {
        "operationType": "ServiceCommission",
        "date": "2021-11-10T20:35:26+03:00",
        "isMarginCall": False,
        "payment": -2.9E+2,
        "currency": "RUB",
        "status": "Done",
        "id": "1876222841"
    }
    input_broker_assets = {}
    input_broker_accounts = {}
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'outcome',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 2.9E+2,
        'datetime': "2021-11-10T20:35:26+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-10T20:35:26+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'commission',
        'description': '',
        'source_account_uuid': None,
    }


def test_parse_transaction_pay_in() -> None:
    input_broker_operation = {
        "operationType": "PayIn",
        "date": "2021-11-10T20:29:09+03:00",
        "isMarginCall": False,
        "payment": 869.72,
        "currency": "RUB",
        "status": "Done",
        "id": "1876201873"
    }
    input_broker_assets = {}
    input_broker_accounts = {}
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'income',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 869.72,
        'datetime': "2021-11-10T20:29:09+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-11-10T20:29:09+03:00",
        'asset_from_uuid': '2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 1,
    }
    del event['uuid']
    assert event == {
        'type': 'other',
        'description': '',
        'source_account_uuid': None,
    }


def test_parse_transaction_sell() -> None:
    input_broker_operation = {
        "operationType": "Sell",
        "date": "2021-12-07T15:34:37.245+03:00",
        "isMarginCall": False,
        "instrumentType": "Bond",
        "figi": "BBG00FJV9WC4",
        "quantity": 1,
        "quantityExecuted": 1,
        "price": 801.52,
        "payment": 820.37,
        "currency": "RUB",
        "commission": {
            "currency": "RUB",
            "value": -0.32
        },
        "trades": [
            {
                "tradeId": "4730485875",
                "date": "2021-12-07T15:34:37.245+03:00",
                "quantity": 1,
                "price": 801.52
            }
        ],
        "status": "Done",
        "id": "27942700107"
    }

    input_broker_assets = {
        "BBG00FJV9WC4": {
            "uuid": '00000000-0000-0000-0000-000000000000'
        }
    }
    input_broker_accounts = {
        "BBG00FJV9WC4": {
            "uuid": '11111111-1111-1111-1111-111111111111'
        }
    }
    transaction, exchange_rate, event = parse_transaction(input_broker_operation, input_broker_assets,
                                                          input_broker_accounts)
    del transaction['uuid']
    assert transaction == {
        'operation': 'income',
        'event_uuid': event['uuid'],
        'account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111',
        'quantity': 1,
        'datetime': "2021-12-07T15:34:37.245+03:00",
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    del exchange_rate['uuid']
    assert exchange_rate == {
        'datetime': "2021-12-07T15:34:37.245+03:00",
        'asset_from_uuid': '00000000-0000-0000-0000-000000000000',
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': 801.52,
    }
    del event['uuid']
    assert event == {
        'type': 'sell',
        'description': '',
        'source_account_uuid': '11111111-1111-1111-1111-111111111111',
    }
