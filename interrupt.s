%ifndef __INTERRUPT_S
%define __INTERRUPT_S

%include "pic.mac"

irq:
	mov ah, 9
	mov al, '='
	mov bx, 7
	mov cx, 1
	int 0x10
	ret

;
; interrupt.s
; Contains interrupt service routine wrappers.
; Based on Bran's kernel development tutorials.
; Rewrittern for JamesM's kernel development tutorials

; This macro create a stub for an ISR which does NOT pass its own
; error code (adds a dummy errcode byte)
%macro ISR_NOERRCODE	1
;	globl isr%1
	isr%1:
		cli								; Disable interrupts firstly
		push byte 0						; push a dummy error code
		push byte %1					; push the interrupt number.
		jmp isr_common_stub				; Go to our common handler code.
%endmacro

; This macro create a stub for an ISR which passed it's own
; error code
%macro ISR_ERRCODE 1
;	globl isr%1
	isr%1:
		cli								; Disable interrupts
		push byte %1					; push the interrupt number
		jmp isr_common_stub
%endmacro

; This macro creates a stub for an IRQ - the first parameter is
; the IRQ number, the second is the ISR number it is remapped to.
%macro IRQ 2
;	globl irq%1
	irq%1:
		cli
		push byte 0
		push byte %2
		jmp irq_common_stub
%endmacro

ISR_NOERRCODE		0
ISR_NOERRCODE		1
ISR_NOERRCODE		2
ISR_NOERRCODE		3
ISR_NOERRCODE		4
ISR_NOERRCODE		5
ISR_NOERRCODE		6
ISR_NOERRCODE		7
ISR_ERRCODE			8
ISR_NOERRCODE		9
ISR_ERRCODE			10
ISR_ERRCODE			11
ISR_ERRCODE			12
ISR_ERRCODE			13
ISR_ERRCODE			14
ISR_NOERRCODE		15
ISR_NOERRCODE		16
ISR_NOERRCODE		17
ISR_NOERRCODE		18
ISR_NOERRCODE		19
ISR_NOERRCODE		20
ISR_NOERRCODE		21
ISR_NOERRCODE		22
ISR_NOERRCODE		23
ISR_NOERRCODE		24
ISR_NOERRCODE		25
ISR_NOERRCODE		26
ISR_NOERRCODE		27
ISR_NOERRCODE		28
ISR_NOERRCODE		29
ISR_NOERRCODE		30
ISR_NOERRCODE		31
IRQ		0,	32
IRQ		1,	33
IRQ		2,	34
IRQ		3,	35
IRQ		4,	36
IRQ		5,	37
IRQ		6,	38
IRQ		7,	39
IRQ		8,	40
IRQ		9,	41
IRQ		10,	42
IRQ		11,	43
IRQ		12,	44
IRQ		13,	45
IRQ		14,	46
IRQ		15,	47

; This is our common ISR stub. It saves the processor state, sets
; up for kernel mode segments, calls the  fault handler,
; and finally restores the stack frame
isr_common_stub:
	push di	; push di,si,bp,sp,bx,dx,cx,ax
	push si
	push bp
	push sp
	push bx
	push dx
	push cx
	push ax
	
	push ds

	mov ax, 0x8000
	mov ds, ax
	mov es, ax
	
	jmp isr_handler

after_isr_handler:
	pop	bx
	mov	ds, bx
	mov es, bx

	pop ax
	pop cx
	pop dx
	pop bx
	pop sp
	pop bp
	pop si
	pop di
	add sp, 4						; cleans up the pushed error code
									; and pushed ISR number
	sti
	iret							; pop ip, cs, flags

; This is our common IRQ stub. It saves the processor stat, sets
; up for kernel mode segments, calls the fault handler
; and finally restores the stack frame.
irq_common_stub:
	push di	; push di,si,bp,sp,bx,dx,cx,ax
	push si
	push bp
	push sp
	push bx
	push dx
	push cx
	push ax
	mov ax, ds
	push ds

	mov ax, 0x8000					; load kernel data segment descriptor
	mov ds, ax
	mov es, ax
	
	jmp irq_handler

after_irq_handler:
	pop bx
	mov ds,bx
	mov es,bx

	pop ax
	pop cx
	pop dx
	pop bx
	pop sp
	pop bp
	pop si
	pop di
	add sp, 4
	sti
	iret

; Current Stack
; --------
; ...
; flag
; cs
; ip
; err_code
; int_vec_nu
; di
; si
; bp
; sp
; bx
; dx
; cx
; ax
; ds
; --------
isr_handler:
	mov bp, sp
	mov bx, [bp+18]
	shl bx, 1
	mov si, [bx + interrupt_handlers]
	test si, si
	jz .isr_return
	call si
.isr_return:
	mov sp, bp	
	jmp after_isr_handler					; jump back to isr_common_stub

irq_handler:
	mov bp, sp
	mov bx, [bp+18]

	mov ah, bl
	pic_send_eoi
	
	shl bx, 1
	mov si, [bx + interrupt_handlers]
	test si, si
	jz .irq_return
	call si
.irq_return:

	mov sp, bp
	jmp after_irq_handler

register_interrupt_handler:
	push bp
	mov bp, sp
	push ax
	push bx

	mov ax, [bp+6]
	mov bx, [bp+4]
	shl bx, 1
	mov [bx+interrupt_handlers], ax
	
	pop bx
	pop ax
	mov sp, bp
	pop bp
	ret

interrupt_handlers:
	times 256 dw 0


%endif
