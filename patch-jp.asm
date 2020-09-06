; RAM Locations
CurrentGM		EQU	$F300					; ID of current GameMode
CurrentSoundID	EQU	$F40E					; ID of current Sound
b_cd_audio 		EQU	$FDE0					; CD Audio enabled var
TrackToPlay		EQU	$FDE1					; Last CD track played var
FF_PlaySound	EQU $FF8A					; Function in RAM which calls PlaySound (SoundCode $C6 in D0)
EnablePauseFlag EQU $F41D
CurrentScene 	EQU $F370

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
;$80 			; -nothing-										[does nothing, not stopping any sound]
;$81			; Title Prologue
;$82			; Stage 1-1 					(loop)
;$83			; Substage						(loop)
;$84			; Stage 1-2						(loop)
;$85            ; Stage 1-1 (Intro Variation after Apple) 		[NOT present in SOUND TEST]
;$86			; Stage 1-Rolling Apple
;$87			; Stage 2-1						(loop)
;$93			; Stage 2-2						
;$94			; Stage 2-1 (Intro Variation)	(loop)
;$88			; Stage 2-3						(loop)
;$8B			; Stage 3-1
;$8C			; Stage 3-2
;$8E			; Stage 4-1
;$91			; Stage 4-2
;$92			; THE END 										[NOT present in SOUND TEST]
;$96			; Stage 5-1
;$98			; Stage 5-2
;$89			; Stage Clear
;$8A			; Lost a life
;$90			; Staff Roll
;$99			; Diamond
;$9A			; Final Boss
;$9B			; Ending
;$9C			; Rainbow
;$9D			; Game Over
;$9E			; Castle						(loop)
;$9F			; Stage 1-Boss - Tree			(loop)

;$D4			; SEEEGAAAA
;$D2			; The Castle of Illusion (voice)
;$D3			; Stage 2-Boss - Jack in the Box(loop)
;$D5			; Stage 4-Boss - Candydragon	(loop)
;$D6			; Stage 3-Boss - Aquamen		(loop)
;$D7			; Stage 5-Boss - Hunchback		(loop)
;$D8 			; Stage Stage 5-1-2 Underwater 	(loop)
;$D9 			; Stage Stage 3-3 Rising Water 	(loop)
;				; - nothing on $8D $8F $95 $97
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		org 	$1A4							; ROM_END
		dc.l 	$000FFFFF						; Overwrite with 8 MBIT size


		org 	$324							; Beginning of checksum-check function
		jsr 	MSUDRV							; Call MSU-MD init
		jsr 	audio_init
		jmp 	ResumeAfterChecksumCheck

		org 	$346							; only for Label
ResumeAfterChecksumCheck

		org 	$1F0							; COUNTRY CODES
		dc.b	"JUE  "							; Overwrite "JAPAN" with JUE
		
		
		org 	$79F86							; only for Label
PlaySound

		org 	$7A494							; only for Label
GM_SegaLoop
		

