#include "inc/ti84pce.inc"

.assume ADL = 1
.org userMem - 2
.db tExtTok, tAsm84CeCmp

LCD_SIZE	= lcdWidth * lcdHeight		; size of lcd at 8bpp
SPEED		= 2							; default walking speed

gBuf		= pixelShadow
spriteX		= gBuf + 3
spriteY		= spriteX + 3
mapX		= spriteY + 3
mapY		= mapX + 3
mapPtr		= mapY + 3
mapW		= mapPtr + 3
mapH		= mapW + 3
walkSpeed	= mapH + 3
setup:
	di
; clear saferam
	ld hl, pixelShadow
	ld de, pixelShadow + 1
	ld (hl), 0
	ld bc, 8400 - 1
	ldir
; load default vRam location
	ld hl, gBuf
	ld bc, vRam
	ld (hl), bc
; clear screen and load palette
	ld a,$FF
	call clrScreen
	call loadPalette
	ld a, lcdbpp8			; enable 8bpp mode
	ld (mpLcdCtrl), a
	xor a,a
	call loadMap
start:
	call swapVram
	call drawMap
	ld ix, man
	ld de, (spriteX)
	ld hl, (spriteY)
	call drawSprite16
	call checkKeys
; check enter
	ld a, (kbdG6)
	rra
	 jr c,quit
; check arrows
	ld a,(kbdG7)
	rra
	push af
	 call c, moveDown
	pop af
	rra
	push af
	 call c, moveLeft
	pop af
	rra
	push af
	 call c, moveRight
	pop af
	rra
	 call c, moveUp
	jr start

moveDown:
	ld hl,spriteY
	ld a,(hl)
	add a, SPEED
	ld b, lcdHeight - 16
	cp a,b
	 jr c,$+3
		ld a, b
	ld (hl),a
	ret

moveUp:
	ld hl,spriteY
	ld a,(hl)
	sub SPEED
	 jr nc,$+3
		xor a,a
	ld (hl),a
	ret

moveRight:
	ld de, SPEED
	ld hl,(spriteX)
	add hl, de
	ld de,lcdWidth - 16
	or a,a
	sbc hl,de
	add hl,de
	 jr c,$+3
		ex de,hl
	ld (spriteX), hl
	ret

moveLeft:
	ld hl,(spriteX)
	ld de,SPEED
	or a,a
	sbc hl,de
	ld a,h
	rla
	 jr nc,$+6
		ld hl,$000000
	ld (spriteX), hl
	ret

quit:
	ld hl,mpLcdBase
	ld bc,vRam
	ld (hl),bc
	ld a,lcdbpp16
	ld (mpLcdCtrl), a
	ld a,$FF
	jr clrScreen

checkKeys:
	ld hl,DI_Mode
	ld (hl),2
	xor a,a
ckLoop:
	cp a,(hl)
	 jr nz,ckLoop
	ret

clrScreen:
	ld hl,(gBuf)
	ld (hl),a
	ld de,(gBuf)
	inc de
	ld bc,LCD_SIZE * 2 - 1
	ldir
	ret

loadPalette:
	ld hl,_sprites_pal
	ld de,mpLcdPalette
	ld bc,_sprites_pal_size
	ldir
	ret


swapVram:
	ld hl,mpLcdBase			; hl = mpLcdBase, the address of the memory-mapped vRam
	ld bc,(hl)				; get current vRam address
	xor a,a
	or a,b					; check if it is vRam (in which case b=0) or the second buffer
	ld de,vRam
	 jr nz,$ + 6
		ld de,vRam + LCD_SIZE
	ld (hl),de				; swap buffer into mpLcdBase
	ld (gBuf),bc			; save the inactive buffer as our new gbuf
	ld	l,mpLcdIcr & $FF
	set	bLcdIntLNBU,(hl)	; clear the previous LcdNextBaseUpdate interrupt
	ld	l,mpLcdRis & $FF
loop:
	bit	bLcdIntLNBU,(hl)	; wait until the interrupt triggers
	 jr z,loop
	ret

#include "gfx.asm"
#include "map.asm"

;sprites
#include "img/sprites.inc"

maps:
	.dl map1

map1:
	.dl 32,40
	.db 1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0
	.db 0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0