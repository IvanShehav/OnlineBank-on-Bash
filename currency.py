import requests
import time
from datetime import datetime

def currency():
    timenow = datetime.now().strftime("%H:%M:%S")
    url = 'https://api.exchangerate-api.com/v4/latest/RUB'
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        rates = data['rates']
        usd_rate = rates.get('USD')
        eur_rate = rates.get('EUR')
        cny_rate = rates.get('CNY')
        print(f"{timenow} - 1 USD стоит: {1/usd_rate:.2f} RUB")
        print(f"{timenow} - 1 EUR стоит: {1/eur_rate:.2f} RUB")
        print(f"{timenow} - 1 CNY стоит: {1/cny_rate:.2f} RUB")
    else:
        print("Ошибка при получении курсов валют")
    time.sleep(3)
if __name__ == "__main__":
    currency()
