import json
import uuid


def get_asset_type_from_broker_type(broker_asset_type: str) -> str | None:
    broker_asset_types_map = {
        'Bond': 'bond',
        'Stock': 'stock',
        'Etf': 'etf',
        'Currency': 'currency'
    }
    if broker_asset_type not in broker_asset_types_map:
        return None
    return broker_asset_types_map[broker_asset_type]


def create_asset(asset_type: str, ticker: str, figi: str, isin: str, name: str):
    return {
        'uuid': str(uuid.uuid4()),
        'asset_type': asset_type,
        'ticker': ticker,
        'figi': figi,
        'isin': isin,
        'name': name,
        'description': None,
        'created': None,
        'updated': None,
    }


def create_account_for_asset(asset_uuid: str) -> dict:
    return {
        'uuid': str(uuid.uuid4()),
        'asset_uuid': asset_uuid,
    }


def parse_assets(json_data: json) -> (dict, dict):
    assets = {}
    accounts = {}
    for broker_asset in json_data['payload']['instruments']:
        parsed_asset = create_asset(
            asset_type=get_asset_type_from_broker_type(broker_asset['type']),
            ticker=broker_asset['ticker'],
            figi=broker_asset['figi'],
            isin=broker_asset['isin'],
            name=broker_asset['name']
        )
        assets[parsed_asset['figi']] = parsed_asset
        accounts[parsed_asset['figi']] = create_account_for_asset(parsed_asset['uuid'])
    return assets, accounts


def get_transaction_type_from_broker_operation_type(broker_operation_type: str) -> str | None:
    broker_operation_types_map = {
        'Buy': 'outcome',
        'BuyCard': 'outcome',
        'Sell': 'income',
        'BrokerCommission': 'outcome',
        'ExchangeCommission': 'outcome',
        'ServiceCommission': 'outcome',
        'MarginCommission': 'outcome',
        'OtherCommission': 'outcome',
        'PayIn': 'income',
        'PayOut': 'outcome',
        'Tax': 'outcome',
        'TaxLucre': 'outcome',
        'TaxDividend': 'outcome',
        'TaxCoupon': 'outcome',
        'TaxBack': 'outcome',
        'Repayment': 'outcome',
        'PartRepayment': 'income',
        'Coupon': 'income',
        'Dividend': 'income',
        'SecurityIn': 'income',
        'SecurityOut': 'outcome'
    }
    if broker_operation_type not in broker_operation_types_map:
        return None
    return broker_operation_types_map[broker_operation_type]


def get_event_type_from_broker_operation_type(broker_operation_type: str) -> str | None:
    broker_operation_types_map = {
        'Buy': 'buy',
        'BuyCard': 'buy',
        'Sell': 'sell',
        'BrokerCommission': 'commission',
        'ExchangeCommission': 'commission',
        'ServiceCommission': 'commission',
        'MarginCommission': 'commission',
        'OtherCommission': 'commission',
        'PayIn': 'other',
        'PayOut': 'other',
        'Tax': 'tax',
        'TaxLucre': 'tax',
        'TaxDividend': 'tax',
        'TaxCoupon': 'tax',
        'TaxBack': 'tax',
        'Repayment': 'other',
        'PartRepayment': 'other',
        'Coupon': 'coupon',
        'Dividend': 'dividend',
        'SecurityIn': 'other',
        'SecurityOut': 'other'
    }
    if broker_operation_type not in broker_operation_types_map:
        return None
    return broker_operation_types_map[broker_operation_type]


def parse_transaction(broker_operation: dict, assets: dict, accounts: dict) -> (dict, dict, dict):
    if broker_operation['operationType'] == 'Buy':
        return parse_transaction_buy(
            broker_operation=broker_operation,
            assets=assets, accounts=accounts,
            source_account_uuid='8d8fde97-d609-4d0f-bed5-73d1a91d1111', # TODO tech: remove hardcode it's the asset bank account
            asset_to_uuid='2689e5ba-c736-4596-874e-9c5e5b91e5fa'  # TODO tech: remove hardcode it's currency RUB asset
        )
    if broker_operation['operationType'] in ['BrokerCommission', 'Coupon', 'PartRepayment', 'Dividend', 'TaxDividend']:
        return parse_transaction_additional_with_source(
            broker_operation=broker_operation,
            accounts=accounts,
            asset_from_uuid='2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',  # TODO tech: remove hardcode it's the bank asset account
            asset_to_uuid='2689e5ba-c736-4596-874e-9c5e5b91e5fa',  # TODO tech: remove hardcode it's currency RUB asset
            exchange_rate_value=1,  # TODO tech: remove hardcode it's currency RUB asset
            account_uuid='8d8fde97-d609-4d0f-bed5-73d1a91d1111',  # TODO tech: remove hardcode account
        )
    if broker_operation['operationType'] in ['ServiceCommission', 'PayIn']:
        return parse_transaction_additional_without_source(
            broker_operation=broker_operation,
            asset_from_uuid='2dee7cdb-0b00-4bc8-b0ab-e05a060522cc',  # TODO tech: remove hardcode it's the bank asset account
            asset_to_uuid='2689e5ba-c736-4596-874e-9c5e5b91e5fa',  # TODO tech: remove hardcode it's currency RUB asset
            exchange_rate_value=1,  # TODO tech: remove hardcode it's currency RUB asset
            account_uuid='8d8fde97-d609-4d0f-bed5-73d1a91d1111',  # TODO tech: remove hardcode account
        )

    # TODO custom exception
    raise Exception('Unexpected operation type=[' + broker_operation['operationType'] + ']')


