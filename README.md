# CRACK
## _Общее описание проекта CRACK_
1  Программа Crack выводит приглашение на ввод пароля.

2  Пользователю необходимо ввести с клавиатуры пароль, состоящий из 5 симвлов.

3 В зависимости от введенного значения на экран выводится фраза: "Access to info is open/closed!"

![](https://github.com/Pave2005/imgs/blob/main/RM1.png)


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
        jne     loc_1013B           ; при введенном '$' функция переходит на метку loc_1013B.
                                    ; за меткой loc_1013B межит программа, которая открывает доступ.
```
#### Вывод:
При вводе пароля можно нажать '$' и так пользователь смжет обойти систему проверки.
## _Вторая уязвимость_
#### Описание:
Закодированные символы исходного пароля хранятся в открытом доступе в буффере byte_10462.
``` asm
byte_10462      db 0
                db 10h dup(0), 57h, 54h, 46h, 57h, 54h, 46h, 57h, 54h
                db 46h, 0
```
Начиная с ячейки со значением 57h хранятся закодированные ASCII-коды исходного пароля.
При этом функция хэширования устроена так, что она прогоняет через себя каждый символ по отдельности и на выходе уже получает реальный смвол пароля.
``` asm
        mov     al, [si+473h]   ; в ячейке [si+473h] лежит закодированный код исходного пароля.
        call    sub_10172       ; sub_10172 - hash-функция, которая преобразует код символа в реальный символ
                                ; исходного пароля.
        cmp     al, [si+463h]   ; в ячейке [si+463h] лежит код символа, введенного пользователем.
                                ; Код символа, введенного пользователем сравнивается с кодом правильного символа
                                ; пароля.
```
#### Вывод:
Исходный пароль можно узнать даже без dishash-функции, просто пропустив ASCII-коды из соответствующих явеек массива byte_10462 черех hash-функцию sub_10172.
## _Программа password_2.0 для взлома с изменением кода._
#### Описание:
Программа подменяет байт в бинарном файе исходной программы. Так ей удается обойти систему проверки пароля.
#### Обход пароля:
При проверке условным jamp взламываемая программа проверяет условие и в зависимости от этого переходит либо на фрагмент с открытием доступа, либо на противоположный.
``` asm
        cmp     byte_10462, 0       ; поверяет ввел ли пользователь символ '$'
        jne     loc_1013B           ; loc_1013B - метка после которой программаоткрывает доступ.
```
Если вместо условного jne поставить jmp, то программы перейдет по метке без какой-либо проверки и так можноь обойти систему проверки пароля.

Для того чтобы поменять поманду в этой части программы можно в бинарном файле заменить байт команды jne на jmp.

![](https://github.com/Pave2005/imgs/blob/main/Bits%20.png)

Меняем байт 75h на EBh.
![](https://github.com/Pave2005/imgs/blob/main/Bits2.png)

#### Вывод:
При использовании данной программы, при вводе любого пароля доступ будет открыт.

# Описание основных функций программы Password_2.0
## _Функция ReadText_

#### Описание:
Функция переписывает содержимое файла в буфер buf, выделяя нужное количество памяти для того, чтобы фместить файл.

#### Аргументы:

file - указатель на файл, который нужно перенести в буфер.

size - размер файла.

#### Возвращаемое значение:

Возвращает ардесс начела буфера, в котором лежит содержимое файла.

## _Функция FileSize_

#### Описание:

Функия возвращает длину данного ей файла.

#### Аргументы:

file - указатель на файл.

#### Возвращаемое значение:

Размер исходного файла.











