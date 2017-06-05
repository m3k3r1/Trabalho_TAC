.8086
.model	small
.stack	2048

dseg   	segment para public 'data'
	Mensagem_Final db 'Parabens conseguiu chegar ao fim.$'
	main_menu db 'Labirinto',13,10
		db	'+----------------------------------+',13,10
		db 	' 1: Jogar                					',13,10
		db 	' 2: Top 10           							',13,10
		db	' 3: Configuracao do Labirinto     ',13,10
		db	' 4: Sair                          ',13,10
		db	'+----------------------------------+$',13,10
	jogar_menu db 'Jogar',13,10
		db	'+----------------------------------+',13,10
		db 	' 1: Jogar com setas               		',13,10
		db  ' 2: Jogar com codigo Hexa				',13,10
		db	' 3: Carregar Labirinto						',13,10
		db	'+----------------------------------+$',13,10
	conf_menu db 'Configuracao',13,10
		db	'+----------------------------------+',13,10
		db	' 1: Criar Labirinto      					',13,10
		db  ' 2: Editar Labirinto               ',13,10
		db	'+----------------------------------+$',13,10
	buffer_Legenda db "Legenda:1-Carater cheio//2-Barras//3-Espaco//4-Carater Inicial//5-Carater Final$"
	buffer_Joga db "Esc-Voltar ao menu$"
	Escolha   db  ?
	Car_Cria  db  ?
	carFich 	db 	?
	var1			dw 	?
	handle  	dw  ?
	filename 	db  "Lab1.txt", 0
	filename_Cria db "f1.txt", 0
	filename_TOP10 db "top10.txt", 0
	handle_TOP10 dw ?
	handle_Cria dw ?
	POSy			db	5
	POSx			db	10
	ProxPOSy	db	5
	ProxPOSx	db	10
	Cor 			db  7
	Car				db  32
	POSya			db	5
	POSxa			db	10
	Cria_POSx db  21
	Cria_POSy db  3
	defaultPOSx db 1
	defaultPOSy db 1
	total_inic dw ?
	array dw 5 dup(?)
	minutos dw ?
	segundos dw ?
	temptotal dw ?
	tempfinal dw ?
	tempo_inicial dw ?
	tempo_final dw ?

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
		mov		Car, al	; Guarda o Caracter que esta na posicao do Cursor (que nao e a posicao do carater)
		mov		Cor, ah	; Guarda a cor que esta na posicao do Cursor (que nao e a posicao do carater)
endm
;Macro para mudar a posicao do cursor
goto_xy	macro		POSx,POSy
		mov		ah,02h
	 	mov		bh,0		; numero da p�gina
		mov		dl,POSx
		mov		dh,POSy
		int		10h
endm
;############################################################
;Converter numero para string
number2string proc
  mov  bx, 10 ;DIGITS ARE EXTRACTED DIVIDING BY 10.
  mov  cx, 0 ;COUNTER FOR EXTRACTED DIGITS.
cycle1:
  mov  dx, 0 ;NECESSARY TO DIVIDE BY BX.
  div  bx ;DX:AX / 10 = AX:QUOTIENT DX:REMAINDER.
  push dx ;PRESERVE DIGIT EXTRACTED FOR LATER.
  inc  cx ;INCREASE COUNTER FOR EVERY DIGIT EXTRACTED.
  cmp  ax, 0  ;IF NUMBER IS
  jne  cycle1 ;NOT ZERO, LOOP.
;NOW RETRIEVE PUSHED DIGITS.
cycle2:
  pop  dx
  add  dl, 48 ;CONVERT DIGIT TO CHARACTER.
  mov  [ si ], dl
  inc  si
  loop cycle2
  ret
number2string endp
;############################################################
;encher o array com $ para o poder ler
dollars proc
  	mov  cx, 5
dollars1:
  	mov  bl, '$'
  	mov  [ si ], bl
  	inc  si
  	loop dollars1
  	ret
dollars endp
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
apaga_ecran	proc
		xor		bx,bx
		mov		cx,25*80