;		HIJACKING PlaySound Calls in different Game Modes:
;		TrackNo to SoundCode:
;		01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 | 26 | 27 28 29 30 31 32 33
;		81 82 83 84 86 87 93 94 88 8B 8C 8E 91 96 98 89 8A 90 99 9A 9B 9C 9D 9E 9F | D1 | D2 D3 D5 D6 D7 D8 D9
		
		org		$850							; Stage 2-1 Dash: Sound Code $93
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$8A90							; Staff Roll: Sound Code $90
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$1758							; Apple Dash: Sound Code $86
		jsr 	CustomPlaySound					; Overwrite jmp to PlaySound
		
		; CHEATS ---------------------------------------------------------------------------------------------
		org 	$938A
		subq.w  #0,($F322).w					; CHEAT -> don't descrease Energy
		
		org		$11EEF							; Tree Hitcount ($0A) [normal]
		dc.b 	$02
		org		$11EFD							; Tree Hitcount ($14) [hard]
		dc.b 	$02
		
		org		$12935							; Boss? Hitcount ($0A) [normal]
		dc.b 	$02
		org		$12943							; Boss? Hitcount ($14) [hard]
		dc.b 	$02
		; END CHEATS -----------------------------------------------------------------------------------------
		
		org		$9740							; SetStageSong
		jmp 	CustomPlaySound					; Overwrite jmp to PlaySound
		
		org 	$9750							; Array_StageMusicIDs --------------------
		dc.b 	$D3								; Overwrite Level 2-Boss SoundID $9F->$D3
		org 	$9753
		dc.b 	$D9								; Overwrite Level 3-3 SoundID $8C->$D9
		org 	$9754
		dc.b 	$D6								; Overwrite Level 3-Boss SoundID $9F->$D6
		org 	$975E
		dc.b 	$D5								; Overwrite Level 4-Boss SoundID $9F->$D5
		org 	$9760
		dc.b 	$D8								; Overwrite Level 5-S SoundID $96->$D8
		org 	$9762
		dc.b 	$D7								; Overwrite Level 5-Boss SoundID $9F->$D5
		
		org 	$9810							; PauseGame:
		jsr 	PauseGame
		
		org 	$9D55
		dc.b 	$D4								; Overwrite Sound Code D1 to D4 (SEGA LOGO)
		org 	$9D58 							; GM_Init (SEGA LOGO)
		jsr 	CustomPlaySound
		
		org		$9D96							; GM_OpeningInit: Sound Code $81
		jmp 	CustomPlaySound					; Overwrite jmp to PlaySound
		
		org 	$9DE3							; GM_OpeningLoop: Sound Code $D1
		dc.b 	$D2								; Overwrite SoundCode
		
		org		$9DE6							; TITLE SCREEN, GM_OpeningLoop: Sound Code $D1
		;jsr 	pause_fade_track				; Fade out Prologue sound
		jsr 	CustomPlaySound					; Overwrite jmp to PlaySound
		
		org		$A01A
		;nop
		;nop
		;nop	
		
		org		$A024							; GM_SoundTestLoop
		jsr 	CustomPlaySound					; Overwrite jmp to PlaySound
		
		org 	$A02A
back_to_SoundTestLoop
		nop										; enable Stage Selection <---------------------------- CHEAT
		
		org		$A27E							; GM_OutsideCastle: Sound Code $9E
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$B018							; player_killed: Sound Code $8A
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		; Diamonds:------------------------------
		org		$14B8							; Level ? Diamond: Sound Code $99
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org 	$1173E							; Level ? Diamond: Sound Code $99
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$121D4							; Level 1 Diamond: Sound Code $99
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$12BAE							; Level ? Diamond: Sound Code $99
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$13588							; Level ? Diamond: Sound Code $99
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org		$13F68							; Level ? Diamond: Sound Code $99
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		; ---------------------------------------
		
		org 	$7B7A8							; Rainbow Bridge: Sound Code $9C
		bra 	CustomPlaySound
		
		org 	$109BE							; sub_109B2: Mizrabel Defeated: Sound Code $9B
		jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
		
		org 	$7AA90							; GM_StageClearInit; calls function in RAM $FF8A
		jsr 	Level_Clear						; Level Complete
			
		org 	$7A5A4							; GM_StageClearInit; calls function in RAM $FF8A
		jsr 	Game_Over						; Game Over
			
		org 	$7AD38							; Castle Music $9E 	jumps to function in RAM $FF8A -> jmp PlaySound
		bra 	CustomPlaySound
		org 	$7B120							; Into Level, Doorclose SFX $BF	jumps to function in RAM $FF8A -> jmp PlaySound
		bra 	pause_fade_track_24
		org 	$7B14A							; After LevelClear, Out the door, Doorclose SFX $BF	jumps to function in RAM $FF8A -> jmp PlaySound
		bra 	CustomPlaySound
			
		org 	$80000
