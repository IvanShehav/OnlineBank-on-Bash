# #!/bin/bash

# #функция для авторизации пользователя
# function login() {
#     if [[ ! -s 'users.txt' ]]  #-s ключ на проверку пустоты файла
#     then
#         echo "Еще ни один пользователь не зарегистрирован."
#         exit 1
#     fi

#     read -p "Введите имя пользователя: " username
#     read -s -p "Введите пароль: " password 
#     echo 

#     if grep -q "$username:$password" users.txt
#     then
#         timeFunction
#         echo "Добро пожаловать в систему, $username."
#     elif ! grep -q "$username" users.txt
#     then
#         echo "Такого пользователя не существует."
#         echo "Пожалуйста, пройдите процедуру регистрации"
#         exit 1
#     else
#         echo "Неверное имя пользователя или пароль."
#         login
#     fi
# }

# login


# #функция для регистрации нового пользователя
# function register() {
#     #проверка на наличие файла
#     if [[ ! -e "$users.txt" ]]
#     then
#         touch users.txt
#     fi

#     read -p "Введите имя нового пользователя: " new_username

#     if grep -q "$new_username:" users.txt
#     then
#         echo "Пользователь с таким именем уже существует."
#         echo "Пожалуйста, придумайте другое имя пользователя."
#         echo 
#         register
#     else
#         read -p "Введите пароль: " new_password
#         echo "$new_username:$new_password" >> users.txt
#         mkdir "DataBase/$new_username"
#         touch "DataBase/$new_username/transactions.txt"
#         echo "Пользователь $new_username успешно зарегистрирован."
#     fi
# }

# register

# ErrorInput="Опция выбрана некорректно. Попробуйте еще раз."
# #меню с основным функционалом
# while True
# do
#     balans=0 #баланс пользователя


#     echo "Список опций:"
#     echo "1. Мой счет"
#     echo "2. Траты"
#     echo "3. Вклады"
#     echo "4. Кредиты"
#     echo "5. Брокерский счет"
#     echo "6. Курсы валют"
#     echo "7. Выйти"

#     read -p "Пожалуйста, выберите необходимый пункт: " options

#     case "$options" in
#         1 ) echo "1. Информация о счете"
#             echo "2. Указать пополнение"
#             echo "3. Выйти"
#             read -p "Выберите опцию: " choice

#             case "$choice" in
#                 1)
#                 ;;
#                 2)
#                 ;;
#                 3) continue
#                 ;;
#                 *) echo $ErrorInput $'\n'
#                 ;;
#             esac
#         ;;
#         2 ) 
#         echo "two"
#         ;;
#         3 ) 
#         echo "three"
#         ;;
#         4 ) 
#         echo "four"
#         ;;
#         5 ) 
#         echo "five"
#         ;;
#         6 ) 
#         echo "six"
#         ;;
#         7 )
#         exit 0
#         ;;
#         * ) echo $ErrorInput $'\n'
#         ;;
#     esac

# done

function hash_password {
    echo $1 | sha256sum | awk '{print $1}'
}
hash_password