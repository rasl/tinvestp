import updater.broker.tinkoff.parser as parser
import json
import csv


def load_json_from_file(file_name: str) -> dict:
    with open(file_name) as f:
        return json.load(f)


def save_list_to_csv(file_name: str, dictionary: dict) -> None:
    items_list = list(dictionary.values())
    headers = items_list[0].keys()
    with open(file_name, 'w') as csv_file:
        writer = csv.DictWriter(csv_file, fieldnames=headers)
        writer.writeheader()
        writer.writerows(items_list)


def main():
    work_dir = 'db/sample/broker/tinkoff/'  # TODO tech: remove
    assets = {}
    accounts = {}
    for file in [
        work_dir + 'market_stocks.json',
        work_dir + 'market_bonds.json',
        work_dir + 'market_etfs.json'
    ]:
        json_data = load_json_from_file(file)
        c_assets, c_accounts = parser.parse_assets(json_data)
        assets |= c_assets
        accounts |= c_accounts

    save_list_to_csv(work_dir + 'assets.csv', assets)
    save_list_to_csv(work_dir + 'accounts.csv', accounts)

    json_data = load_json_from_file(work_dir + 'transactions.json')
    transactions, exchange_rates, events = parser.parse_transactions(json_data, assets, accounts)
    save_list_to_csv(work_dir + 'events.csv', events)
    save_list_to_csv(work_dir + 'exchange_rates.csv', exchange_rates)
    save_list_to_csv(work_dir + 'transactions.csv', transactions)


if __name__ == '__main__':
    main()
