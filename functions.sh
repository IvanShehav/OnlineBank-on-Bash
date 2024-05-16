#!/bin/bash

#функция определения времени суток
function timeFunction() {
    time=$(date +%H:%M:%S)
    if [[ $time > "05:00:00" && $time < "12:00:00" ]]
    then
        echo "Доброе утро!"
    elif [[ $time > "12:00:00" && $time < "18:00:00" ]]
    then
        echo "Добрый день!"
    elif [[ $time > "18:00:00" && $time < "23:00:00" ]]
    then
        echo "Добрый вечер!"
    elif [[ ($time > "23:00:00" && $time < "24:00:00") || ($time > "00:00:00" && $time < "05:00:00") ]]
    then
        echo "Доброй ночи!"
    fi
}


#функция для авторизации пользователя
function login() {
    if [[ ! -s 'users.txt' ]]  #-s ключ на проверку пустоты файла
    then
        echo "Еще ни один пользователь не зарегистрирован."
        echo
        exit 0
    fi

    echo 
    echo "=======Авторизация======="
    read -p "Введите имя пользователя: " username
    read -s -p "Введите пароль: " password 
    echo 

    if grep -q "$username:$(hash_password $password)" users.txt
    then
        echo
        timeFunction
        echo "Добро пожаловать в систему, $username."

        DataBaseDirection="DataBase/$username"
    elif ! grep -q "$username" users.txt
    then
        echo
        echo "Такого пользователя не существует."
        echo "Пожалуйста, пройдите процедуру регистрации."
        echo
        register
    else
        echo
        echo "Неверное имя пользователя или пароль."
        exit 1
    fi
}


#функция для регистрации нового пользователя
function register() {

    balance=0 #баланс пользователя

    #проверка на наличие файла
    if [[ ! -e "users.txt" ]]
    then
        touch users.txt
    fi
    echo
    echo "=======Регистрация======="
    read -p "Введите имя нового пользователя: " new_username

    if grep -q "$new_username:" users.txt
    then
        echo "Пользователь с таким именем уже существует."
        echo "Пожалуйста, придумайте другое имя пользователя."
        echo 
        register
    else
        read -p "Введите пароль: " new_password
        echo "$new_username:$(hash_password $new_password)" >> users.txt
        mkdir "DataBase/$new_username"
        touch "DataBase/$new_username/transactions.txt"
        touch "DataBase/$new_username/account.txt"
        echo "Имя пользователя: $new_username" >> DataBase/"$new_username"/account.txt
        echo "Баланс: $balance" >> DataBase/"$new_username"/account.txt
        generate_account_number
        echo "Номер счета: $account_number" >> DataBase/"$new_username"/account.txt
        echo "Дата регистрации: $(date +%d.%m.%Y" "%H:%M)" >> DataBase/"$new_username"/account.txt
        echo
        echo "Пользователь $new_username успешно зарегистрирован."
    fi

    login
}


#функция хеширования
function hash_password {
    echo $1 | sha512sum | awk '{print $1}'
}


#функция генерации номера счета
generate_account_number() {
    account_number=""
    for ((i=1; i<=16; i++))
    do
        random_digit=$((RANDOM % 10))
        account_number="${account_number}${random_digit}"
    done

    if [[ ! -e "account_number.txt" ]]
    then
        touch account_number.txt
    fi 

    if grep -q "$account_number" account_number.txt
    then
        generate_account_number
    else
        echo $account_number >> account_number.txt
    fi
}


#функция записи трат
function write_expense() {
    read -p "Выберите катеорию трат: " category
    read -p "Введите сумму: " amount

    echo "$(date +%d.%m.%Y) - $category: $amount" >> $DataBaseDirection/transactions.txt
    balance=$(grep "Баланс:" $DataBaseDirection/account.txt | cut -d ":" -f 2 | tr -d '[:space:]')
    new_balance=$((balance - amount))
    sed -i "s/Баланс: $balance/Баланс: $new_balance/" $DataBaseDirection/account.txt
    echo
    echo "Баланс успешно обновлен."
    echo "Трата успешно записана."
}

#функция просмотра трат
function read_expense() {
    echo "==================================="
    echo "Ваши траты:"
    cat $DataBaseDirection/transactions.txt
    echo "==================================="
}

