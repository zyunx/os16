[BITS 16]
[ORG 0x80000]					; raw binary specific, specify the
								; address at which the output code
								; will eventually be loaded.


	jmp 0x8000:start_kernel		; gotot segment 0, offset 'start'

; Programmable Interrupt Controller Macros
%include "pic.mac"
; Interrupt service routine related
%include "interrupt.s"
%include "timer.s"

start_kernel:
	cli
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0

Meet:
	mov si, kernel_msg
PrintMeet:
	lodsb
	cmp al, 0
	je init_timer_stage
	mov ah, 0x0e
	mov bx, 7
	int 10h
	jmp PrintMeet

init_timer_stage:
	call init_timer

	;mov ah, 9
	;mov al, '='
	;mov bx, 7
	;mov cx, 1
	;int 0x10


initialize_pic:
	push ax
	push bx
	pic_remap 0x20, 0x28
	pop bx
	pop ax
	
	; Enable ISR
	sti

	push ax
	push cx
	mov al, 0
	pic_mask_irq
	pop cx
	pop ax

	push ax
	push cx
	mov al, 0
	pic_unmask_irq
	pop cx
	pop ax
	;int 0x21

hang:
	hlt
	jmp hang
	
;irq_timer:
;	cli
;	pusha
	
;	mov ah, 0
;	pic_send_eoi

;.tick:
;	mov si, timer_msg
;.print:
;	lodsb
;	cmp al, 0
;	je .print_end
;	mov ah, 0x0e
;	mov bx, 7
;	int 10h
;	jmp .print

	;mov ah, 9
	;mov al, '='
	;mov bx, 7
	;mov cx, 1
	;int 0x10
;.print_end:
;	popa
;	sti
;	iret

kernel_msg db 'Hi! I am OS16', 0x27 ,'s kernel.',0x0d, 0x0a, 0

times 0x10000-($-$$) db 0