def create_event(event_type: str, source_account_uuid: str | None):
    event = {
        'uuid': str(uuid.uuid4()),
        'type': event_type,
        'description': '',
        'source_account_uuid': source_account_uuid,
    }
    return event


def create_exchange_rate(datetime: str, asset_from_uuid: str, asset_to_uuid: str, exchange_rate_value: int):
    exchange_rate = {
        'uuid': str(uuid.uuid4()),
        'datetime': datetime,
        'asset_from_uuid': asset_from_uuid,
        'asset_to_uuid': asset_to_uuid,
        'exchange_rate_value': exchange_rate_value,
    }
    return exchange_rate


def create_transaction(transaction_type: str, event_uuid: str, account_uuid: str, quantity: int, datetime: str,
                       exchange_rate_uuid: str):
    transaction = {
        'uuid': str(uuid.uuid4()),
        'operation': transaction_type,
        'event_uuid': event_uuid,
        'account_uuid': account_uuid,
        'quantity': quantity,
        'datetime': datetime,
        'exchange_rate_uuid': exchange_rate_uuid,
    }
    return transaction


def parse_transaction_buy(broker_operation: dict, assets: dict, accounts: dict, source_account_uuid: str,
                          asset_to_uuid: str) -> (dict, dict, dict):
    transaction_type = get_transaction_type_from_broker_operation_type(broker_operation['operationType'])
    event = create_event(
        event_type=get_event_type_from_broker_operation_type(broker_operation['operationType']),
        source_account_uuid=source_account_uuid
    )

    exchange_rate = create_exchange_rate(
        datetime=broker_operation['date'],
        asset_from_uuid=assets[broker_operation['figi']]['uuid'],
        asset_to_uuid=asset_to_uuid,
        exchange_rate_value=broker_operation['price']
    )

    transaction = create_transaction(
        transaction_type=transaction_type,
        event_uuid=event['uuid'],
        account_uuid=accounts[broker_operation['figi']]['uuid'],
        quantity=broker_operation['quantity'],
        datetime=broker_operation['date'],
        exchange_rate_uuid=exchange_rate['uuid']
    )
    return transaction, exchange_rate, event


def parse_transaction_additional_with_source(broker_operation: dict, accounts: dict, asset_from_uuid: str,
                                             asset_to_uuid: str, exchange_rate_value: int, account_uuid: str) -> \
    (dict, dict, dict):
    transaction_type = get_transaction_type_from_broker_operation_type(broker_operation['operationType'])
    event_type = get_event_type_from_broker_operation_type(broker_operation['operationType'])
    event = create_event(
        event_type=event_type,
        source_account_uuid=accounts[broker_operation['figi']]['uuid']
    )

    exchange_rate = create_exchange_rate(
        datetime=broker_operation['date'],
        asset_from_uuid=asset_from_uuid,
        asset_to_uuid=asset_to_uuid,
        exchange_rate_value=exchange_rate_value
    )

    transaction = create_transaction(
        transaction_type=transaction_type,
        event_uuid=event['uuid'],
        account_uuid=account_uuid,
        quantity=abs(broker_operation['payment']),
        datetime=broker_operation['date'],
        exchange_rate_uuid=exchange_rate['uuid']
    )
    return transaction, exchange_rate, event


def parse_transaction_additional_without_source(broker_operation: dict, asset_from_uuid: str, asset_to_uuid: str,
                                                exchange_rate_value: int, account_uuid: str) -> (dict, dict, dict):
    transaction_type = get_transaction_type_from_broker_operation_type(broker_operation['operationType'])
    event = create_event(
        event_type=get_event_type_from_broker_operation_type(broker_operation['operationType']),
        source_account_uuid=None
    )

    exchange_rate = create_exchange_rate(
        datetime=broker_operation['date'],
        asset_from_uuid=asset_from_uuid,
        asset_to_uuid=asset_to_uuid,
        exchange_rate_value=exchange_rate_value,
    )

    transaction = create_transaction(
        transaction_type=transaction_type,
        event_uuid=event['uuid'],
        account_uuid=account_uuid,
        quantity=abs(broker_operation['payment']),
        datetime=broker_operation['date'],
        exchange_rate_uuid=exchange_rate['uuid']
    )
    return transaction, exchange_rate, event


def parse_transactions(json_data: json, assets: dict, accounts: dict) -> (dict, dict, dict):
    events = {}
    exchange_rates = {}
    transactions = {}
    for broker_transaction in json_data['payload']['operations']:
        parsed_transaction, er, e = parse_transaction(broker_transaction, assets, accounts)
        transactions[broker_transaction['id']] = parsed_transaction
        exchange_rates[broker_transaction['id']] = er
        events[broker_transaction['id']] = e

    return transactions, exchange_rates, events