#функция удаления трат
function delete_expense() {
    echo "Введите номер строки, которую хотите удалить:"
    read line_number

    # Получаем сумму траты из указанной строки
    amount=$(sed -n "${line_number}p" "$DataBaseDirection/transactions.txt" | awk -F ': ' '{print $2}')

    if [[ $amount ]]
    then
        balance=$(grep "Баланс:" $DataBaseDirection/account.txt | cut -d ":" -f 2 | tr -d '[:space:]')
        new_balance=$((balance + amount))
        sed -i "s/Баланс: $balance/Баланс: $new_balance/" $DataBaseDirection/account.txt #обновление баланса
        sed -i "${line_number}d" $DataBaseDirection/transactions.txt # удаление строки
        echo
        echo "Трата успешно удалена."
        echo "Баланс успешно обновлен."
    else
        echo
        echo "Строки с таким номером не существует. Пожалуйста, выберите другой номер строки."
    fi
}


#функция открытия вклада
function bankDeposit() {
    #функция обновления баланса шоб не повторять
    function updateBalans() {
        balance=$(grep "Баланс:" $DataBaseDirection/account.txt | cut -d ":" -f 2 | tr -d '[:space:]')
        if [[ $count -gt $balance ]]
        then
            echo "Недостаточно средств."
        else
            new_balance=$((balance - count))
            sed -i "s/Баланс: $balance/Баланс: $new_balance/" $DataBaseDirection/account.txt #обновление баланса
            if [[ ! -e "$DataBaseDirection/deposit.txt" ]]
            then
                touch $DataBaseDirection/deposit.txt
            fi
            echo "Вклад: " >> "$DataBaseDirection/deposit.txt"
            case "$bank" in
                1) echo "Ответсвенное лицо: ПАО Сбербанк" >> "$DataBaseDirection/deposit.txt"
                ;;
                2) echo "Ответсвенное лицо: АО Тинькофф Банк" >> "$DataBaseDirection/deposit.txt"
                ;;
                3) echo "Ответсвенное лицо: ПАО Банк ВТБ" >> "$DataBaseDirection/deposit.txt"
                ;;
                4) echo "Ответсвенное лицо: ПАО МТС-банк" >> "$DataBaseDirection/deposit.txt"
                ;;
                5) echo "Ответсвенное лицо: АНО Сириус" >> "$DataBaseDirection/deposit.txt"
                ;;
            esac
            echo "Сумма: $count" >> "$DataBaseDirection/deposit.txt"
            echo " " >> "$DataBaseDirection/deposit.txt"

            echo
            echo "Вклад успешно создан."
            echo "Благодарим за доверие!"
        fi
    }

    echo "Список банков и условия вкладов: "
    echo "1. Сбербанк - 10% годовых, от 1 миллиона на 12 месяцев"
    echo "2. Тинькофф - 10% годовых, от 100 тысяч на 6 месяцев"
    echo "3. ВТБ - 11% годовых, от 30 тысяч на 24 месяца"
    echo "4. МТС - 7% годовых, от 10 тысяч на срок 3 месяца"
    echo "5. Сириус - 15% годовых, от 100 тысяч на срок 48 месяцев"
    echo "6. Выйти"
    read -p "Пожалуйста, выберите желаемый банк: " bank
    echo

    case "$bank" in
        1) echo "Выбранный банк: Сбербанк"
        read -p "Пожалуйста, введите желаемую сумму вклада: " count
        if [[ $count -ge 1000000 ]]
        then
            read -p "Вы собираетесь сделать вклад в размере: $count₽ под 10% годовых на 12 месяцев, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма вклада указана неверно."
        fi
        ;;
        2)
        echo "Выбранный банк: Тинькофф"
        read -p "Пожалуйста, введите желаемую сумму вклада: " count
        if [[ $count -ge 100000 ]]
        then
            read -p "Вы собираетесь сделать вклад в размере: $count₽ под 10% годовых на 6 месяцев, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма вклада указана неверно."
        fi
        ;;
        3) echo "Выбранный банк: ВТБ"
        read -p "Пожалуйста, введите желаемую сумму вклада: " count
        if [[ $count -ge 30000 ]]
        then
            read -p "Вы собираетесь сделать вклад в размере: $count₽ под 11% годовых на 24 месяца, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма вклада указана неверно."
        fi
        ;;
        4) echo "Выбранный банк: МТС"
        read -p "Пожалуйста, введите желаемую сумму вклада: " count
        if [[ $count -ge 10000 ]]
        then
            read -p "Вы собираетесь сделать вклад в размере: $count₽ под 7% годовых на 3 месяцев, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма вклада указана неверно."
        fi
        ;;
        5) echo "Выбранный банк: Сириус"
        read -p "Пожалуйста, введите желаемую сумму вклада: " count
        if [[ $count -ge 100000 ]]
        then
            read -p "Вы собираетесь сделать вклад в размере: $count₽ под 15% годовых на 48 месяцев, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма вклада указана неверно."
        fi
        ;;
        6) echo
        ;;
        *) echo $ErrorInput
        ;;
    esac
}


