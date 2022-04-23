%include "lib/stdlib.asm"


; --------- SETUP --------------

DELAY	equ 50			; ms

WIDTH 	equ 200			; line length
HEIGHT 	equ 10000		; n steps

CH_0 	equ '.'			; false char
CH_1 	equ "o"			; true char

; --------- END-SETUP --------------


; compute numerical value of state given booleans prev, curr and next
%define state(prev, curr, next) (100 * CH_%+prev + 10 * CH_%+curr + CH_%+next)


; initialize board
%macro init 1
	pusha
	mov rsi, %1
	mov rcx, rsi
	add rcx, WIDTH + 2
%%_init:

	mov [rsi], byte CH_0
	mov [rdi], byte CH_0
	 
	inc rsi
	inc rdi
	 
	cmp rsi, rcx
	jbe %%_init
	 
	popa
%endmacro


global _start


section .bss
board1	resb WIDTH + 2	; 2 bytes for edges
board2	resb WIDTH + 2


section .text
_start:
	; initial setup
	mov rsi, board1
	mov rdi, board2

	init rsi
	init rdi

	; set middle element to 1
	mov byte [rsi + WIDTH / 2 + 1], CH_1

	mov rcx, HEIGHT

_loop:
	call printbrd 	; print current state
	call step 		; generate new state
	xchg rsi, rdi 	; swap pointers
	
	; only call SYS_NANOSLEEP if there is any actual delay set
	%if DELAY != 0
	sleep 0, DELAY * 1_000_000
	%endif

	loop _loop	; rinse and repeat

	exit



; --------- UTILS --------------


; print board
; input ptr: RSI
printbrd:
	pusha
	inc rsi
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rdx, WIDTH + 1
	syscall
	putc NEWL
	popa
	ret

	
; generate new automaton state
; input ptr: RSI
; output ptr: RDI
step:
	pusha
	push r8
	push r9

	; move one cell right so prev is not undefined
	inc rsi
	inc rdi

	; width limit
	mov r9, rsi
	add r9, WIDTH

_step:
	; get value of prev, curr and next
	xor r8, r8

	; prev
	xor rax, rax
	mov al, [rsi - 1]
	mov rbx, 100
	mul rbx
	add r8, rax

	; curr
	xor rax, rax
	mov al, [rsi]
	mov rbx, 10
	mul rbx
	add r8, rax

	; next
	xor rax, rax
	mov al, [rsi + 1]
	add r8, rax
	

	; main logic
	cmp r8, state(1, 1, 1)
	jz _sfalse
	cmp r8, state(1, 1, 0)
	jz _strue
	cmp r8, state(1, 0, 1)
	jz _sfalse
	cmp r8, state(1, 0, 0)
	jz _strue
	cmp r8, state(0, 1, 1)
	jz _strue
	cmp r8, state(0, 1, 0)
	jz _sfalse
	cmp r8, state(0, 0, 1)
	jz _strue
	cmp r8, state(0, 0, 0)
	jz _sfalse


	abort	; shouldn't happen

_sret:
	; increment pointers
	inc rsi
	inc rdi

	cmp rsi, r9
	jbe _step

	pop r9
	pop r8
	popa	
	ret


; set current cell to 0
_sfalse:
	mov [rdi], byte CH_0
	jmp _sret

; set current cell to 1
_strue:
	mov [rdi], byte CH_1
	jmp _sret
