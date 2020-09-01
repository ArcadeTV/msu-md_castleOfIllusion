; RAM Locations
CurrentSoundID	EQU	$F40E					; ID of current Sound
b_cd_audio 		EQU	$0DE0					; CD Audio enabled var
b_play_last		EQU	$0DE1					; Last CD track played var
door_sound		EQU $FF8A					; Function in RAM which calls PlaySound (SoundCode $C6 in D0)

; I/O
HW_version		EQU	$A10001					; hardware version in low nibble
											; bit 6 is PAL (50Hz) if set, NTSC (60Hz) if clear
											; region flags in bits 7 and 6:
											;         USA NTSC = $80
											;         Asia PAL = $C0
											;         Japan NTSC = $00
											;         Europe PAL = $C0
											
; MSU-MD vars
MCD_STAT		EQU $A12020					; 0-ready, 1-init, 2-cmd busy
MCD_CMD			EQU $A12010
MCD_ARG 		EQU $A12011
MCD_CMD_CK 		EQU $A1201F

; SoundIDs
music01			EQU $81						; Title Prologue
music02			EQU $82						; Stage 1-1 					(loop)
music03			EQU $83						; Substage						(loop)
music04			EQU $84						; Stage 1-2						(loop)
music05			EQU $86						; Stage 1-Rolling Apple
music06			EQU $87						; Stage 2-1						(loop)
music07			EQU $93						; Stage 2-2						
music08			EQU $94						; Stage 2-1 (Intro Variation)	(loop)
music09			EQU $88						; Stage 2-3						(loop)
music10			EQU $8B						; Stage 3-1
music11			EQU $8C						; Stage 3-2
music12			EQU $8E						; Stage 4-1
music13			EQU $91						; Stage 4-2
music14			EQU $96						; Stage 5-1
music15			EQU $98						; Stage 5-2
music16			EQU $89						; Stage Clear
music17			EQU $8A						; Lost a life
music18			EQU $90						; Staff Roll
music19			EQU $99						; Diamond
music20			EQU $9A						; Final Boss
music21			EQU $9B						; Ending
music22			EQU $9C						; Rainbow
music23			EQU $9D						; Game Over
music24			EQU $9E						; Castle						(loop)
music25			EQU $9F						; Boss							(loop)
                                            ; Stage 1-1 (Intro Variation) [NOT present in SOUND TEST]
music26			EQU $D1 					; SEEEGAAAA
music27			EQU $D2 					; The Castle of Illusion (voice)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		org 	$1A4						; ROM_END
		dc.l 	$000FFFFF					; Overwrite with 8 MBIT size


		org 	$324						; Beginning of checksum-check function
		jsr 	MSUDRV						; Call MSU-MD init
		jsr 	audio_init
		jmp 	ResumeAfterChecksumCheck

		org 	$346						; only for Label
ResumeAfterChecksumCheck

		org 	$1F0						; COUNTRY CODES
		dc.b	"JUE  "						; Overwrite "JAPAN" with JUE
		
		
		org $79F86							; only for Label
PlaySound

		org $7A494							; only for Label
GM_SegaLoop
		

;		HIJACKING PlaySound Calls in different Game Modes:
;		TrackNo to SoundCode:
;		01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26
;		81 82 83 84 86 87 93 94 88 8B 8C 8E 91 96 98 89 8A 90 99 9A 9B 9C 9D 9E 9F ??

		org	$8A90							; Staff Roll: Sound Code $90
		jsr CustomPlaySound					; Overwrite jsr to PlaySound
		
		org	$9740							; SetStageSong
		jmp CustomPlaySound					; Overwrite jmp to PlaySound
		
		org $9D58 							; GM_Init (SEGA LOGO)
		jsr CustomPlaySound
		
		org	$9D96							; GM_OpeningInit: Sound Code $81
		jmp CustomPlaySound					; Overwrite jmp to PlaySound
		
		org $9DE3							; GM_OpeningLoop: Sound Code $D1
		dc.b $D2							; Overwrite SoundCode
		
		org	$9DE6							; TITLE SCREEN, GM_OpeningLoop: Sound Code $D1
		;jsr pause_fade_track				; Fade out Prologue sound
		jsr CustomPlaySound					; Overwrite jmp to PlaySound
		
		org	$A024							; GM_SoundTestLoop
		jmp CustomPlaySound					; Overwrite jmp to PlaySound
		
		org $A02A
		nop									; enable Stage Selection
		
		org	$A27E							; GM_OutsideCastle: Sound Code $9E
		jsr CustomPlaySound					; Overwrite jsr to PlaySound
		
		org	$B018							; player_killed: Sound Code $8A
		jsr CustomPlaySound					; Overwrite jsr to PlaySound
		
		org	$121D4							; emerald_appears: Sound Code $99
		jsr CustomPlaySound					; Overwrite jsr to PlaySound
	
		org $7B120							; jumps to door_sound function in RAM
		bra pause_fade_track_24
		
		org $80000