MSUDRV
		dc.b	$30,$3C,$00,$01,$0C,$B9,$53,$45,$47,$41,$00,$40,$01,$00,$66,$00,$00,$5E,$13,$FC,$00,$02,$00,$A1,$20,$01,$08,$39,$00,$01,$00,$A1,$20,$01,$13,$FC,$00,$00,$00,$A1,$20,$03,$20,$7C,$00,$00,$00,$34,$22,$7C,$00,$42,$00,$00,$30,$3C,$03,$62,$32,$FB,$88,$00,$54,$48,$51,$C8,$FF,$F8,$13,$FC,$00,$00,$00,$A1,$20,$0F,$13,$FC,$00,$01,$00,$A1,$20,$01,$10,$39,$00,$A1,$20,$01,$02,$00,$00,$01,$67,$00,$FF,$F4,$13,$FC,$00,$00,$00,$A1,$20,$02,$30,$3C,$00,$00,$4E,$75,$00,$00,$00,$00,$00,$00,$00,$7C,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$A0,$00,$00,$00,$90,$00,$00,$00,$A0,$00,$00,$00,$A0,$2E,$7C,$00,$08,$00,$00,$46,$FC,$20,$00,$4E,$F9,$00,$00,$03,$2A,$4E,$FA,$FF,$EE,$48,$E7,$C0,$C0,$4E,$B9,$00,$00,$05,$8C,$4C,$DF,$03,$03,$4E,$73,$4E,$73,$00,$00,$12,$2F,$00,$07,$10,$39,$00,$07,$01,$AD,$66,$F8,$13,$C1,$00,$07,$01,$AC,$23,$EF,$00,$08,$00,$07,$01,$A8,$13,$FC,$00,$01,$00,$07,$01,$AD,$4E,$75,$59,$4F,$2F,$02,$22,$2F,$00,$0C,$4A,$01,$67,$54,$30,$39,$00,$07,$01,$A6,$E4,$48,$24,$00,$E1,$8A,$02,$82,$00,$3F,$FF,$00,$42,$A7,$1F,$41,$00,$03,$2F,$02,$4E,$B9,$00,$00,$06,$50,$50,$8F,$20,$40,$B0,$82,$62,$2C,$22,$79,$00,$00,$06,$C0,$20,$02,$E0,$88,$E5,$48,$33,$40,$00,$34,$94,$88,$1F,$79,$00,$07,$01,$AE,$00,$07,$12,$2F,$00,$07,$10,$39,$00,$07,$01,$AE,$B0,$01,$67,$F2,$B1,$C2,$63,$DA,$24,$1F,$58,$4F,$4E,$75,$12,$2F,$00,$0B,$20,$6F,$00,$04,$30,$2F,$00,$0E,$53,$40,$0C,$40,$FF,$FF,$67,$06,$10,$C1,$51,$C8,$FF,$FC,$4E,$75,$4E,$71,$2F,$02,$10,$2F,$00,$0B,$14,$00,$E8,$0A,$72,$00,$12,$02,$24,$01,$E7,$8A,$D4,$81,$D4,$81,$02,$00,$00,$0F,$D0,$02,$02,$80,$00,$00,$00,$FF,$24,$1F,$4E,$75,$48,$E7,$30,$20,$20,$2F,$00,$10,$74,$00,$26,$00,$42,$43,$48,$43,$2F,$00,$48,$78,$00,$02,$45,$FA,$FF,$1A,$4E,$92,$42,$A7,$42,$A7,$4E,$92,$4F,$EF,$00,$10,$42,$A7,$42,$A7,$4E,$92,$50,$8F,$B6,$39,$00,$07,$01,$B3,$66,$F0,$42,$41,$E9,$8A,$70,$00,$30,$01,$41,$F9,$00,$07,$01,$B2,$84,$30,$08,$02,$52,$41,$0C,$41,$00,$05,$63,$E8,$20,$02,$4C,$DF,$04,$0C,$4E,$75,$48,$E7,$30,$38,$20,$79,$00,$00,$06,$C0,$11,$7C,$00,$00,$00,$01,$20,$79,$00,$00,$06,$C0,$10,$BC,$00,$02,$48,$78,$00,$0C,$42,$A7,$48,$79,$00,$07,$01,$A6,$45,$FA,$FF,$3C,$4E,$92,$48,$78,$01,$9C,$42,$A7,$48,$79,$00,$07,$00,$0A,$4E,$92,$33,$FC,$40,$00,$00,$07,$01,$A6,$4F,$EF,$00,$18,$20,$79,$00,$00,$06,$C0,$10,$28,$00,$01,$08,$00,$00,$00,$67,$F6,$11,$7C,$00,$10,$00,$33,$20,$79,$00,$00,$06,$C0,$31,$7C,$00,$04,$00,$36,$74,$0F,$42,$A7,$42,$A7,$47,$FA,$FE,$6A,$4E,$93,$50,$8F,$53,$42,$6A,$F0,$2F,$3C,$00,$04,$00,$00,$48,$78,$00,$02,$4E,$93,$50,$8F,$74,$2F,$42,$A7,$42,$A7,$4E,$93,$50,$8F,$53,$42,$6A,$F4,$2F,$3C,$00,$04,$00,$00,$49,$FA,$FF,$0A,$4E,$94,$10,$39,$00,$07,$01,$B6,$E9,$88,$02,$80,$00,$00,$0F,$F0,$80,$39,$00,$07,$01,$B7,$42,$A7,$1F,$40,$00,$03,$61,$00,$FE,$C4,$72,$00,$12,$00,$23,$C1,$00,$07,$00,$0A,$36,$3C,$01,$00,$42,$42,$50,$8F,$4A,$81,$67,$54,$20,$02,$E5,$88,$02,$80,$00,$03,$FF,$FC,$24,$40,$D5,$FC,$00,$07,$00,$0A,$20,$03,$02,$80,$00,$05,$FF,$FF,$00,$80,$00,$05,$00,$00,$2F,$00,$4E,$94,$25,$40,$00,$08,$58,$8F,$20,$03,$02,$80,$00,$00,$0F,$00,$32,$03,$06,$41,$07,$00,$0C,$80,$00,$00,$09,$00,$67,$04,$06,$41,$FA,$00,$36,$01,$52,$42,$42,$80,$30,$02,$B0,$B9,$00,$07,$00,$0A,$65,$AC,$2F,$3C,$00,$03,$00,$00,$61,$00,$FE,$76,$23,$C0,$00,$07,$00,$0E,$22,$02,$E5,$89,$02,$81,$00,$03,$FF,$FC,$20,$41,$D1,$FC,$00,$07,$00,$12,$20,$80,$42,$A7,$48,$78,$00,$02,$4E,$93,$4F,$EF,$00,$0C,$4C,$DF,$1C,$0C,$4E,$75,$59,$4F,$2F,$02,$20,$79,$00,$00,$06,$C0,$11,$7C,$00,$01,$00,$20,$61,$00,$FE,$8E,$20,$79,$00,$00,$06,$C0,$10,$BC,$00,$02,$20,$79,$00,$00,$06,$C0,$1F,$68,$00,$1F,$00,$07,$20,$79,$00,$00,$06,$C0,$11,$7C,$00,$00,$00,$20,$20,$79,$00,$00,$06,$C0,$12,$28,$00,$1F,$10,$2F,$00,$07,$B0,$01,$67,$F4,$1F,$68,$00,$1F,$00,$07,$11,$7C,$00,$02,$00,$20,$20,$79,$00,$00,$06,$C0,$10,$28,$00,$10,$0C,$00,$00,$15,$66,$16,$10,$28,$00,$11,$ED,$48,$02,$40,$3F,$C0,$33,$C0,$00,$07,$01,$A6,$31,$40,$00,$34,$60,$B0,$14,$28,$00,$10,$70,$00,$10,$02,$72,$13,$B2,$80,$67,$52,$6D,$0A,$12,$3C,$00,$11,$B2,$80,$6E,$98,$60,$08,$72,$14,$B2,$80,$67,$6C,$60,$8E,$10,$28,$00,$11,$53,$00,$13,$C0,$00,$07,$01,$AF,$E5,$88,$02,$80,$00,$00,$03,$FC,$20,$40,$D1,$FC,$00,$07,$00,$0A,$2F,$28,$00,$08,$48,$78,$00,$03,$61,$00,$FC,$B8,$20,$79,$00,$00,$06,$C0,$31,$79,$00,$07,$01,$A6,$00,$34,$13,$C2,$00,$07,$01,$B0,$60,$44,$10,$28,$00,$11,$42,$A7,$1F,$40,$00,$03,$61,$00,$FC,$B8,$20,$79,$00,$00,$06,$C0,$31,$7C,$00,$00,$00,$34,$42,$A7,$48,$78,$00,$06,$61,$00,$FC,$7E,$4F,$EF,$00,$0C,$60,$00,$FF,$26,$42,$A7,$48,$78,$00,$07,$61,$00,$FC,$6C,$20,$79,$00,$00,$06,$C0,$31,$79,$00,$07,$01,$A6,$00,$34,$50,$8F,$60,$00,$FF,$08,$4E,$71,$2F,$02,$22,$2F,$00,$0C,$41,$F9,$00,$07,$00,$00,$13,$EF,$00,$0B,$00,$07,$00,$00,$42,$39,$00,$07,$00,$01,$42,$39,$00,$07,$00,$08,$20,$01,$42,$40,$48,$40,$E8,$48,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$02,$20,$01,$42,$40,$48,$40,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$03,$20,$01,$74,$0C,$E4,$A8,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$04,$20,$01,$E0,$88,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$05,$20,$01,$E8,$88,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$06,$02,$01,$00,$0F,$13,$C1,$00,$07,$00,$07,$42,$39,$00,$07,$00,$09,$42,$41,$70,$00,$30,$01,$10,$30,$08,$00,$D0,$39,$00,$07,$00,$09,$13,$C0,$00,$07,$00,$09,$52,$41,$0C,$41,$00,$08,$63,$E4,$0A,$00,$00,$0F,$02,$00,$00,$0F,$13,$C0,$00,$07,$00,$09,$24,$1F,$4E,$75,$2F,$02,$74,$00,$41,$F9,$00,$07,$01,$B2,$0C,$39,$00,$01,$00,$07,$01,$B2,$66,$76,$4A,$39,$00,$07,$01,$B3,$66,$6E,$42,$41,$E9,$8A,$70,$00,$30,$01,$84,$30,$08,$02,$52,$41,$0C,$41,$00,$05,$63,$EE,$12,$39,$00,$07,$01,$AF,$20,$01,$E5,$88,$02,$80,$00,$00,$03,$FC,$20,$40,$D1,$FC,$00,$07,$00,$16,$20,$10,$55,$80,$B0,$82,$62,$3A,$4A,$39,$00,$07,$00,$00,$66,$32,$43,$FA,$FB,$4C,$0C,$39,$00,$12,$00,$07,$01,$B0,$66,$1A,$20,$01,$E5,$88,$02,$80,$00,$00,$03,$FC,$20,$40,$D1,$FC,$00,$07,$00,$12,$2F,$10,$48,$78,$00,$03,$60,$06,$42,$A7,$48,$78,$00,$06,$4E,$91,$50,$8F,$24,$1F,$4E,$75,$43,$F9,$00,$07,$01,$B2,$20,$79,$00,$00,$06,$C0,$30,$28,$00,$36,$08,$00,$00,$01,$66,$F6,$33,$E8,$00,$38,$00,$07,$01,$B2,$33,$68,$00,$3A,$00,$02,$33,$68,$00,$3C,$00,$04,$33,$68,$00,$3E,$00,$06,$33,$68,$00,$40,$00,$08,$10,$39,$00,$07,$01,$AD,$41,$FA,$FE,$86,$67,$1C,$2F,$39,$00,$07,$01,$A8,$70,$00,$10,$39,$00,$07,$01,$AC,$2F,$00,$4E,$90,$13,$FC,$00,$00,$00,$07,$01,$AD,$60,$06,$42,$A7,$42,$A7,$4E,$90,$50,$8F,$20,$79,$00,$00,$06,$C0,$31,$79,$00,$07,$00,$00,$00,$42,$31,$79,$00,$07,$00,$02,$00,$44,$31,$79,$00,$07,$00,$04,$00,$46,$31,$79,$00,$07,$00,$06,$00,$48,$31,$79,$00,$07,$00,$08,$00,$4A,$0C,$39,$00,$01,$00,$07,$01,$B2,$66,$08,$10,$10,$00,$00,$00,$01,$60,$06,$10,$10,$02,$00,$FF,$FE,$10,$80,$61,$00,$FE,$C2,$10,$39,$00,$07,$01,$AE,$52,$00,$13,$C0,$00,$07,$01,$AE,$4E,$75,$00,$00,$2F,$02,$22,$2F,$00,$0C,$20,$2F,$00,$08,$0C,$81,$00,$01,$00,$00,$64,$16,$24,$00,$42,$42,$48,$42,$84,$C1,$30,$02,$48,$40,$34,$2F,$00,$0A,$84,$C1,$30,$02,$60,$30,$24,$01,$E2,$89,$E2,$88,$0C,$81,$00,$01,$00,$00,$64,$F4,$80,$C1,$02,$80,$00,$00,$FF,$FF,$22,$02,$C2,$C0,$48,$42,$C4,$C0,$48,$42,$4A,$42,$66,$0A,$D2,$82,$65,$06,$B2,$AF,$00,$08,$63,$02,$53,$80,$24,$1F,$4E,$75,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4E,$75,$4E,$75,$00,$FF,$80,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$4E,$75,$4E,$75
		
		
		org 	$80750
