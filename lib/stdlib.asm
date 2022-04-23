%include "lib/syscalls.asm"

%define sizeof(__type__) __%+__type__%+_s
%define maxof(__type__) (2 << (BYTE_BITS * sizeof(__type__) - 1)) - 1

; for compatibility with sizeof
__byte_s	equ BYTE_SIZE
__word_s 	equ WORD_SIZE
__dword_s 	equ DWORD_SIZE
__qword_s 	equ QWORD_SIZE

BYTE_BITS	equ 8

BYTE_SIZE	equ 1
WORD_SIZE 	equ BYTE_SIZE 	<< 1
DWORD_SIZE 	equ WORD_SIZE 	<< 1
QWORD_SIZE 	equ DWORD_SIZE 	<< 1

BYTE_MAX 	equ maxof(byte)
WORD_MAX 	equ maxof(word)
DWORD_MAX 	equ maxof(dword)
QWORD_MAX 	equ maxof(qword)

SIGILL 		equ 132
SIGTRAP 	equ 133
SIGABRT 	equ 134
SIGFPE 		equ 136
SIGBUS 		equ 138
SIGSEGV 	equ 139
SIGXCPU 	equ 158
SIGXFSZ 	equ 159

STDIN 		equ 0
STDOUT 		equ 1
STDERR 		equ 2

EXIT_SUCCESS	equ 0
EXIT_FAILURE 	equ 1

NULL 		equ 0

TRUE 		equ	1
FALSE 		equ 0

CR 			equ 0x0d
LF 			equ 0x0a
NEWL 		equ LF
EOF			equ -1
ERR			equ -1

O_ACCMODE 	equ 0000003o
O_RDONLY	equ 0000000o
O_WRONLY	equ 0000001o
O_RDWR		equ 0000002o
O_CREAT		equ 0000100o	
O_EXCL		equ 0000200o	
O_NOCTTY	equ 0000400o	
O_TRUNC		equ 0001000o	
O_APPEND	equ 0002000o
O_NONBLOCK	equ 0004000o
O_DSYNC		equ 0010000o	
O_DIRECT	equ 0040000o	
O_LARGEFILE	equ 0100000o
O_DIRECTORY	equ 0200000o	
O_NOFOLLOW	equ 0400000o	
O_NOATIME	equ 1000000o
O_CLOEXEC	equ 2000000o



; push common registers to stack
%macro pusha 0
	push rax
	push rbx
	push rcx
	push rdx
	push rsi
	push rdi
%endmacro


; pop common registers from stack
%macro popa 0
	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rbx
	pop rax
%endmacro


; call SYS_EXIT with desired exit code 
%macro exit 1
	mov rax, SYS_EXIT
	mov rdi, %1
	syscall
%endmacro


; call SYS_EXIT with exit code 0 (EXIT_SUCCESS)
%macro exit 0 
	exit EXIT_SUCCESS
%endmacro


; abort execution with SIGABRT
%macro abort 0
	exit SIGABRT
%endmacro


; write string to desired stream
%macro fputs 2
	pusha
	push %1
	push %2
	mov rax, %1
	call strlen
	mov rax, SYS_WRITE
	pop rdi
	pop rsi
	syscall
	popa
%endmacro


; write string to STDOUT
%macro puts 1
	fputs %1, STDOUT
%endmacro


; write char (r/imm64) to desired stream
%macro fputc 2
	pusha
	push %1
	mov rax, SYS_WRITE
	mov rdi, %2
	mov rsi, rsp
	mov rdx, 1 		; length of byte
	syscall
	add rsp, sizeof(qword)
	popa
%endmacro


; write char (r/imm64) to STDOUT
%macro putc 1
	fputc %1, STDOUT
%endmacro


; print decimal (r/imm64) to STDOUT
%macro print 1
	pusha
	push NULL
	mov rax, %1
%%_print:
	mov rcx, 10
	xor rdx, rdx
	div	rcx
	add rdx, '0'
	push rdx
	cmp rax, 0
	jnz %%_print

%%_print2:
	pop rax
	cmp rax, NULL
	jz %%_printr
	putc rax
	jmp %%_print2

%%_printr:
	popa
%endmacro


; fill buffer with bytes from stream
; fp, buf, n
%macro fgets 3
	mov rax, SYS_READ
	mov rdi, %1
	mov rsi, %2
	mov rdx, %3
	syscall
%endmacro


; fill buffer with bytes from STDIN
; buf, n
%macro gets 2
	fgets STDIN %1, %2
%endmacro


; get char from stream to RAX
%macro fgetc 1
	sub rsp, sizeof(qword)
	fgets %1, rsp, 1
	pop rax
%endmacro


; get char from STDIN to RAX
%macro getc 0
	fgetc STDIN
%endmacro


; sleep for %1 seconds and %2 nanoseconds
%macro sleep 2
	pusha
	push %2
	push %1

	mov rax, SYS_NANOSLEEP
	mov rdi, rsp
	mov rsi, 0
	syscall

	add rsp, 2 * sizeof(qword)
	popa
%endmacro

; sleep for %1 seconds
%macro sleep 1
	sleep %1, 0
%endmacro


; write char %2 to buffer %1
%macro write 2
	pusha
	xor rbx, rbx
	mov bl, [%1]
	mov byte [%1 + rbx + 1], %2
	inc byte [%1]
	popa
%endmacro


; flush buffer %1
%macro flush 1
	pusha
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, %1
	inc rsi
	xor rdx, rdx
	mov dl, [%1]
	syscall
	mov byte [%1], 0
	popa
%endmacro


; open file given path string %1, flags %2 and return fd in RAX
%macro fopen 2
	push rdi
	push rsi
	mov rax, SYS_OPEN
	mov rdi, %1
	mov rsi, %2
	syscall
	pop rsi
	pop rdi
%endmacro


%macro fopenr 1
	fopen %1, O_RDONLY
%endmacro


%macro fopenw 1
	fopen %1, O_WRONLY
%endmacro


%macro fopenrw 1
	fopen %1, O_RDWR
%endmacro


; close file given by fd in RAX
%macro fclose 1
	pusha
	push %1
	mov rax, SYS_CLOSE
	pop rdi
	syscall
	popa
%endmacro


%macro fclose 0
	pop rax
	fclose rax
	add rsp, sizeof(qword)
%endmacro


; get length of string in <RAX> to <RDX>
strlen:
	push rax
	mov rdx, -1
	dec rax
_strlen:
	inc rax
	inc rdx
	cmp byte[rax], 0
	jne _strlen
	pop rax
	ret