apaga:
		mov		byte ptr es:[bx],' '
		mov		byte ptr es:[bx+1],7
		inc		bx
		inc 	bx
		loop	apaga
		ret
apaga_ecran	endp
;######################################################################
;Guardar o tempo
tempo_t proc

	 PUSH AX
	 PUSH BX
	 PUSH CX
	 PUSH DX

	 PUSHF

	 MOV AH, 2CH             ; Buscar a hORAS
	 INT 21H

	 XOR AX,AX
	 MOV AL, DH              ; segundos para al
	 mov Segundos, AX		; guarda segundos na variavel correspondente

	 XOR AX,AX
	 MOV AL, CL              ; Minutos para al
	 mov Minutos, AX         ; guarda MINUTOS na variavel correspondente

	 ; converter minutos para segundos // CHECK THIS
	 mov bl,60
	 mul bl		;AX<-Ax*60
	 add	Segundos, AX ;segundos<-minutos+segundos
	 mov  ax, Segundos
	 mov  temptotal,ax

	 POPF
	 POP DX
	 POP CX
	 POP BX
	 POP AX

	 RET
tempo_t endp
;################################################
;imprimir bonus
imprime1 proc
		mov		ah, 02h
		mov		dl, 254	; Coloca AVATAR
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
		ret
imprime1 endp

main		proc
		mov   ax, dseg
		mov 	ds, ax
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov 	ah, 08h	; Guarda o Caracter que est� na posi��o do Cursor
		mov		bh,0		; numero da p�gina
		int		10h
		mov		Car, al	; Guarda o Caracter que est� na posi��o do Cursor
		mov		Cor, ah	; Guarda a cor que est� na posi��o do Cursor
;#############################################
;Menu principal
INICIO:
		call 	apaga_ecran
		mov 	POSx, 0
		mov 	POSy, 0
		goto_xy POSx, POSy ; mete o cursor no inicio do ecra
		mov		ah, 09h
		lea		dx, main_menu ; imprime o menu principal
		int		21h
		mov 	ah, 00h
		int 	16h
		mov 	Escolha, al
		cmp 	escolha, 49 ;opcao 1
		je 		menu_jogar  ;leva ao submenu - jogar
		cmp 	escolha, 50 ;opcao 2
		je 		final					;mostra o top 10
		cmp   escolha, 51 ;opcao 3
		je    menu_conf   ;leva ao submenu - config
		cmp 	escolha, 52 ;opcao 4
		je 		final 			; fecha o jogo
		cmp 	al, 48
		jbe 	INICIO ; caso nao escolha uma das opcoes volta ao inicio
		cmp 	al, 52
		jae 	INICIO
;###########################################
;Sub menu de Jogar
menu_jogar:
		call 	apaga_ecran
		mov 	POSx, 0
		mov 	POSy, 0
		goto_xy POSx, POSy ; mete o cursor no inicio do ecra
		mov		ah, 09h
		lea		dx, jogar_menu ; imprime o menu de jogo
		int		21h
		mov 	ah, 00h
		int 	16h
		mov 	Escolha, al
		cmp 	escolha, 49 ; opcao 1
		je 		Abre_Default
		cmp 	escolha, 50 ; opcao 2
		je 		Abre_Default
		cmp   escolha, 51; opcao 3
		je    Abre_User
		cmp 	al, 48
		jbe 	menu_jogar; caso nao escolha uma das opcoes volta ao inicio do menu
		cmp 	al, 51
		jae 	menu_jogar
;###########################################
;Sub menu de Jogar
menu_conf:
		call 	apaga_ecran
		mov 	POSx, 0
		mov 	POSy, 0
		goto_xy POSx, POSy ; mete o cursor no inicio do ecra
		mov		ah, 09h
		lea		dx, conf_menu ;imprime o menu de configuracao
		int		21h
		mov 	ah, 00h ; esperar por input
		int 	16h
		mov 	Escolha, al
		cmp 	escolha, 49 ; opcao 1
		je 		INICIO_Cria
		cmp 	escolha, 50 ; opcao 2
		je 		Editar
		cmp 	al, 48
		jbe 	menu_conf; caso nao escolha uma das opcoes volta ao inicio do menu
		cmp 	al, 50
		jae 	menu_conf