CustomPlaySound
		tst.b 	b_cd_audio						; is CD Audio enabled?
		beq.s 	passthrough						; branch if not
		btst 	#$6,HW_version.l 				; Check for PAL or NTSC, 0=60Hz, 1=50Hz
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
		sf		b_cd_audio					; Clear CD Audio enabled var
		sf 		TrackToPlay					; Clear Last CD track played var
		tst.w	d0							; if 0: no CD Hardware found
		beq		audio_init_fail				; Return without setting CD enabled
		move.b 	#$FF,(b_cd_audio).w			; set CD enabled to RAM
		move.w 	#($1500|255),MCD_CMD		; Set CD Volume to MAX
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
audio_init_fail
		rts
		

passthrough
		jmp 	PlaySound					; jump back to original function
		

find_track
		move.b 	(CurrentSoundID).w,d0		; get (CurrentSoundID) for compare
		move.b 	d0,(TrackToPlay).w			; save last played Track
		
		cmp.b 	#$D1,d0
		beq 	pause_fade_track			; TODO: maybe problematic in SoundTest Mode
		
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
		cmp.b 	#$D4,d0
		beq 	play_track_26
		cmp.b 	#$D2,d0
		beq 	play_track_27
		cmp.b 	#$D3,d0
		beq 	play_track_28
		cmp.b 	#$D5,d0
		beq 	play_track_29
		cmp.b 	#$D6,d0
		beq 	play_track_30
		cmp.b 	#$D7,d0
		beq 	play_track_31
		cmp.b 	#$D8,d0
		beq 	play_track_32
		cmp.b 	#$D9,d0
		beq 	play_track_33