#функция взятия кредита
function bankCredit() {

    #функция обновления баланса шоб не повторять
    function updateBalans() {
        balance=$(grep "Баланс:" $DataBaseDirection/account.txt | cut -d ":" -f 2 | tr -d '[:space:]')
        new_balance=$((balance + count))
        sed -i "s/Баланс: $balance/Баланс: $new_balance/" $DataBaseDirection/account.txt #обновление баланса
        echo "Кредит успешно выдан."
    }

    echo "Список банков и условия кредитования: "
    echo "1. Сбербанк - 12% годовых, до 1 миллиона"
    echo "2. Тинькофф - 10% годовых, до 500 тысяч"
    echo "3. ВТБ - 11% годовых, до 300 тысяч"
    echo "4. МТС - 13% годовых, до 500 тысяч"
    echo "5. Сириус - 3% годовых, до 100 тысяч"
    echo "6. Выйти"
    read -p "Пожалуйста, выберите желаемый банк: " bank
    echo

    case "$bank" in
        1) echo "Выбранный банк: Сбербанк"
        read -p "Пожалуйста, введите желаемую сумму кредита: " count
        if [[ $count -le 1000000 ]] && [[ $count -gt 0 ]]
        then
            read -p "Вы собираетесь взять кредит на сумму: $count₽ под 12% годовых, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма кредита указана неверно."
        fi
        ;;
        2)
        echo "Выбранный банк: Тинькофф"
        read -p "Пожалуйста, введите желаемую сумму кредита: " count
        if [[ $count -le 500000 ]] && [[ $count -gt 0 ]]
        then
            read -p "Вы собираетесь взять кредит на сумму: $count₽ под 10% годовых, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма кредита указана неверно."
        fi
        ;;
        3) echo "Выбранный банк: ВТБ"
        read -p "Пожалуйста, введите желаемую сумму кредита: " count
        if [[ $count -le 300000 ]] && [[ $count -gt 0 ]]
        then
            read -p "Вы собираетесь взять кредит на сумму: $count₽ под 11% годовых, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма кредита указана неверно."
        fi
        ;;
        4) echo "Выбранный банк: МТС"
        read -p "Пожалуйста, введите желаемую сумму кредита: " count
        if [[ $count -le 500000 ]] && [[ $count -gt 0 ]]
        then
            read -p "Вы собираетесь взять кредит на сумму: $count₽ под 13% годовых, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма кредита указана неверно."
        fi
        ;;
        5) echo "Выбранный банк: Сириус"
        read -p "Пожалуйста, введите желаемую сумму кредита: " count
        if [[ $count -le 100000 ]] && [[ $count -gt 0 ]]
        then
            read -p "Вы собираетесь взять кредит на сумму: $count₽ под 3% годовых, верно? (Y/N): " answer
            if [[ $answer == "Y" ]]
            then
                updateBalans
            elif [[ $answer == "N" ]]
            then
                echo "Рады были помочь!"
            else
                echo "Ответ введен некорректно."
            fi
        else 
            echo "Сумма кредита указана неверно."
        fi
        ;;
        6) echo
        ;;
        *) echo $ErrorInput
        ;;
    esac
}


#функция курса валют
function currency() {
    echo "Загружаем актуальные курсы валют..."
    sleep 0.5
    python3 currency.py
}


#функция по работе с python
function testFunctionPy() {
python3 - <<END
print("В разработке...")
END
}

#функция построение графика расходов
function graph_expenses() {
    fileName="$DataBaseDirection/transactions.txt"

    echo -n "" > $DataBaseDirection/expenses.csv
    # Разделяем строку на дату и сумму
    while IFS= read -r line
    do
        # Разделяем строку на дату и сумму
        IFS=' ' read -ra arr <<< "${line}"
        date="${arr[0]}"
        category="${arr[2]}"
        amount="${arr[3]}"
        
        # Суммируем траты за каждый день
        if grep -q "^${date}," $DataBaseDirection/expenses.csv
        then
            total=$(awk -v date="${date}" -F, '$1==date {total+=$2} END {print total}' $DataBaseDirection/expenses.csv)
            sed -i "s/^${date}.*/${date},$((total+amount))/" $DataBaseDirection/expenses.csv
        else
            echo "${date},${amount}" >> $DataBaseDirection/expenses.csv
        fi
    done < "$fileName"

    python3 graph.py "$DataBaseDirection/expenses.csv"
}

