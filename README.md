# CRACK
## _Общее описание проекта CRACK_
1  Программа Crack выводит приглашение на ввод пароля.

2  Пользователю необходимо ввести с клавиатуры пароль, состоящий из 5 симвлов.

3 В зависимости от введенного значения на экран выводится фраза: "Access to info is open/closed!"

![](RM1.png)


## _Функция TakeSyms_

#### Описание:
Эта функция принимает ASCII коды символов, введенных пользователем с клавиатуры и записывает их в массив EntrPswdBuf.


#### Используемые регистры:
bx - адресс первой ячейки массива EntrPswdBuf.

al - ASCII код последнего введенного символа.


#### Сторонние символы:
 '$' - символ, после которого завершается прием пароля.


## _Функция PutRefPswd_

#### Описание:
Эта функция записывает в неиспользуемую паролем област массива EntrPswdBuf полученный hash верного пароля.


#### Используемые регистры:
si - адресс свободной для записи области массива EntrPswdBuf.


## _TakeRefPswd_

#### Описание:
Эта функция принимает из массива референсное значение hash-а пароля посимвольно и соединяет его в hex число.

#### Используемые регистры:
si - адресс свободной для записи области массива EntrPswdBuf.

dh - старший элемент значения пароля.

dl - младший элемент значения пароля.

cl - разряд системы счисления.


#### Возвращаемое значение:
dl - значение hash-а референсного значения в шестнадцатиричной системе счисления.


## _Hash_

#### Описание:
Эта функция определенным алгоритмом преобразует введенный пароль в hash значение.


#### Используемые регистры:
si - адресс первой ячейки массива EntrPswdBuf.

dl/cl - ASCII коды символов с буфера с паролем.

ax - константа hash-а.


#### Возвращаемое значение:
ax - захэшированный код пароля.


## _Описание уязвимости_

Не происходит проверка числа вводимых символов, из-за этого пользователь может перднамеренно переполнить буфер с паролем и референсным значением и перезаписать область с правильным паролем.


# Уязвимости в программе опонента.
## _Первая уязвимость_
#### Описание:
Когда программа вызывает функцию считывания пароля с клавиатуры при вводе $ меняется значение нудевой константы.
``` asm
        mov     [si+463h], al       ; al - хранит ASCII-код символа введенного с клавиатуры.
        inc     si
        cmp     al, 24h             ; 24h - ASCII-код '$'.
        jnz     short loc_10165
        mov     byte_10462, 0FFh    ; byte_10462 = FFh
```
Из-за чего, когда программа передает управление функции проверки пароля, она сравнивает значение этой константы, с нулем и при неравенстве открывает доступ.
``` asm
        cmp     byte_10462, 0       ; поверяет ввел ли пользователь символ '$'
        jne     loc_1013B     ; при введенном '$' функция перебрасывает ход программы на метку loc_1013B,       которая открывает доступ.
```