break
		rts
		
play_track_1								; Prologue
		jsr 	mute_chipmusic
		move.w 	#($1100|1),MCD_CMD 			; send cmd: play track #1, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_2								; Stage 1-1
		jsr 	mute_chipmusic
		move.w 	#($1200|2),MCD_CMD 			; send cmd: play track #2, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_3								; Substage
		jsr 	mute_chipmusic
		move.w 	#($1200|3),MCD_CMD 			; send cmd: play track #3, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_4								; Stage 1-2
		jsr 	mute_chipmusic
		move.w 	#($1200|4),MCD_CMD 			; send cmd: play track #4, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_5								; Stage 1-Rolling Apple
		jsr 	mute_chipmusic
		move.w 	#($1100|5),MCD_CMD 			; send cmd: play track #5, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_6								; Stage 2-1
		jsr 	mute_chipmusic
		move.w 	#($1200|6),MCD_CMD 			; send cmd: play track #6, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_7								; Stage 2-2 (Dash)
		jsr 	mute_chipmusic
		move.w 	#($1100|7),MCD_CMD 			; send cmd: play track #7, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_8								; Stage 2-1 (Intro Variant)
		jsr 	mute_chipmusic
		move.w 	#($1200|8),MCD_CMD 			; send cmd: play track #8, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_9								; Stage 2-3
		jsr 	mute_chipmusic
		move.w 	#($1200|9),MCD_CMD 			; send cmd: play track #9, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_10								; Stage 3-1
		jsr 	mute_chipmusic
		move.w 	#($1200|10),MCD_CMD 		; send cmd: play track #10, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_11								; Stage 3-2
		jsr 	mute_chipmusic
		move.w 	#($1200|11),MCD_CMD 		; send cmd: play track #11, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_12								; Stage 4-1
		jsr		mute_chipmusic
		move.w 	#($1200|12),MCD_CMD 		; send cmd: play track #12, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_13								; Stage 4-2
		jsr 	mute_chipmusic
		move.w 	#($1200|13),MCD_CMD 		; send cmd: play track #13, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_14								; Stage 5-1
		jsr 	mute_chipmusic
		move.w 	#($1200|14),MCD_CMD 		; send cmd: play track #14, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_15								; Stage 5-2
		jsr 	mute_chipmusic
		move.w 	#($1200|15),MCD_CMD 		; send cmd: play track #15, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_16								; Stage Clear
		jsr 	mute_chipmusic
		move.w 	#($1100|16),MCD_CMD 		; send cmd: play track #16, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		move.w 	(CurrentGM).w,d0			; get current game mode
		cmp.b 	#$0A,d0						; $0A = Sound Test
		beq 	track_16_soundtest_handler
		dc.b 	$4E,$B8,$FF,$8A				; jump back
