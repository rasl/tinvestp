import pytest
from updater.broker.tinkoff.parser import parse_asset, get_asset_type_from_broker_type


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
def test_parse_asset(input: dict, expected_result: dict) -> None:
    actual_result = parse_asset(input)
    del actual_result['uuid']
    del actual_result['created']
    del actual_result['updated']
    assert actual_result == expected_result