MSUDRV
		dc.b	$30,$3C,$00,$01,$0C,$B9,$53,$45,$47,$41,$00,$40,$01,$00,$66,$00,$00,$5E,$13,$FC,$00,$02,$00,$A1,$20,$01,$08,$39,$00,$01,$00,$A1,$20,$01,$13,$FC,$00,$00,$00,$A1,$20,$03,$20,$7C,$00,$00,$00,$34,$22,$7C,$00,$42,$00,$00,$30,$3C,$03,$62,$32,$FB,$88,$00,$54,$48,$51,$C8,$FF,$F8,$13,$FC,$00,$00,$00,$A1,$20,$0F,$13,$FC,$00,$01,$00,$A1,$20,$01,$10,$39,$00,$A1,$20,$01,$02,$00,$00,$01,$67,$00,$FF,$F4,$13,$FC,$00,$00,$00,$A1,$20,$02,$30,$3C,$00,$00,$4E,$75,$00,$00,$00,$00,$00,$00,$00,$7C,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$90,$00,$00,$00,$A0,$00,$00,$00,$A0,$2E,$7C,$00,$08,$00,$00,$46,$FC,$20,$00,$4E,$F9,$00,$00,$03,$2A,$4E,$FA,$FF,$EE,$48,$E7,$C0,$C0,$4E,$B9,$00,$00,$05,$8C,$4C,$DF,$03,$03,$4E,$73,$4E,$73,$00,$00,$12,$2F,$00,$07,$10,$39,$00,$07,$01,$AD,$66,$F8,$13,$C1,$00,$07,$01,$AC,$23,$EF,$00,$08,$00,$07,$01,$A8,$13,$FC,$00,$01,$00,$07,$01,$AD,$4E,$75,$59,$4F,$2F,$02,$22,$2F,$00,$0C,$4A,$01,$67,$54,$30,$39,$00,$07,$01,$A6,$E4,$48,$24,$00,$E1,$8A,$02,$82,$00,$3F,$FF,$00,$42,$A7,$1F,$41,$00,$03,$2F,$02,$4E,$B9,$00,$00,$06,$50,$50,$8F,$20,$40,$B0,$82,$62,$2C,$22,$79,$00,$00,$06,$C0,$20,$02,$E0,$88,$E5,$48,$33,$40,$00,$34,$94,$88,$1F,$79,$00,$07,$01,$AE,$00,$07,$12,$2F,$00,$07,$10,$39,$00,$07,$01,$AE,$B0,$01,$67,$F2,$B1,$C2,$63,$DA,$24,$1F,$58,$4F,$4E,$75,$12,$2F,$00,$0B,$20,$6F,$00,$04,$30,$2F,$00,$0E,$53,$40,$0C,$40,$FF,$FF,$67,$06,$10,$C1,$51,$C8,$FF,$FC,$4E,$75,$4E,$71,$2F,$02,$10,$2F,$00,$0B,$14,$00,$E8,$0A,$72,$00,$12,$02,$24,$01,$E7,$8A,$D4,$81,$D4,$81,$02,$00,$00,$0F,$D0,$02,$02,$80,$00,$00,$00,$FF,$24,$1F,$4E,$75,$48,$E7,$30,$20,$20,$2F,$00,$10,$74,$00,$26,$00,$42,$43,$48,$43,$2F,$00,$48,$78,$00,$02,$45,$FA,$FF,$1A,$4E,$92,$42,$A7,$42,$A7,$4E,$92,$4F,$EF,$00,$10,$42,$A7,$42,$A7,$4E,$92,$50,$8F,$B6,$39,$00,$07,$01,$B3,$66,$F0,$42,$41,$E9,$8A,$70,$00,$30,$01,$41,$F9,$00,$07,$01,$B2,$84,$30,$08,$02,$52,$41,$0C,$41,$00,$05,$63,$E8,$20,$02,$4C,$DF,$04,$0C,$4E,$75,$48,$E7,$30,$38,$20,$79,$00,$00,$06,$C0,$11,$7C,$00,$00,$00,$01,$20,$79,$00,$00,$06,$C0,$10,$BC,$00,$02,$48,$78,$00,$0C,$42,$A7,$48,$79,$00,$07,$01,$A6,$45,$FA,$FF,$3C,$4E,$92,$48,$78,$01,$9C,$42,$A7,$48,$79,$00,$07,$00,$0A,$4E,$92,$33,$FC,$40,$00,$00,$07,$01,$A6,$4F,$EF,$00,$18,$20,$79,$00,$00,$06,$C0,$10,$28,$00,$01,$08,$00,$00,$00,$67,$F6,$11,$7C,$00,$10,$00,$33,$20,$79,$00,$00,$06,$C0,$31,$7C,$00,$04,$00,$36,$74,$0F,$42,$A7,$42,$A7,$47,$FA,$FE,$6A,$4E,$93,$50,$8F,$53,$42,$6A,$F0,$2F,$3C,$00,$04,$00,$00,$48,$78,$00,$02,$4E,$93,$50,$8F,$74,$2F,$42,$A7,$42,$A7,$4E,$93,$50,$8F,$53,$42,$6A,$F4,$2F,$3C,$00,$04,$00,$00,$49,$FA,$FF,$0A,$4E,$94,$10,$39,$00,$07,$01,$B6,$E9,$88,$02,$80,$00,$00,$0F,$F0,$80,$39,$00,$07,$01,$B7,$42,$A7,$1F,$40,$00,$03,$61,$00,$FE,$C4,$72,$00,$12,$00,$23,$C1,$00,$07,$00,$0A,$36,$3C,$01,$00,$42,$42,$50,$8F,$4A,$81,$67,$54,$20,$02,$E5,$88,$02,$80,$00,$03,$FF,$FC,$24,$40,$D5,$FC,$00,$07,$00,$0A,$20,$03,$02,$80,$00,$05,$FF,$FF,$00,$80,$00,$05,$00,$00,$2F,$00,$4E,$94,$25,$40,$00,$08,$58,$8F,$20,$03,$02,$80,$00,$00,$0F,$00,$32,$03,$06,$41,$07,$00,$0C,$80,$00,$00,$09,$00,$67,$04,$06,$41,$FA,$00,$36,$01,$52,$42,$42,$80,$30,$02,$B0,$B9,$00,$07,$00,$0A,$65,$AC,$2F,$3C,$00,$03,$00,$00,$61,$00,$FE,$76,$23,$C0,$00,$07,$00,$0E,$22,$02,$E5,$89,$02,$81,$00,$03,$FF,$FC,$20,$41,$D1,$FC,$00,$07,$00,$12,$20,$80,$42,$A7,$48,$78,$00,$02,$4E,$93,$4F,$EF,$00,$0C,$4C,$DF,$1C,$0C,$4E,$75,$59,$4F,$2F,$02,$20,$79,$00,$00,$06,$C0,$11,$7C,$00,$01,$00,$20,$61,$00,$FE,$8E,$20,$79,$00,$00,$06,$C0,$10,$BC,$00,$02,$20,$79,$00,$00,$06,$C0,$1F,$68,$00,$1F,$00,$07,$20,$79,$00,$00,$06,$C0,$11,$7C,$00,$00,$00,$20,$20,$79,$00,$00,$06,$C0,$12,$28,$00,$1F,$10,$2F,$00,$07,$B0,$01,$67,$F4,$1F,$68,$00,$1F,$00,$07,$11,$7C,$00,$02,$00,$20,$20,$79,$00,$00,$06,$C0,$10,$28,$00,$10,$0C,$00,$00,$15,$66,$16,$10,$28,$00,$11,$ED,$48,$02,$40,$3F,$C0,$33,$C0,$00,$07,$01,$A6,$31,$40,$00,$34,$60,$B0,$14,$28,$00,$10,$70,$00,$10,$02,$72,$13,$B2,$80,$67,$52,$6D,$0A,$12,$3C,$00,$11,$B2,$80,$6E,$98,$60,$08,$72,$14,$B2,$80,$67,$6C,$60,$8E,$10,$28,$00,$11,$53,$00,$13,$C0,$00,$07,$01,$AF,$E5,$88,$02,$80,$00,$00,$03,$FC,$20,$40,$D1,$FC,$00,$07,$00,$0A,$2F,$28,$00,$08,$48,$78,$00,$03,$61,$00,$FC,$B8,$20,$79,$00,$00,$06,$C0,$31,$79,$00,$07,$01,$A6,$00,$34,$13,$C2,$00,$07,$01,$B0,$60,$44,$10,$28,$00,$11,$42,$A7,$1F,$40,$00,$03,$61,$00,$FC,$B8,$20,$79,$00,$00,$06,$C0,$31,$7C,$00,$00,$00,$34,$42,$A7,$48,$78,$00,$06,$61,$00,$FC,$7E,$4F,$EF,$00,$0C,$60,$00,$FF,$26,$42,$A7,$48,$78,$00,$07,$61,$00,$FC,$6C,$20,$79,$00,$00,$06,$C0,$31,$79,$00,$07,$01,$A6,$00,$34,$50,$8F,$60,$00,$FF,$08,$4E,$71,$2F,$02,$22,$2F,$00,$0C,$41,$F9,$00,$07,$00,$00,$13,$EF,$00,$0B,$00,$07,$00,$00,$42,$39,$00,$07,$00,$01,$42,$39,$00,$07,$00,$08,$20,$01,$42,$40,$48,$40,$E8,$48,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$02,$20,$01,$42,$40,$48,$40,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$03,$20,$01,$74,$0C,$E4,$A8,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$04,$20,$01,$E0,$88,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$05,$20,$01,$E8,$88,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$06,$02,$01,$00,$0F,$13,$C1,$00,$07,$00,$07,$42,$39,$00,$07,$00,$09,$42,$41,$70,$00,$30,$01,$10,$30,$08,$00,$D0,$39,$00,$07,$00,$09,$13,$C0,$00,$07,$00,$09,$52,$41,$0C,$41,$00,$08,$63,$E4,$0A,$00,$00,$0F,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$09,$24,$1F,$4E,$75,$2F,$02,$74,$00,$41,$F9,$00,$07,$01,$B2,$0C,$39,$00,$01,$00,$07,$01,$B2,$66,$76,$4A,$39,$00,$07,$01,$B3,$66,$6E,$42,$41,$E9,$8A,$70,$00,$30,$01,$84,$30,$08,$02,$52,$41,$0C,$41,$00,$05,$63,$EE,$12,$39,$00,$07,$01,$AF,$20,$01,$E5,$88,$02,$80,$00,$00,$03,$FC,$20,$40,$D1,$FC,$00,$07,$00,$16,$20,$10,$55,$80,$B0,$82,$62,$3A,$4A,$39,$00,$07,$00,$00,$66,$32,$43,$FA,$FB,$4C,$0C,$39,$00,$12,$00,$07,$01,$B0,$66,$1A,$20,$01,$E5,$88,$02,$80,$00,$00,$03,$FC,$20,$40,$D1,$FC,$00,$07,$00,$12,$2F,$10,$48,$78,$00,$03,$60,$06,$42,$A7,$48,$78,$00,$06,$4E,$91,$50,$8F,$24,$1F,$4E,$75,$43,$F9,$00,$07,$01,$B2,$20,$79,$00,$00,$06,$C0,$30,$28,$00,$36,$08,$00,$00,$01,$66,$F6,$33,$E8,$00,$38,$00,$07,$01,$B2,$33,$68,$00,$3A,$00,$02,$33,$68,$00,$3C,$00,$04,$33,$68,$00,$3E,$00,$06,$33,$68,$00,$40,$00,$08,$10,$39,$00,$07,$01,$AD,$41,$FA,$FE,$86,$67,$1C,$2F,$39,$00,$07,$01,$A8,$70,$00,$10,$39,$00,$07,$01,$AC,$2F,$00,$4E,$90,$13,$FC,$00,$00,$00,$07,$01,$AD,$60,$06,$42,$A7,$42,$A7,$4E,$90,$50,$8F,$20,$79,$00,$00,$06,$C0,$31,$79,$00,$07,$00,$00,$00,$42,$31,$79,$00,$07,$00,$02,$00,$44,$31,$79,$00,$07,$00,$04,$00,$46,$31,$79,$00,$07,$00,$06,$00,$48,$31,$79,$00,$07,$00,$08,$00,$4A,$0C,$39,$00,$01,$00,$07,$01,$B2,$66,$08,$10,$10,$00,$00,$00,$01,$60,$06,$10,$10,$02,$00,$FF,$FE,$10,$80,$61,$00,$FE,$C2,$10,$39,$00,$07,$01,$AE,$52,$00,$13,$C0,$00,$07,$01,$AE,$4E,$75,$00,$00,$2F,$02,$22,$2F,$00,$0C,$20,$2F,$00,$08,$0C,$81,$00,$01,$00,$00,$64,$16,$24,$00,$42,$42,$48,$42,$84,$C1,$30,$02,$48,$40,$34,$2F,$00,$0A,$84,$C1,$30,$02,$60,$30,$24,$01,$E2,$89,$E2,$88,$0C,$81,$00,$01,$00,$00,$64,$F4,$80,$C1,$02,$80,$00,$00,$FF,$FF,$22,$02,$C2,$C0,$48,$42,$C4,$C0,$48,$42,$4A,$42,$66,$0A,$D2,$82,$65,$06,$B2,$AF,$00,$08,$63,$02,$53,$80,$24,$1F,$4E,$75,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4E,$75,$4E,$75,$00,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4E,$75,$4E,$75
		
		
		org $80750