track_16_soundtest_handler
		rts
play_track_17								; Lost a Life
		jsr 	mute_chipmusic
		move.w 	#($1100|17),MCD_CMD 		; send cmd: play track #17, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_18								; Staff Roll
		jsr 	mute_chipmusic
		move.w 	#($1100|18),MCD_CMD 		; send cmd: play track #18, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_19								; Diamond
		jsr 	mute_chipmusic
		move.w 	#($1100|19),MCD_CMD 		; send cmd: play track #19, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_20								; Final Boss
		jsr 	mute_chipmusic
		move.w 	#($1200|20),MCD_CMD 		; send cmd: play track #20, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_21								; Ending
		jsr 	mute_chipmusic
		move.w 	#($1100|21),MCD_CMD 		; send cmd: play track #21, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_22								; Rainbow
		jsr 	mute_chipmusic
		move.w 	#($1100|22),MCD_CMD 		; send cmd: play track #22, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		;dc.b 	$4E,$B8,$FF,$8A				; jump back
		jmp 	$7B7AC
play_track_23								; Game Over
		jsr 	mute_chipmusic
		move.w 	#($1100|23),MCD_CMD 		; send cmd: play track #23, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_24								; Castle
		jsr 	mute_chipmusic
		move.w 	(CurrentScene).w,d0			; get current game mode
		move.w 	#($1100|24),MCD_CMD 		; send cmd: play track #24, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		cmp.b 	#$05,d0						; $05 = Castle Doors Scenes after the first Level (without Monk)
		beq 	track_24_return
		rts
