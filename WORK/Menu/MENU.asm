.8086
.model small
.stack 2048

dados	segment para  'data'
  startGame     db "       1 - Start Game$"
  mazeSettings  db "       2 - Maze Settings$"
  scoreBoard    db "       3 - Score Board$"
  exit          db "       4 - Exit$"
  userOption    db "       Option >$"
dados	ends

;############################################
mostra macro str
  mov ah,09h
  lea dx,STR
  int 21h
  mov dl, 10
  mov ah, 02h
  int 21h
  mov dl, 13
  mov ah, 02h
  int 21h
endm
;############################################
read_input proc
		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		input
		mov		ah, 08h
		int		21h
		mov		ah,1
input:	ret
read_input	endp
;############################################

codigo segment para 'code'
  assume cs:codigo, ds:dados

inicio:
  mov ax, dados
  mov ds, ax

ciclo:
  mostra startGame
  mostra mazeSettings
  mostra scoreBoard
  mostra exit
  mostra userOption
  jne ciclo

fim:
  mov ah, 4Ch
  int 21h

codigo ends
end inicio
