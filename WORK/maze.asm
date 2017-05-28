;------------------------------------------------------------------------
;
;	Base para TRABALHO PRATICO - TECNOLOGIAS e ARQUITECTURAS de COMPUTADORES
;
;	ANO LECTIVO 2016/2017
;;--------------------------------------------------------------
; Imprime valor da tecla numa posi��o do ecran na posi��o linha,coluna
;--------------------------------------------------------------
;	Programa de demostra��o de v�rias rotinhas do sistema de
;	manipula��o do ecr�n
;	Imprime um de v�rios caracteres na localiza��o do cursor
; 	Caracteres s�o seleccionadas com as teclas: 1, 2, 3, 4, e SPACE
;
;		arrow keys to move
;		press ESC to exit
;--------------------------------------------------------------

.8086
.model small
.stack 2048

dseg	segment para public 'data'
		var1	dw ?
		handle  dw  ?
		string	db	"Teste pr�tico de T.I",0
		filename db "f1.txt", 0
		Car			db	32
		POSy		db	5	; a linha pode ir de [1 .. 25]
		POSx		db	10	; POSx pode ir [1..80]
		InPOSx	db  ?
		InPOSy	db	?
	;	p_POSxy dw	40	; ponteiro para posicao de escrita
dseg	ends

cseg	segment para public 'code'
assume		cs:cseg, ds:dseg



;########################################################################
goto_xy	macro		POSx,POSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
;ROTINA PARA APAGAR ECRAN

apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80

apaga:
		mov	byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 		bx
		loop		apaga
		ret
apaga_ecran	endp


;########################################################################
; LE UMA TECLA

LE_TECLA	PROC

		mov		ah,08h
		int		21h
		mov		ah,0
		cmp		al,0
		jne		SAI_TECLA
		mov		ah, 08h
		int		21h
		mov		ah,1
SAI_TECLA:	RET
LE_TECLA	endp
;########################################################################

Main  proc
		mov		ax, dseg
		mov		ds,ax
		mov		ax,0B800h
		mov		es,ax

		call		apaga_ecran

		;Obter a posi��o
		dec		POSy		; linha = linha -1
		dec		POSx		; POSx = POSx -1

		mov 	ah,3CH ; Criacao do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		mov 	dx, OFFSET filename
		int		21h
		mov		handle, ax


CICLO:	goto_xy	POSx,POSy
IMPRIME:
		mov		ah, 02h
		mov		dl, Car
		int		21H
		goto_xy	POSx,POSy

		call 		LE_TECLA
		cmp		ah, 1
		je		ESTEND
		cmp 	AL, 27		; ESCAPE
		je		ESCAPE


UM:		CMP 		AL, 49		; Tecla 1
		JNE		DOIS
		mov		Car, 35	;Caracter CHEIO
		jmp		CICLO

DOIS:		CMP 		AL, 50		; Tecla 2
		JNE		TRES
		mov		Car, 32		;Espaco
		jmp		CICLO

TRES:		CMP 		AL, 51		; Tecla 3
		JNE		QUATRO
		mov		Car, 73	;Carater Inicial
		jmp		CICLO

QUATRO:	CMP 		AL, 52; Tecla 4
		JNE		NOVE
		mov		Car, 70		;Carater final
		jmp		CICLO

NOVE:		jmp		CICLO

ESTEND:	cmp 		al,48h
		jne		BAIXO
		dec		POSy		;cima
		jmp		CICLO

BAIXO:	cmp		al,50h
		jne		ESQUERDA
		inc 	POSy		;Baixo
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec		POSx		;Esquerda
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		CICLO
		inc		POSx		;Direita
		jmp		CICLO

ESCAPE:
		mov ax,0b800h
		mov es,ax
		xor si,si
		jmp fim


fim:
		mov al, es:[si]
		mov ah, es:[si+1]
		mov var1,ax
		mov ah,40h
		mov cx,2
		lea dx,var1
		mov	bx,handle
		int 21h
		add si , 2
		cmp si, 4000
		jne fim

		mov		ah,3Eh ; Fecho do ficheiro
		mov		bx,handle
		int		21h

		mov		ah,4CH
		INT		21H
Main	endp
Cseg	ends
end	Main