;###########################################
;Abertura do labirinto default
Abre_Default:
		call  apaga_ecran
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		mov 	ah,3Dh ; Abertura do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename
		int		21h
		mov		handle, ax
		mov   POSx, 0
		mov   POSy, 0
		goto_xy POSx, POSy

ler_ciclo:
		mov   ah,3fh			; indica que vai ser lido um ficheiro
		mov   bx,handle		; bx deve conter o Handle do ficheiro previamente aberto
		mov   cx,1			; numero de bytes a ler
		lea   dx,carFich		; vai ler para o local de memoria apontado por dx (car_fich)
		int   21h				; faz efectivamente a leitura
		cmp   ax,0			;EOF?	verifica se já estamos no fim do fdoicheiro
		je   fecha_ficheiro	; se EOF fecha o ficheiro
		mov   ah,02h			; coloca o caracter no ecran
		mov   dl,carFich		; este é o caracter a enviar para o ecran
		int 	21h			; imprime no ecran
		jmp	 	ler_ciclo		; continua a ler o ficheiro
fecha_ficheiro:
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Joga
		int		21h
		mov 	POSx, 5
		mov 	POSy, 10
		mov   ah,3eh
		mov   bx,handle
		int   21h
		cmp   escolha, 49
		je		CICLO
		jne   bonus_inicio
;#######################################
;Abertura do labirinto do user
Abre_User:
		call  apaga_ecran
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si
		goto_xy defaultPOSx, defaultPOSy

		mov 	ah,3Dh ; Abertura do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename_Cria
		int		21h
		mov		handle_Cria, ax
		mov   POSx, 0
		mov   POSy, 0
		goto_xy POSx, POSy
ler_ciclo_user:
		mov   ah,3fh			; indica que vai ser lido um ficheiro
		mov   bx,handle_Cria		; bx deve conter o Handle do ficheiro previamente aberto
		mov   cx,1			; numero de bytes a ler
		lea   dx,carFich		; vai ler para o local de memoria apontado por dx (car_fich)
		int   21h				; faz efectivamente a leitura
		cmp	  ax,0			;EOF?	verifica se já estamos no fim do fdoicheiro
		je	  fecha_ficheiro_user	; se EOF fecha o ficheiro
		mov   ah,02h			; coloca o caracter no ecran
		mov	  dl,carFich		; este é o caracter a enviar para o ecran
		int	  21h				; imprime no ecran
		jmp	  ler_ciclo_user		; continua a ler o ficheiro
fecha_ficheiro_user:
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Joga
		int		21h
		mov 	POSx, 5
		mov 	POSy, 10
		mov   ah,3eh
		mov   bx,handle_Cria
		int   21h
		jmp		CICLO
;########################################
;Jogo em si
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
IMPRIME:
		mov		ah, 02h
		mov		dl, 254	; Coloca AVATAR
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
		CMP 	AL, 27	; ESCAPE
		JE		INICIO
		jmp		LER_SETA

ESTEND:
		cmp 	al,48h
		jne		BAIXO
		dec 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70   ; comparacao com o carater final
		je    Fim_C
		cmp   al, 73
		je    Inicio_C ; comparacao com o carater inicial
		cmp   ProxPOSy,0 ; verificacao se nao sai das boundaries
		je   CICLO
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO
		dec 	POSy
		jmp 	CICLO
Inicio_C:
		call  tempo_t
	  mov   ax, temptotal
		mov   tempo_inicial, ax
		dec 	POSy
		jmp 	CICLO
Fim_C:
		call	tempo_t  ; recebe tempo final
		mov		ax, temptotal ;guarda o tempo total em tempfinal // CHECK THIS
		mov		tempo_final,ax
		mov ax, tempo_inicial
		sub tempo_final,ax
		mov si,	offset array
		call	dollars
		mov si,offset array
		mov ax,tempo_final
		call number2string
		mov  dx, offset array
		mov   POSx, 1
		mov   POSy, 23
		goto_xy POSx, POSy
		mov   dx, offset array
		mov   ah, 9
		int   21h
		jmp   FIM
