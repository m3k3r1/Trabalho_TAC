.8086
.model	small
.stack	2048

dseg   	segment para public 'data'
	POSy			db	5	;posicao atual
	POSx			db	10 ;posicao atual
	ProxPOSy	db	5 ;proxima posicao
	ProxPOSx	db	10 ; proxima posicao
	Cor 			db  7 ; atributo cor do carater que estava na posicao anterior
	Car				db  32	; carater que estava na posicao anterior
	POSya			db	5 ; posicao anterior
	POSxa			db	10 ; posicao anterior

dseg    	ends

cseg		segment para public 'code'
		assume  cs:cseg, ds:dseg

;Macro para saber se a proxima posicao esta livre
goto_Prox_xy	macro		ProxPOSx,ProxPOSy
		mov		ah,02h
		mov		bh,0		; numero da p�gina
		mov		dl,ProxPOSx
		mov		dh,ProxPOSy
		int		10h
		mov 	ah, 08h
		mov		bh,	0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que esta na posicao do Cursor
		mov		Cor, ah	; Guarda a cor que esta na posicao do Cursor
endm
;########################################################################

;Macro para mudar a posicao do cursor
goto_xy	macro		POSx,POSy
		mov		ah,02h
	 	mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm

;########################################################################
; Ler tecla do ecra
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

main		proc
		mov     ax, dseg
		mov     ds, ax

		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

CICLO:
		goto_xy	POSxa,POSya	; Vai para a posi��o anterior do cursor
		mov		ah, 02h
		mov		dl, Car	; Repoe Caracter guardado
		int		21H

		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor

		goto_xy	POSx,POSy	; Vai para posi��o do cursor
IMPRIME:	mov		ah, 02h
		mov		dl, 190	; Coloca AVATAR
		int		21H
		goto_xy	POSx,POSy	; Vai para posi��o do cursor

		mov		al, POSx	; Guarda a posi��o do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 		POSya, al

		mov		al, POSx	; Guarda a posi��o do cursor
		mov		ProxPOSx, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 	ProxPOSy, al

LER_SETA:
		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND
		jmp		LER_SETA

ESTEND:
		cmp 	al,48h
		jne		BAIXO
		dec 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO ; Se estiver ocupada volta ao inicio sem alteracao da posicao atual
		dec 	POSy
		jmp 	CICLO


BAIXO:
		cmp		al,50h
		jne		ESQUERDA
		inc 	ProxPOSy	;Baixo
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp 	al, 20h ;  Verificacao se esta esta ocupada
		jne 	CICLO; Se estiver ocupada volta ao inicio sem alteracao da posicao atual
		inc 	POSy
		jmp		CICLO

ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec 	ProxPOSx;
		goto_Prox_xy ProxPOSx,ProxPOSy
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO; Se estiver ocupada volta ao inicio sem alteracao da posicao atual
		dec 	POSx
		jmp		CICLO

DIREITA:
		cmp		al,4Dh
		jne		LER_SETA
		inc 	ProxPOSx;
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO; Se estiver ocupada volta ao inicio sem alteracao da posicao atual
		inc 	POSx
		jmp		CICLO

FIM:
		mov		ah,4CH
		INT		21H
main		endp
cseg    	ends
end     	Main