track_24_return
		;dc.b 	$4E,$B8,$FF,$8A				; jump back
		jmp 	$7AD3C
play_track_25								; Boss Level 1
		jsr 	mute_chipmusic
		move.w 	#($1200|25),MCD_CMD 		; send cmd: play track #25, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_26								; SEEEGAAAA
		jsr 	mute_chipmusic
		move.w 	#($1100|26),MCD_CMD 		; send cmd: play track #26, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_27								; Title - Castle of Illusion (voice)
		jsr 	mute_chipmusic
		move.w 	#($1100|27),MCD_CMD 		; send cmd: play track #27, no loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_28								; BOSS - Level 2 - Jack in the Box
		jsr 	mute_chipmusic
		move.w 	#($1200|28),MCD_CMD 		; send cmd: play track #28, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_29								; BOSS - Level 4 - Candydragon
		jsr 	mute_chipmusic
		move.w 	#($1200|29),MCD_CMD 		; send cmd: play track #29, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_30								; BOSS - Level 3 - Aquamen
		jsr 	mute_chipmusic
		move.w 	#($1200|30),MCD_CMD 		; send cmd: play track #30, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_31								; BOSS - Level 5 - Hunchback
		jsr 	mute_chipmusic
		move.w 	#($1200|31),MCD_CMD 		; send cmd: play track #31, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_32								; Stage 5-2-1 Castle Underwater Passage
		jsr 	mute_chipmusic
		move.w 	#($1200|32),MCD_CMD 		; send cmd: play track #32, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
