.model tiny
.186
.code
org 100h

locals @@

MaxPswdLen          equ 30
HashNum             equ 24

Start:              push cs
                    pop ds

                    mov ah, 09h
                    lea dx, Intro
                    int 21h                     ; вывели строку на экран.

                    call PutRefPswd

                    call TakeSyms               ; в буффере EntrPswdBuf лежит введенный пароль.
                    call Hash                   ; ax = password

                    call TakeRefPswd
                    xor dh, dh

                    cmp dx, ax
                    jne @@IncorrectPswd

                    mov ah, 09h
                    lea dx, AccessIsOpen
                    int 21h

                    jmp @@Final

@@IncorrectPswd:    mov ah, 09h
                    lea dx, AccessIsClosed
                    int 21h

@@Final:            mov ax, 4c13h
                    int 21h

AccessIsOpen   db   0ah, 0ah, 'Access to info is open!',           '$'
AccessIsClosed db   0ah, 0ah, 'Access to info is closed!',         '$'
Intro          db  'Enter the password to log in!', 0ah, 0ah,      '$'

EntrPswdBuf    db   MaxPswdLen DUP(0)

;===============================================================================
TakeSyms    proc

            xor ax, ax
            lea bx, EntrPswdBuf

@@EntrPswd: mov ah, 01h
            int 21h                             ; в al лежит введенный символ символ.

            cmp al, '$'
            je @@StopIp

            mov byte ptr cs:[bx], al            ; в первой ячейке массива лежит первый символ.

            inc bx
            jmp @@EntrPswd

@@StopIp:   ret
            endp

;===============================================================================
Hash        proc

            lea si, EntrPswdBuf                 ; адресс нулевой ячейки массива.

            mov ax, HashNum
            xor dh, dh

            xor cl, cl

            mov cl, byte ptr cs:[si]            ; cl = EntrPswdBuf[0]
            mov dl, byte ptr cs:[si + 1]
            shl dl, 2
            or cl, dl

            mov dl, byte ptr cs:[si + 2]
            shr dl, 4
            or cl, dl

            mul cl                              ; ax *= cl
            shr ax, 4

            mov dl, byte ptr cs:[si + 3]
            shr dl, 3
            mov cl, byte ptr cs:[si + 4]
            or dl, cl

            xor dl, dl

            or ax, dx
            shl ax, 8
            shr ax, 8

            or ax, dx                           ; ax = захешированный пароль

            ret
            endp

;===============================================================================
TakeRefPswd proc

            push ax

            lea si, EntrPswdBuf + 5

            mov dh, byte ptr cs:[si]
            mov dl, byte ptr cs:[si + 1]

            sub dh, '0'
            sub dl, '0'

            xor ax, ax
            mov al, dh
            mov cl, 16
            mul cl

            add dl, al                            ; получили число

            pop ax

            ret
            endp

;===============================================================================
PutRefPswd  proc

            lea si, EntrPswdBuf + 5

            mov byte ptr cs:[si],     '4'
            mov byte ptr cs:[si + 1], '1'

            ret
            endp

end         Start
