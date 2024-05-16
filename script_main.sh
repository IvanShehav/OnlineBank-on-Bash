#!/bin/bash
. ./functions.sh

ErrorInput="Опция выбрана некорректно. Попробуйте еще раз." #ошибка при выбое неверной функции в case

#логика  входа
echo "Добро пожаловать в онлайн-банк "Сириус"!"
echo "1. Зарегистрироваться"
echo "2. Авторизироваться"

read -p "Выберите действие (1/2): " options

case $options in 
    1 ) register ;;
    2 ) login
        username=$username 
        ;;
    * ) echo "Введен некорректный пункт. Попробуйте еще раз." ;;
esac



while True
do
    sleep 1.5
    echo
    echo "Список опций:"
    echo "1. Мой счет"
    echo "2. Траты"
    echo "3. Вклады"
    echo "4. Кредиты"
    echo "5. Брокерский счет"
    echo "6. Курсы валют"
    echo "7. Выйти"

    read -p "Пожалуйста, выберите необходимый пункт: " options
    echo

    case "$options" in
        1 ) echo "1. Информация о счете"
            echo "2. Указать пополнение"
            echo "3. Выйти"
            read -p "Выберите опцию: " choice
            echo

            case "$choice" in
                1) 
                echo "============================================"
                cat DataBase/$username/account.txt
                echo "============================================"
                ;;
                2) 
                read -p "Введите сумму: " count
                balance=$(grep "Баланс:" DataBase/$username/account.txt | cut -d ":" -f 2 | tr -d '[:space:]')
                new_balance=$((balance + count))
                sed -i "s/Баланс: $balance/Баланс: $new_balance/" DataBase/$username/account.txt
                echo "Баланс успешно обновлен."
                ;;
                3) continue
                ;;
                *) echo $ErrorInput
                ;;
            esac
        ;;
        2 ) echo "1. Записать траты"
            echo "2. Посмотреть траты"
            echo "3. Построить график расходов"
            echo "4. Удалить траты"
            echo "5. Выйти"
            read -p "Выберите опцию: " choice
            echo

            case "$choice" in
                1) write_expense
                ;;
                2) read_expense
                ;;
                3) graph_expenses
                ;;
                4) delete_expense
                ;;
                5) continue
                ;;
                *) echo $ErrorInput
                ;;
            esac
        ;;
        3 ) bankDeposit
        ;;
        4 ) bankCredit
        ;;
        5 ) testFunctionPy
        ;;
        6 ) currency
        ;;
        7 )
        echo "До свидания, $username!"
        exit 0
        ;;
        * ) echo $ErrorInput $'\n'
        ;;
    esac

done