BAIXO:
		cmp		al,50h
		jne		ESQUERDA
		inc 	ProxPOSy	;Baixo
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a
		cmp   al, 70 ;verifica se o carater e o final
		je    Fim_B
		cmp   al, 73 ;Verifica se o caracter e o inicial
		je    Inicio_B
		cmp   ProxPOSy,22
		je   CICLO
		cmp 	al, 20h ; ; Verificacao se esta esta ocupada
		jne 	CICLO
		inc 	POSy
		jmp		CICLO
Inicio_B:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		inc 	POSy
		jmp 	CICLO
Fim_B:
		call	tempo_t  ; recebe tempo final
		mov		ax, temptotal ;guarda o tempo total em tempfinal // CHECK THIS
		mov		tempo_final,ax
		mov ax, tempo_inicial
		sub tempo_final,ax
		mov si,	offset array
		call	dollars
		mov si,offset array
		mov ax,tempo_final
		call number2string
		mov  dx, offset array
		mov   POSx, 1
		mov   POSy, 23
		goto_xy POSx, POSy
		mov   dx, offset array
		mov   ah, 9
		int   21h
		jmp   FIM


ESQUERDA:
		cmp		al,4Bh
		jne		DIREITA
		dec 	ProxPOSx;
		goto_Prox_xy ProxPOSx,ProxPOSy
		cmp   al, 70
		je 		Fim_E
		cmp   al, 73
		je    Inicio_E
		cmp   ProxPOSx,21
		je  	CICLO
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO
		dec		POSx
		jmp		CICLO
Inicio_E:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		dec 	POSx
		jmp 	CICLO
Fim_E:
		call	tempo_t  ; recebe tempo final
		mov		ax, temptotal ;guarda o tempo total em tempfinal // CHECK THIS
		mov		tempo_final,ax
		mov ax, tempo_inicial
		sub tempo_final,ax
		mov si,	offset array
		call	dollars
		mov si,offset array
		mov ax,tempo_final
		call number2string
		mov  dx, offset array
		mov   POSx, 1
		mov   POSy, 23
		goto_xy POSx, POSy
		mov   dx, offset array
		mov   ah, 9
		int   21h
		jmp   FIM


DIREITA:
		cmp		al,4Dh
		jne		LER_SETA
		inc 	ProxPOSx;
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je		Fim_D
		cmp   al, 73
		je    Inicio_D
		cmp   ProxPOSx,61
		je  	CICLO
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	CICLO
		inc   POSx
		jmp   CICLO
Inicio_D:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		inc 	POSx
		jmp 	CICLO
		Fim_D:
		call	tempo_t  ; recebe tempo final
		mov		ax, temptotal ;guarda o tempo total em tempfinal // CHECK THIS
		mov		tempo_final,ax
		mov ax, tempo_inicial
		sub tempo_final,ax
		mov si,	offset array
		call	dollars
		mov si,offset array
		mov ax,tempo_final
		call number2string
		mov  dx, offset array
		mov   POSx, 1
		mov   POSy, 23
		goto_xy POSx, POSy
		mov   dx, offset array
		mov   ah, 9
		int   21h
		jmp   FIM

;###########################################################
; PARTE RELACIONADA COM A CRIACAO DO LABIRINTO
INICIO_Cria:
		call		apaga_ecran
		;Obter a posi��o
		dec		POSy		; linha = linha -1
		dec		POSx		; POSx = POSx -1

		mov 	ah,3CH ; Criacao do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename_Cria
		int		21h
		mov		handle_Cria, ax
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Legenda
		int		21h