CustomPlaySound
		tst.b 	b_cd_audio					; is CD Audio enabled?
		beq.s 	passthrough					; branch if not
		btst 	#$6,HW_version.l 			; Check for PAL or NTSC, 0=60Hz, 1=50Hz
		beq 	sixtyhertz
fiftyhertz
		; use 50Hz optimized tracks
sixtyhertz
		
ready
		tst.b 	MCD_STAT
		bne.s 	ready 						; Wait for Driver ready to receive cmd
		jsr 	find_track
		rts 								; Return to regular game code
		
audio_init
		sf b_cd_audio						; Clear CD Audio enabled var
		sf b_play_last						; Clear Last CD track played var
		tst.w	d0							; if 0: no CD Hardware found
		bne		audio_init_fail				; Return without setting CD enabled
		st		b_cd_audio					; CD enabled
		move.w 	#($1500|255),MCD_CMD		; Set CD Volume to MAX
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
audio_init_fail
		rts
		

passthrough
		jmp PlaySound						; jump back to original function
		

find_track
		move.b 	(CurrentSoundID).w,d0		; get (CurrentSoundID) for compare
		move.b 	d0,b_play_last				; save last played Track

		cmp.b 	#$81,d0
		beq 	play_track_1
		cmp.b 	#$82,d0
		beq 	play_track_2
		cmp.b 	#$83,d0
		beq 	play_track_3
		cmp.b 	#$84,d0
		beq 	play_track_4
		cmp.b 	#$86,d0
		beq 	play_track_5
		cmp.b 	#$87,d0
		beq 	play_track_6
		cmp.b 	#$93,d0
		beq 	play_track_7
		cmp.b 	#$94,d0
		beq 	play_track_8
		cmp.b 	#$88,d0
		beq 	play_track_9
		cmp.b 	#$8B,d0
		beq 	play_track_10
		cmp.b 	#$8C,d0
		beq 	play_track_11
		cmp.b 	#$8E,d0
		beq 	play_track_12
		cmp.b 	#$91,d0
		beq 	play_track_13
		cmp.b 	#$96,d0
		beq 	play_track_14
		cmp.b 	#$98,d0
		beq 	play_track_15
		cmp.b 	#$89,d0
		beq 	play_track_16
		cmp.b 	#$8A,d0
		beq 	play_track_17
		cmp.b 	#$90,d0
		beq 	play_track_18
		cmp.b 	#$99,d0
		beq 	play_track_19
		cmp.b 	#$9A,d0
		beq 	play_track_20
		cmp.b 	#$9B,d0
		beq 	play_track_21
		cmp.b 	#$9C,d0
		beq 	play_track_22
		cmp.b 	#$9D,d0
		beq 	play_track_23
		cmp.b 	#$9E,d0
		beq 	play_track_24
		cmp.b 	#$9F,d0
		beq 	play_track_25
		cmp.b 	#$D1,d0
		beq 	play_track_26
		cmp.b 	#$D2,d0
		beq 	play_track_27
