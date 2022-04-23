%macro spush 1
	push %1
%endmacro

%macro spop 1
	pop %1
%endmacro

%macro sdup 0
	spop rax
	mov rbx, rax
	spush rax
	spush rbx
%endmacro

%macro sswap 0
	spop rax
	spop rbx
	spush rax
	spush rbx
%endmacro

%macro sdrop 0
	add rsp, 8
%endmacro

%macro sover 0
	sswap
	sdup
%endmacro

%macro srot 0
	spop rcx
	spop rbx
	spop rax

	spush rbx
	spush rcx
	spush rax
%endmacro

%macro sadd 0
	spop rax
	spop rbx
	add rax, rbx
	spush rax
%endmacro

%macro ssub 0
	spop rax
	spop rbx
	sub rax, rbx
	spush rax
%endmacro

%macro smul 0
	spop rax
	spop rbx
	mul rbx
	spush rax
%endmacro

%macro sdivmod 0
	xor rdx, rdx
	spop rbx
	spop rax
	div rbx
	spush rax
	spush rdx
%endmacro

%macro sdiv 0
	sdivmod
	sdrop
%endmacro

%macro smod 0
	sdivmod
	sswap
	sdrop
%endmacro

%macro sidivmod 0
	xor rdx, rdx
	spop rax
	spop rbx
	cqo
	xchg rax, rbx
	idiv rbx
	spush rax
	spush rdx
%endmacro

%macro sidiv 0
	sidivmod
	sdrop
%endmacro

%macro simod 0
	sidivmod
	sswap
	sdrop
%endmacro

%macro spow 0
	spop rcx
	dec rcx
	sdup
	spop rbx
	spop rax
%%_loop:
	mul rbx
	loop %%_loop
	spush rax
%endmacro

%macro sshr 0
	spop rax
	spop rcx
	shr rax, cl
	spush rax
%endmacro

%macro sshl 0
	spop rax
	spop rcx
	shl rax, cl
	spush rax
%endmacro

%macro seq 0
	spop rax
	spop rbx
	cmp rax, rbx
	je %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro slt 0
	spop rax
	spop rbx
	cmp rbx, rax
	jl %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sgt 0
	spop rax
	spop rbx
	cmp rbx, rax
	jg %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sle 0
	spop rax
	spop rbx
	cmp rbx, rax
	jle %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sge 0
	spop rax
	spop rbx
	cmp rbx, rax
	jge %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sbt 0
	spop rax
	spop rbx
	cmp rbx, rax
	jb %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sat 0
	spop rax
	spop rbx
	cmp rbx, rax
	ja %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sbe 0
	spop rax
	spop rbx
	cmp rbx, rax
	jbe %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sae 0
	spop rax
	spop rbx
	cmp rbx, rax
	jae %%_true
	sspush 0
	jmp %%_end
%%_true:
	sspush 1
%%_end:
	nop
%endmacro

%macro sand 0
	spop rax
	spop rbx
	and rax, rbx
	spush rax
%endmacro

%macro sor 0
	spop rax
	spop rbx
	or rax, rbx
	spush rax
%endmacro

%macro sxor 0
	spop rax
	spop rbx
	xor rax, rbx
	spush rax
%endmacro

%macro sputc 0
	mov rax, 1
	mov rdi, 1
	mov rsi, rsp
	mov rdx, 1
	syscall
	sdrop
%endmacro

%macro sputs 0
	spop r8
%%_loop:
	sputc
	dec r8
	cmp r8, 0
	jne %%_loop
	spush NEWL
	sputc
%endmacro

%macro sprint 0
	spop rax
	print rax
	spush NEWL
	sputc
%endmacro

%macro sinc 0
	spop rax
	inc rax
	spush rax
%endmacro

%macro sdec 0
	spop rax
	dec rax
	spush rax
%endmacro

%macro scmp 0
	spop rax
	cmp rax, 0
%endmacro

%macro srepl 0
	spop rcx
	spop rax
	inc rcx
%%_loop:
	spush rax
	loop %%_loop
%endmacro

%macro stake 0
    sdup
    pop rax
    mov rbx, sizeof(qword)
    mul rbx
    mov rbx, rsp
    add rbx, rax
    mov rax, [rbx]
    add rsp, sizeof(qword)
    push rax
%endmacro
