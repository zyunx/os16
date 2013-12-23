BITS 16
ORG 0							; raw binary specific, specify the
								; address at which the output code
								; will eventually be loaded.

	jmp 0x7c0:start				; gotot segment 0, offset 'start'

start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov sp, 0

Meet:
	mov si, boot_msg
PrintMeet:
	lodsb
	cmp al, 0
	je reset
	mov ah, 0x0e
	mov bx, 7
	int 10h
	jmp PrintMeet

reset:								; Reset disk
	mov ah, 0
	mov dl, 0x80
	int 13h
	jc reset

read:
	mov si, DAPACK
	mov ah, 0x42
	mov dl, 0x80
	int 0x13
	jc Error

	;mov ax, 0x8000
	;mov es, ax
	;mov ax, 0
	;mov di, ax
	;mov ax, [es:di]
	;push ax
	;call putw
	;pop ax
	jmp 0x8000:0000

	;mov ax, 8000h					; ES:BX = 8000:0000
	;mov es, ax
	;mov bx, 0

	;mov ah, 2						; Load disk data to ES:BX
	;mov al, 5						; Load 128 sectors
	;mov ch, 3
	;mov cl, 3
	;mov dh, 1
	;mov dl, 0x80
	;int 13h
	;jc Error

	;mov ax, [es:0];
	;push ax
	;call putw
	;pop ax
	;jmp 0x8000:0000

	;xor ax,ax
	;mov al,bl
	;shr ax, 5
	;and ax,0x001f
	;push ax
	;call putw
	;pop ax

read_geometry:
	mov ah, 08h
	mov dl, 80h
	int 13h
	jc Error

	inc dh
	mov [number_of_heads], dh
	mov ax, cx
	and ax, 0x3f
	mov [sectors_per_track], al
	mov ax, cx
	and ax, 0xffcf
	shr ax, 6
	mov [number_of_cylinders], ax

	xor ax,ax
	mov al, [number_of_heads]
	push ax
	call putw
	pop ax
	xor ax, ax
	mov al, [sectors_per_track]
	push ax
	call putw
	pop ax
	xor ax,ax
	mov ax, [number_of_cylinders]
	push ax
	call putw
	pop ax

	
detect_mem:
	xor ax, ax
	int 0x12
	jc Error
	test ax, ax
	jz Error

	push ax
	call putw
	pop ax

	jmp hang


Error:
	mov si, msg
PrintError:
	lodsb
	cmp al, 0
	je hang
	mov ah, 0x0e
	mov bx, 7
	int 10h
	jmp PrintError
	
hang:
	jmp $

putw:
	push bp
	mov bp, sp
	pusha

	mov si, [bp + 4]
	mov cx, 4
.printw:
	rol si, 4
	mov ax, si
	and ax, 0x000f
	cmp al, 10
	jb .printc
	add al, 0x7
.printc:
	add al, '0'
	mov ah, 0x0e
	mov bx, 7
	int 0x10
	loop .printw
	
	popa
	mov sp, bp
	pop bp
	ret


number_of_heads		db	0
sectors_per_track	db	0
number_of_cylinders	dw	0

msg	db 'Error!',0

boot_msg db 'Nice to meet you! I am OS16 boot loader.', 0x0d, 0x0a, 0

DAPACK:
		db	0x10
		db	0
blkcnt:	dw  128
db_add:	dw	0x0000
		dw  0x8000
d_lba:	dd	128
		dd	0

		
times 510-($-$$) db 0
dw 0xaa55