break
		rts
		
play_track_1
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|1),MCD_CMD 			; send cmd: play track #1, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_2
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1200|2),MCD_CMD 			; send cmd: play track #2, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_3
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|3),MCD_CMD 			; send cmd: play track #3, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_4
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|4),MCD_CMD 			; send cmd: play track #4, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_5
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|5),MCD_CMD 			; send cmd: play track #5, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_6
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|6),MCD_CMD 			; send cmd: play track #6, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_7
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|7),MCD_CMD 			; send cmd: play track #7, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_8
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|8),MCD_CMD 			; send cmd: play track #8, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_9
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|9),MCD_CMD 			; send cmd: play track #9, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_10
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|10),MCD_CMD 		; send cmd: play track #10, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_11
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|11),MCD_CMD 		; send cmd: play track #11, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_12
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|12),MCD_CMD 		; send cmd: play track #12, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_13
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|13),MCD_CMD 		; send cmd: play track #13, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_14
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|14),MCD_CMD 		; send cmd: play track #14, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_15
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|15),MCD_CMD 		; send cmd: play track #15, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_16
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|16),MCD_CMD 		; send cmd: play track #16, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_17
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|17),MCD_CMD 		; send cmd: play track #17, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_18
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|18),MCD_CMD 		; send cmd: play track #18, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_19
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|19),MCD_CMD 		; send cmd: play track #19, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_20
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|20),MCD_CMD 		; send cmd: play track #20, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_21
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|21),MCD_CMD 		; send cmd: play track #21, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_22
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|22),MCD_CMD 		; send cmd: play track #22, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_23
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|23),MCD_CMD 		; send cmd: play track #23, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_24
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|24),MCD_CMD 		; send cmd: play track #24, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_25
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|25),MCD_CMD 		; send cmd: play track #25, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_26
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|26),MCD_CMD 		; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_27
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		move.w 	#($1100|27),MCD_CMD 		; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts


