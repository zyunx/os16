%ifndef __MONITOR_S
%define __MONITOR_S

%define MONITOR_FB		0xB8000
%define MONITOR_CMD		0x3d4
%define MONITOR_DATA	(MONITOR_CMD+1)

%define MONITOR_CMD_SET_CUR_H	14
%define MONITOR_CMD_SET_CUR_L	15


monitor_curx	db 0
monitor_cury	db 0

; Move Cursor
monitor_mov_cur:
	push bp
	mov bp, sp
	push dx
	push cx

	xor ax, ax
	mov al, [monitor_cury]
	mov cl, 80
	mul cl
	add al, [monitor_curx]
	adc ah, 0
	mov cx, ax

	mov al, MONITOR_CMD_SET_CUR_H
	mov dx, MONITOR_CMD
	out dx, al

	mov al, ch
	mov dx, MONITOR_DATA
	out dx, al

	mov al, MONITOR_CMD_SET_CUR_L
	mov dx, MONITOR_CMD
	out dx, al
	
	mov al, cl
	mov dx, MONITOR_DATA
	out dx, al
	
	pop cx
	pop dx
	mov sp, bp
	pop bp
	ret

; Scroll up the screen one line
monitor_scroll:
	push bp
	mov bp, sp
	push di
	push si
	push cx

	cmp byte [monitor_cury], 25
	jb .return
	push ds
	cld
	mov ax, 0xB000
	mov ds, ax
	mov si, 0x8000 + 160
	mov es, ax
	mov di, 0x8000
	mov cx, 80*24
	rep movsw

	mov ax, 0x0F20
	mov cx, 80
	rep stosw
	pop ds

	mov byte [monitor_cury], 24
.return:
	pop cx
	pop si
	pop di
	mov sp, bp
	pop bp
	ret

; Clean a monitor
monitor_clear:
	push bp
	mov bp, sp
	push di
	push cx

	cld
	mov ax, 0xB000
	mov es, ax
	mov di, 0x8000
	mov ax, 0x0F20
	mov cx, 80*25
	rep stosw

	mov byte [monitor_cury], 0
	mov byte [monitor_curx], 0
	call monitor_mov_cur
.return:
	pop cx
	pop di
	mov sp, bp
	pop bp
	ret

; Put a char at current location
; parameter 1 : char value (on stack)
monitor_putc:
	push bp
	mov bp, sp
	push dx
	push cx
	push di
	push es

	mov dx, [bp+4]
	mov dh, 0x0f
	
.if_bs:										; If backspace
	cmp	dl, 0x08
	jnz .if_tab
	dec byte [monitor_curx]
	jmp .end_char_if
.if_tab:									; If tab
	cmp dl, 0x09
	jnz .if_carrage
	add byte [monitor_curx], 8
	and byte [monitor_curx], 0xF8
	jmp .end_char_if
.if_carrage:								; If '\r'
	cmp dl, 0x0d
	jnz .if_newline
	mov byte [monitor_curx], 0
	jmp .end_char_if
.if_newline:								; if '\n'
	cmp dl, 0x0a
	jnz .if_printable
	mov byte [monitor_curx], 0
	inc byte [monitor_cury]
	jmp .end_char_if
.if_printable:
	cmp dl, 0x20
	jb	.end_char_if
	mov ax, 0xB000
	mov es, ax
	mov di, 0x8000
	xor ax, ax
	mov al, [monitor_cury]
	mov cl, 80
	mul cl
	add al, [monitor_curx]
	adc ah, 0
	shl ax, 1
	add di, ax
	mov [es:di], dx
	inc byte [monitor_curx]
.end_char_if:
	
	cmp byte [monitor_curx], 80
	jb .move_cur
	mov byte [monitor_curx], 0
	inc byte [monitor_cury]
.move_cur:
	call monitor_scroll
	call monitor_mov_cur
.end:

	pop es
	pop di
	pop cx
	pop dx
	mov sp, bp
	pop bp
	ret

; Print a string (zero terminated)
monitor_puts:
	push bp
	mov bp, sp
	push bx

	mov bx, [bp+4]
.print_next:
	cmp byte [bx], 0
	jz	.return
	mov ax, [bx]
	mov ah, 0
	push ax
	call monitor_putc
	add sp, 2
	inc bx
	jmp .print_next
.return:
	pop bx
	mov sp, bp
	pop bp
	ret

; Print a world
monitor_putw:
	push bp
	mov bp, sp
	push dx
	push cx

	mov ax, [bp + 4]
	mov cx, 4
.pc:
	rol ax, 4
	mov dl, al
	and dl, 0xF
	cmp dl, 9
	ja .p10a
	add dl, '0'
	jmp .p
.p10a:
	sub dl, 10
	add dl, 'a'
.p:
	mov dh, 0
	push ax
	push dx
	call monitor_putc
	add sp, 2
	pop ax
	loop .pc

	pop cx
	pop dx
	mov sp, bp
	pop bp
	ret


%endif
