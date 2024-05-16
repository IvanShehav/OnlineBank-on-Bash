##вариант столбчатого графика
# import csv
# import matplotlib.pyplot as plt
# from datetime import datetime

# def plot_expenses_graph(filename):
#     # Загрузка данных из CSV файла
#     with open(filename, 'r') as file:
#         reader = csv.reader(file)
#         dates, amounts = [], []
#         for row in reader:
#             try:
#                 date, amount = row
#                 dates.append(datetime.strptime(date, '%d.%m.%Y'))
#                 amounts.append(int(amount.replace(',','')))
#             except ValueError:
#                 pass

#     # Создание графика
#     fig, ax = plt.subplots(figsize=(12, 6))
#     ax.bar(dates, amounts)
#     ax.set_title('Ваши траты')
#     ax.set_xlabel('Дата')
#     ax.set_ylabel('Сумма')
#     ax.grid(True)

#     # Показ графика
#     plt.show()

# if __name__ == "__main__":
#     import sys
#     # Получаем путь к файлу из аргументов командной строки
#     filename = sys.argv[1]
#     plot_expenses_graph(filename)


import csv
import matplotlib.pyplot as plt
from datetime import datetime

def plot_expenses_graph(filename):
    # Загрузка данных из CSV файла
    with open(filename, 'r') as file:
        reader = csv.reader(file)
        dates, amounts = [], []
        for row in reader:
            try:
                date, amount = row
                dates.append(datetime.strptime(date, '%d.%m.%Y'))
                amounts.append(int(amount.replace(',', '')))
            except ValueError:
                pass

    # Создание графика
    fig, ax = plt.subplots(figsize=(12, 6))  # Задаем размер окна
    ax.plot(dates, amounts, marker='o', linestyle='-', color='b')  # Линейный график
    ax.set_title('Ваши траты')
    ax.set_xlabel('Дата')
    ax.set_ylabel('Сумма')
    ax.grid(True)

    # Показ графика
    plt.show()

if __name__ == "__main__":
    import sys
    # Получаем путь к файлу из аргументов командной строки
    filename = sys.argv[1]
    plot_expenses_graph(filename)