pause_fade_track
		move.w 	#($1300|200),MCD_CMD 		; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
		
pause_track
		move.w 	#($1300|0),MCD_CMD 			; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts

pause_fade_track_24
		move.w 	#($1300|100),MCD_CMD 		; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		dc.b 	$4E,$B8,$FF,$8A				; jump back
		rts
		
resume_track
		move.w 	#$1400,MCD_CMD 				; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
		
		
cd_audio_tbl
;			 Track#							  Request#	Code	Name
		dc.w 1								; $00: 		0x81 	Title Prologue
		dc.w 2								; $01: 		0x82 	Stage 1-1
		dc.w -1								; $02: 		0x83 	Substage
		dc.w -1								; $03: 		0x84 	Stage 1-2
		dc.w -1								; $04: 		0x86 	Stage 1-Rolling Apple
		dc.w -1								; $05: 		0x87 	Stage 2-1
		dc.w -1								; $06: 		0x93 	Stage 2-2
		dc.w -1								; $07: 		0x94 	Stage 2-1 (Intro Variation)
		dc.w -1								; $08: 		0x88 	Stage 2-3
		dc.w -1								; $09: 		0x8B 	Stage 3-1
		dc.w -1								; $10: 		0x8C 	Stage 3-2
		dc.w -1								; $11: 		0x8E 	Stage 4-1
		dc.w -1								; $12: 		0x91 	Stage 4-2
		dc.w -1								; $13: 		0x96 	Stage 5-1
		dc.w -1								; $14: 		0x98 	Stage 5-2
		dc.w -1								; $15: 		0x89 	Stage Clear
		dc.w -1								; $16: 		0x8A 	Lost a life
		dc.w -1								; $17: 		0x90 	Staff Roll
		dc.w -1								; $18: 		0x99 	Diamond
		dc.w -1								; $19: 		0x9A 	Final Boss
		dc.w -1								; $20: 		0x9B 	Ending
		dc.w -1								; $21: 		0x9C 	Rainbow
		dc.w -1								; $22: 		0x9D 	Game Over
		dc.w -1								; $23: 		0x9E 	Castle
		dc.w -1								; $24: 		0x9F 	Boss
		dc.w -1								; $25: 		0x?? 	Stage 1-1 (Intro Variation) [NOT present in SOUND TEST]
