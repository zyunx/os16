%ifndef __KEYBOARD_S
%define __KEYBOARD_S

%include "monitor.s"

%define KYBRD_ENC_INPUT_BUF		0x60
%define KYBRD_ENC_CMD_REG		0x60

%define KYBRD_CTRL_STATS_REG	0x64
%define KYBRD_CTRL_CMD_REG		0x64

; KYBRD_CTRL_STATS_MASK
%define KYBRD_CTRL_STATS_MASK_OUT_BUF	1
%define KYBRD_CTRL_STATS_MASK_IN_BUF	2
%define KYBRD_CTRL_STATS_MASK_SYSTEM	4
%define KYBRD_CTRL_STATS_MASK_CMD_DATA	8
%define KYBRD_CTRL_STATS_MASK_LOCKED	0x10
%define KYBRD_CTRL_STATS_MASK_AUX_BUF	0x20
%define KYBRD_CTRL_STATS_MASK_TIMEOUT	0x40
%define KYBRD_CTRL_STATS_MASK_PARITY	0x80

; Wait the keyboard input buffer to be full
; Use Reg: AL
%macro keyboard_wait_input_buf 0
%%again:
	in al, KYBRD_CTRL_STATS_REG
	and al, KYBRD_CTRL_STATS_MASK_IN_BUF
	jnz %%again
%endmacro

; Wait the keyboard output buffer to be full
; Used Reg: AL
%macro keyboard_wait_output_buf 0
%%again:
	in al, KYBRD_CTRL_STATS_REG
	and al, KYBRD_CTRL_STATS_MASK_OUT_BUF
	jz %%again
%endmacro


; Send command byte to keyboard controller
; Use reg: AL
%macro keyboard_ctrl_send_cmd 1

	keyboard_wait_input_buf

	mov al, %1
	out KYBRD_CTRL_CMD_REG, al
%endmacro

; Send command byte to keyboard encoder
%macro keyboard_enc_send_cmd 1
	
	keyboard_wait_input_buf

	mov al, %1
	out KYBRD_ENC_CMD_REG, al
%endmacro


init_keyboard:
	pusha

	;mov al, 0xf0
	;out KYBRD_ENC_CMD_REG, al
	;keyboard_wait_output_buf
	;in al, KYBRD_ENC_INPUT_BUF
	;mov ah, 0
	;push ax
	;call monitor_putw
	;add sp, 2

	;mov al, 0x02
	;out KYBRD_ENC_CMD_REG, al
	;keyboard_wait_output_buf
	;in al, KYBRD_ENC_INPUT_BUF
	;mov ah, 0
	;push ax
	;call monitor_putw
	;add sp, 2

	push keyboard_handler
	push 0x21
	call register_interrupt_handler
	add sp, 4

	mov ax, 0x0000
	mov es, ax
	mov ax, irq1
	mov [es:0x84], ax
	mov ax, cs
	mov [es:0x86], ax
	
	popa
	ret

keyboard_handler:
	;push 'a'
	;call monitor_putc
	;add sp, 2

	;keyboard_wait_ouput_buf
.again:
	;in al, KYBRD_CTRL_STATS_REG
	;and al, KYBRD_CTRL_STATS_MASK_OUT_BUF
	;jz .end

	;in al, KYBRD_CTRL_CMD_REG
	in al, KYBRD_ENC_INPUT_BUF
	;cmp al, 0xfa
	;jz .end
	mov ah,0
	push ax
	call monitor_putw
	add sp, 2
	;jmp .again
.end:
	ret

%endif
