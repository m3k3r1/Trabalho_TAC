.8086
.model small
.stack 2048

dseg	segment para public 'data'
	posY		db	5	  ; POSy pode ir [1..25]
	posX		db	10	; POSx pode ir [1..80]
dseg	ends

codigo	segment para  'code'
	assume		cs:cseg, ds:dseg

main:
	mov ax, dados
	mov ds, ax





fim:
	mov	ah,4Ch
	int	21h

codigo ends
main ends