CICLO_Cria:	goto_xy	Cria_POSx,Cria_POSy
IMPRIME_Cria:
		mov		ah, 02h
		mov		dl, Car_Cria
		int		21H
		goto_xy	Cria_POSx,Cria_POSy

		call 	LE_TECLA
		cmp		ah, 1
		je		ESTEND_Cria
		cmp 	AL, 27		; ESCAPE
		je		ESCAPE_Cria

UM_Cria:		CMP 		AL, 49		; Tecla 1
		JNE		DOIS_Cria
		mov		Car_Cria, 219	;Caracter CHEIO
		jmp		CICLO_Cria

DOIS_Cria: CMP  AL,50 ; tecla 2
		JNE 	TRES_Cria
		mov 	Car_Cria, 186; barras
		jmp 	CICLO_Cria

TRES_Cria:		CMP 		AL, 51		; Tecla 3
		JNE		QUATRO_Cria
		mov		Car_Cria, 32	;espaco
		jmp		CICLO_Cria

QUATRO_Cria:	CMP 		AL, 52; Tecla 5
		JNE		CINCO_Cria
		mov		Car_Cria, 73		;carater inicial
		jmp		CICLO_Cria

CINCO_Cria: CMP AL,53 ; tecla 6
		jne 	NOVE_Cria
		mov   car_cria,70 ; carater final
		jmp   ciclo_cria

NOVE_Cria:		jmp		CICLO_Cria

ESTEND_Cria:	cmp 		al,48h
		jne		BAIXO_Cria
		cmp  	Cria_POSy, 1
		jbe   CICLO_Cria
		dec		Cria_POSy		;cima
		jmp		CICLO_Cria

BAIXO_Cria:	cmp		al,50h
		jne		ESQUERDA_Cria
		cmp   Cria_POSy, 21
		jae   CICLO_Cria
		inc 	Cria_POSy		;Baixo
		jmp		CICLO_Cria

ESQUERDA_Cria:
		cmp		al,4Bh
		jne		DIREITA_Cria
		cmp   Cria_POSx, 20
		jbe   CICLO_Cria
		dec		Cria_POSx		;Esquerda
		jmp		CICLO_Cria

DIREITA_Cria:
		cmp		al,4Dh
		jne		CICLO_Cria
		cmp   Cria_POSx,60
		jae   CICLO_Cria
		inc		Cria_POSx		;Direita
		jmp		CICLO_Cria

ESCAPE_Cria:
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si
GUARDA_Cria:
		mov 	al, es:[si]
		mov 	ah, es:[si+1]
		mov 	var1,ax
		mov 	ah,40h
		mov 	cx,2
		lea 	dx,var1
		mov		bx,handle_Cria
		int 	21h
		add 	si , 2
		cmp 	si, 3520
		jne 	GUARDA_Cria
		mov		ah,3Eh ; Fecho do ficheiro
		mov		bx,handle_Cria
		int		21h
		jmp 	INICIO

;Editar
;################################
Editar:
		call  apaga_ecran
		mov 	ax,0b800h
		mov 	es,ax
		xor 	si,si

		mov 	ah,3Dh ; Abertura do ficheiro
		mov 	cx,0	; Apos criacao o ficheiro ja esta aberto para leitura / escrita.
		lea 	dx, filename_Cria
		int		21h
		mov		handle_Cria, ax
		mov   POSx, 0
		mov   POSy, 0
		goto_xy POSx, POSy
ler_ciclo_edit:
		mov   ah,3fh			; indica que vai ser lido um ficheiro
		mov   bx,handle_Cria		; bx deve conter o Handle do ficheiro previamente aberto
		mov   cx,1			; numero de bytes a ler
		lea   dx,carFich		; vai ler para o local de memoria apontado por dx (car_fich)
		int   21h				; faz efectivamente a leitura
		cmp	  ax,0			;EOF?	verifica se já estamos no fim do fdoicheiro
		je	  fecha_ficheiro_edit	; se EOF fecha o ficheiro
		mov   ah,02h			; coloca o caracter no ecran
		mov	  dl,carFich		; este é o caracter a enviar para o ecran
		int	  21h				; imprime no ecran
		jmp	  ler_ciclo_edit		; continua a ler o ficheiro
