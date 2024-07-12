.model small
.stack 100h
.data
    buffer DB 100, ?, 100 dup (0)
    inputMessage DB 'The program has started, please enter the symbol line here: $'
    outputMessage DB 'The output of the program is: $'
    newLine DB 10, 13, '$'
    lengthMessage DB '. Length  '
.code

main:
    MOV AX, @data
    MOV DS, AX

input:
    MOV AH, 09h
    LEA DX, inputMessage
    INT 21h

    MOV AH, 0Ah
    LEA DX, buffer
    INT 21h

    MOV AH, 09h
    LEA DX, newLine
    INT 21h

processing:
    LEA BX, [buffer + 1]
    MOV AL, DS:[BX]
    MOV DL, 0

    nextIteration:
        INC DL
        INC BX

        CMP DL, AL
        JA finalizing

    MOV CL, DS:[BX]

    CMP CL, '0'
    JB nextIteration

    CMP CL, '9'
    JBE integer

    CMP CL, 'A'
    JB nextIteration

    CMP CL, 'Z'
    JBE uppercase

    CMP CL, 'a'
    JB nextIteration

    CMP CL, 'z'
    JBE lowercase

    uppercase:
        ADD CL, 32
        MOV DS:[BX], CL
        JMP nextIteration

    lowercase:
        SUB CL, 32
        MOV DS:[BX], CL
        JMP nextIteration

    integer:
        MOV CL, ' '
        MOV DS:[BX], CL
        JMP nextIteration

    finalizing:
        MOV BYTE PTR [BX], '$'
        CMP AL, 10
        JAE doubleDigit
        ADD AL, 48
        LEA BX, [lengthMessage + 9]
        MOV DS:[BX], AL 
        MOV BYTE PTR [BX+1], '$'
        JMP output

    doubleDigit:
        MOV BL, 10
        MOV AH, 0
        DIV BL
        ADD AL, 30h
        ADD AH, 30h
        LEA BX, [lengthMessage + 9]
        MOV DS:[BX], AX 
        MOV BYTE PTR [BX+2], '$'
        JMP output

output:
    MOV AH, 09h
    LEA DX, outputMessage
    INT 21h

    MOV AH, 09h
    LEA DX, [buffer + 2]
    INT 21h

    MOV AH, 09h
    LEA DX, lengthMessage
    INT 21h

null:
    MOV AX, 4C00h
    INT 21h
end main