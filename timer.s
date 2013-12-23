%ifndef __TIMER_S
%define __TIMER_S

%include "interrupt.s"

timer_handler_msg db 'Another Tick', 0x0d, 0x0a, 0

init_timer:
	pusha

	push timer_handler
	push 0x20
	call register_interrupt_handler
	pop ax
	pop ax

	mov ax, 0x0000
	mov es, ax
	mov ax, irq0
	mov [es:0x80], ax
	mov ax, cs
	mov [es:0x82], ax

	mov bx, 10000
	mov al, 0x36
	out 0x43, al
	mov al, bl
	out 0x40, al
	mov al, bh
	out 0x40, al
	
	popa
	ret

timer_handler:
	pusha
.tick:
	mov si, timer_handler_msg
.print:
	lodsb
	cmp al, 0
	je .print_end
	mov ah, 0x0e
	mov bx, 7
	int 10h
	jmp .print
.print_end:
	popa
	ret

%endif