play_track_33								; Stage 3-3 Ruins Rising Water
		jsr 	mute_chipmusic
		move.w 	#($1200|33),MCD_CMD 		; send cmd: play track #33, loop
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts


pause_fade_track
		move.w 	#($1300|150),MCD_CMD 		; send cmd: fade track 2sec
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
		
pause_track
		move.w 	#($1300|0),MCD_CMD 			; send cmd: pause track
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts

pause_fade_track_24							; Castle Doors Music
		move.w 	#($1300|100),MCD_CMD 		; send cmd: fade track 1,33sec
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		dc.b 	$4E,$B8,$FF,$8A				; jump back
		rts
		
resume_track
		move.w 	#$1400,MCD_CMD 				; send cmd: resume
		addq.b 	#1,MCD_CMD_CK 				; Increment command clock
		rts
		
Level_Clear
		move.b  #$89,(CurrentSoundID).w
		clr.l 	d0
		move.b 	(CurrentSoundID).w,d0
		jsr 	CustomPlaySound
		rts

Game_Over
		move.b  #$9D,(CurrentSoundID).w
		clr.l 	d0
		move.b 	(CurrentSoundID).w,d0
		jsr 	CustomPlaySound
		rts


mute_chipmusic
		move.w 	(CurrentGM).w,d0			; get current game mode
		cmp.b 	#$0A,d0						; $0A = Sound Test
		beq 	jump_back_to_SoundTestLoop
		move.b  #$00,(CurrentSoundID).w		; Mute Chipmusic
		rts

jump_back_to_SoundTestLoop
		move.b 	(CurrentSoundID).w,d0
		jmp back_to_SoundTestLoop

PauseGame
		nop
		nop
		nop
		tst.b   (EnablePauseFlag).w 		; Test if paused
		bne.s   mute_while_paused
		jsr 	resume_track
		rts
mute_while_paused
		jsr 	pause_track
		rts

;GM_Array:;;;;;;;;;;;;;;;@FF:F300
;GM_Init            	; 00
;GM_SegaLoop_j      	; 02
;GM_OpeningInit     	; 04
;GM_OpeningLoop     	; 06
;GM_InitSoundTest   	; 08
;GM_SoundTestLoop   	; 0A
;GM_StageInit       	; 0C
;GM_StageLoop       	; 0E
;GM_StageInverter   	; 10
;GM_TitleLoop       	; 12
;GM_EndingInit      	; 14
;GM_Ending          	; 16
;GM_GameOverInit_j  	; 18
;GM_GameOverLoop_j  	; 1A
;GM_CopyrightInit_j 	; 1C
;GM_CopyrightLoop_j 	; 1E
;GM_InitCastleLoop_j 	; 20
;GM_CastleLoop_j    	; 22
;GM_StageClearInit_j 	; 24
;GM_StageClearLoop_j 	; 26
;GM_OutsideCastle   	; 28
;sub_A286           	; 2A
;GM_CastleEscapeInit 	; 2C
;GM_CastleEscapeLoop 	; 2E

