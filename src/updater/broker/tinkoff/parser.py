import json
import uuid


def parse_asset(broker_item: dict) -> dict:
    asset_type = str(broker_item['type']).lower()
    if asset_type not in ['bond', 'stock', 'etf', 'deposit', 'currency', 'cash', 'value', 'bank account', 'other']:
        asset_type = 'other'
    return {
        'uuid': str(uuid.uuid4()),
        'asset_type': asset_type,
        'ticker': broker_item['ticker'],
        'figi': broker_item['figi'],
        'isin': broker_item['isin'],
        'name': broker_item['name'],
        'description': None,
        'created': None,
        'updated': None,
    }


def create_account_for_asset(asset: dict) -> dict:
    return {
        'uuid': str(uuid.uuid4()),
        'asset_uuid': asset['uuid'],
    }


# TODO technical: unit tests
def parse_assets(json_data: json) -> (dict, dict):
    assets = {}
    accounts = {}
    for broker_asset in json_data['payload']['instruments']:
        parsed_asset = parse_asset(broker_asset)
        assets[parsed_asset['figi']] = parsed_asset
        accounts[parsed_asset['figi']] = create_account_for_asset(parsed_asset)
    return assets, accounts


# TODO technical: unit tests
def parse_transaction(broker_operation: dict, assets: dict, accounts: dict) -> (dict, dict, dict):
    transaction_type = None
    if broker_operation['operationType'] in ['Coupon', 'PartRepayment', 'PayIn', 'Dividend']:
        transaction_type = 'income'
    if broker_operation['operationType'] in ['BrokerCommission', 'Buy', 'ServiceCommission', 'TaxDividend']:
        transaction_type = 'outcome'

    event = {
        'uuid': str(uuid.uuid4()),
        'type': 'buy',  # 'sell', 'buy', 'interest', 'dividends', 'coupons', 'tax', 'commission', 'other'
        'description': '',
        'source_account_uuid': '8d8fde97-d609-4d0f-bed5-73d1a91d1111'
    }

    exchange_rate = {
        'uuid': str(uuid.uuid4()),
        'datetime': broker_operation['date'],
        'asset_from_uuid': assets[broker_operation['figi']]['uuid'],
        'asset_to_uuid': '2689e5ba-c736-4596-874e-9c5e5b91e5fa',
        'exchange_rate_value': broker_operation['price'],
    }

    transaction = {
        'uuid': str(uuid.uuid4()),
        'operation': transaction_type,
        'event_uuid': event['uuid'],
        'account_id': accounts[broker_operation['figi']]['uuid'],
        'quantity': broker_operation['quantity'],
        'datetime': broker_operation['date'],
        'exchange_rate_uuid': exchange_rate['uuid'],
    }
    return transaction, exchange_rate, event


def parse_transactions(json_data: json, assets: dict, accounts: dict) -> (dict, dict, dict):
    events = {}
    exchange_rates = {}
    transactions = {}
    for broker_transaction in json_data['payload']['operations']:
        if broker_transaction['operationType'] != 'Buy':  # TODO technical: other types
            continue
        parsed_transaction, er, e = parse_transaction(broker_transaction, assets, accounts)
        transactions[broker_transaction['id']] = parsed_transaction
        exchange_rates[broker_transaction['id']] = er
        events[broker_transaction['id']] = e

    return transactions, exchange_rates, events
