;####################
drawSprite16:
; Draw 16x16 sprite
;
; Inputs:
;	ix	= pointer to sprite
;	de	= x coord
;	l	= y coord
;####################
	ld h,lcdWidth/2	; y * lcdWidth/2
	mlt hl
	add hl,hl		; y * lcdWidth
	add hl,de		; y * lcdWidth + x
	ld de,(gBuf)
	add hl,de		; hl = position in vRam
	push hl
	lea hl, ix		; skip width/height bytes
	pop ix
	ld bc,16
dsLoop:
	ld b,16
	lea de,ix		; ld de, ix
dsSpriteLoop:
	ld a,(hl)
	or a,a
	 jr z,$+3
		ld (de),a
	inc hl
	inc de
	djnz dsSpriteLoop
	ld de,lcdWidth
	add ix,de		; move to next line
	dec c
	 jr nz,dsLoop
	ret