import pytest
from updater.broker.tinkoff.parser import parse_asset


@pytest.mark.parametrize(
    'input, expected_result',
    [
        (
            {
                "figi": "BBG00T22WKV5",
                "ticker": "SU29013RMFS8",
                "isin": "RU000A101KT1",
                "minPriceIncrement": 0.01,
                "faceValue": 1E+3,
                "lot": 1,
                "currency": "RUB",
                "name": "ОФЗ 29013",
                "type": "Bond"
            },
            {
                'asset_type': 'bond',
                'ticker': 'SU29013RMFS8',
                'figi': 'BBG00T22WKV5',
                'isin': 'RU000A101KT1',
                'name': 'ОФЗ 29013',
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