fecha_ficheiro_edit:
		mov 	POSy, 23
		mov 	POSx, 1
		goto_xy POSx,POSy
		mov		ah, 09h
		lea		dx, buffer_Legenda
		int		21h
		mov 	POSx, 5
		mov 	POSy, 10
		jmp		CICLO_Cria

bonus_inicio:
		goto_xy 0, 0
		mov  ah,09h
		lea  dx,mensagem_controlos
		int  21h
		mov  POSx, 10
		mov  POSy, 15
bonus:
		goto_xy	POSx,POSy	; Vai para nova possi��o
		mov		al, POSx	; Guarda a posi��o do cursor
		mov		POSxa, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 		POSya, al

		mov		al, POSx	; Guarda a posi��o do cursor
		mov		ProxPOSx, al
		mov		al, POSy	; Guarda a posi��o do cursor
		mov 	ProxPOSy, al

		mov ah, 00h
		int 16h

		cmp al, 48
		mov cx, 1
		je bonus_cima

		cmp al, 49
		mov cx, 2
		je bonus_cima

		cmp al, 50
		mov cx, 3
		je bonus_cima

		cmp al, 51
		mov cx, 4
		je bonus_cima

		cmp al, 52
		mov cx, 1
		je bonus_baixo

		cmp al, 53
		mov cx, 2
		je bonus_baixo

		cmp al, 54
		mov cx, 3
		je bonus_baixo

		cmp al, 55
		mov cx, 4
		je bonus_baixo

		cmp al, 56
		mov cx, 1
		je bonus_direita

		cmp al, 57
		mov cx, 2
		je bonus_direita

		cmp al, 97
		mov cx, 3
		je bonus_direita

		cmp al, 98
		mov cx, 4
		je bonus_direita

		cmp al, 99
		mov cx, 1
		je bonus_esquerda

		cmp al, 100
		mov cx, 2
		je bonus_esquerda

		cmp al, 101
		mov cx, 3
		je bonus_esquerda

		cmp al, 102
		mov cx, 4
		je bonus_esquerda

		cmp al,27
		je  INICIO

		cmp al, 48
		jb bonus
		cmp al, 97
		jb	bonus
		cmp al, 102
		ja  bonus

		cmp al,27
		je  INICIO

bonus_cima:
		dec 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al,73
		je    bonus_cima_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	bonus
bonus_cima_imprime:
		dec 	POSy
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

		call imprime1
		loop bonus_cima
		jmp bonus
bonus_cima_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_cima_imprime


bonus_baixo:
		inc 	ProxPOSy
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al,73
		je    bonus_baixo_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	bonus
bonus_baixo_imprime:
		inc 	POSy
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

		call imprime1
		loop bonus_baixo
		jmp bonus
bonus_baixo_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_cima_imprime

bonus_direita:
		inc 	ProxPOSx
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al,73
		je    bonus_direita_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada
bonus_direita_imprime:
		jne 	bonus
		inc 	POSx
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

		call 	imprime1
		loop 	bonus_direita
		jmp 	bonus
bonus_direita_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_direita_imprime

bonus_esquerda:
		dec 	ProxPOSx
		goto_Prox_xy ProxPOSx,ProxPOSy ; Mudar de posicao para a seguinte
		cmp   al, 70
		je    Fim_C
		cmp   al, 73
		je    bonus_esquerda_inicio
		cmp 	al, 20h ; Verificacao se esta esta ocupada
		jne 	bonus
bonus_esquerda_imprime:
		dec 	POSx
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

		call imprime1
		loop bonus_esquerda
		jmp bonus
bonus_esquerda_inicio:
		call  tempo_t
		mov   ax, temptotal
		mov   tempo_inicial, ax
		jmp 	bonus_esquerda_imprime


FIM:
		mov 	ah,09h ;display da mensagem de quanto tempo demorou
		lea   dx, Mensagem_Final
		int   21h

FINAL:
		mov		ah,4CH
		INT		21H
main		endp
cseg    	ends
end     	Main
