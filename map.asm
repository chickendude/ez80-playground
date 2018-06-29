;####################
loadMap:
; Loads a map into memory
;
; inputs:
;	a	= map to load
;####################
	or a,a
	sbc hl,hl
	ld h,3
	ld l,a			; ld hl, a
	mlt hl
	ld de,maps
	add hl,de		; get map offset
	ld hl, (hl)		; hl = map address
	ld de, 3		; each value is 3 bytes
	ld bc, (hl)		; bc = map width
	ld (mapW),bc	; save value
	add hl,de		; skip to next value
	ld bc,(hl)		; bc = map height
	ld (mapH),bc	;
	add hl,de		; hl = start of map data
	ld (mapPtr),hl	; save start of map data
	ret

;####################
drawMap:
; Draws the tilemap loaded into memory
;
; inputs:
;	None
;####################
	ld hl,(mapPtr)
	ld bc,15
	exx
		or a,a
		sbc hl,hl
		ld de,(gBuf)
	exx
dmLoop:
	ld b,20
dmRow:
	ld a,(hl)			; sprite id
	exx
		ld h,16*8
		ld l,a
		mlt hl
		add hl,hl
		ld bc,tiles
		add hl,bc		; hl = start of sprite data
		ld a,16			; 16 rows to copy
dmSpriteRow:
		ld bc,16		; copy first row (16 pixels)
		ldir
		ld bc,320-16	;
		ex de,hl
			add hl,bc
		ex de,hl
		dec a
		 jr nz,dmSpriteRow
		ld bc,-320*16 + 16
		ex de,hl
			add hl,bc
		ex de,hl
	exx
	inc hl
	 djnz dmRow
	exx
		ld bc,320*15
		ex de,hl
			add hl,bc
		ex de,hl
	exx
	ld ix,(mapW)
	lea de,ix-20
	add hl,de
	dec c
	 jr nz, dmLoop
	ret