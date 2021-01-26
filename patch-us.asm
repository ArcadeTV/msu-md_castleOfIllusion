; Build setup
PRODUCTION  set 1                           ; set to 0 for GENS compatibility (for debugging) and 1 when ready
CHEAT       set 0                           ; set to 1 for cheat enabled

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
        
    org $4
    dc.l 	$90000							; custom entry point for redirecting
    
    org 	$1A4							; ROM_END
    dc.l 	$002FFFFF						; Overwrite with 8 MBIT size
    
    org 	$300							; original entry point, after reset-checks ($200 present in the header)
Game

    org 	$324							; Beginning of checksum-check function
    jmp 	audio_init						; Call MSU-MD init


    org 	$346							; only for Label
ResumeAfterChecksumCheck

    org 	$1F0							; COUNTRY CODES
    dc.b	"JU   "							; Overwrite "JAPAN" with JUE
    
    
    org 	$79F86							; only for Label
PlaySound

    org 	$7A4AA;us						; only for Label
GM_SegaLoop
    

;		HIJACKING PlaySound Calls in different Game Modes:
;		TrackNo to SoundCode:
;		01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 | 26 | 27 28 29 30 31 32 33
;		81 82 83 84 86 87 93 94 88 8B 8C 8E 91 96 98 89 8A 90 99 9A 9B 9C 9D 9E 9F | D1 | D2 D3 D5 D6 D7 D8 D9
    
    org		$84a;us							; Stage 2-1 Dash: Sound Code $93
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$89FA;us						; Staff Roll: Sound Code $90
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$1752;us						; Apple Dash: Sound Code $86
    jsr 	CustomPlaySound					; Overwrite jmp to PlaySound
    
    ; CHEATS ---------------------------------------------------------------------------------------------

    if CHEAT
    org 	$92F4;us
    subq.w  #0,($F322).w					; CHEAT -> don't descrease Energy
    
    org		$11DC7;us						; Tree Hitcount ($0A) [normal]
    ;dc.b 	$02
    org		$11DD2;us						; Tree Hitcount ($14) [hard]
    ;dc.b 	$02
    
    org		$1280D;us						; Boss 2 Hitcount ($0A) [normal]
    ;dc.b 	$02
    org		$1281B;us						; Boss 2 Hitcount ($14) [hard]
    ;dc.b 	$02
    endif

    ; END CHEATS -----------------------------------------------------------------------------------------
    
    org		$96A8;us						; SetStageSong
    jmp 	CustomPlaySound					; Overwrite jmp to PlaySound
    
    org 	$96B8;us						; Array_StageMusicIDs --------------------
    dc.b 	$D3								; Overwrite Level 2-Boss SoundID $9F->$D3
    org 	$96BB;us
    dc.b 	$D9								; Overwrite Level 3-3 SoundID $8C->$D9
    org 	$96BC;us
    dc.b 	$D6								; Overwrite Level 3-Boss SoundID $9F->$D6
    org 	$96C6;us
    dc.b 	$D5								; Overwrite Level 4-Boss SoundID $9F->$D5
    org 	$96C8;us
    dc.b 	$D8								; Overwrite Level 5-S SoundID $96->$D8
    org 	$96CA;us
    dc.b 	$D7								; Overwrite Level 5-Boss SoundID $9F->$D5
    
    org 	$9778;us						; PauseGame:
    jsr 	PauseGame
    
    org 	$9C97;us
    dc.b 	$D4								; Overwrite Sound Code D1 to D4 (SEGA LOGO)
    org 	$9C9A;us						; GM_Init (SEGA LOGO)
    jsr 	CustomPlaySound
    
    org		$9CD8;us						; GM_OpeningInit: Sound Code $81
    jmp 	CustomPlaySound					; Overwrite jmp to PlaySound
    
    org 	$9D25;us						; GM_OpeningLoop: Sound Code $D1
    dc.b 	$D2								; Overwrite SoundCode
    
    org		$9D28;us						; TITLE SCREEN, GM_OpeningLoop: Sound Code $D1
    ;jsr 	pause_fade_track				; Fade out Prologue sound
    jsr 	CustomPlaySound					; Overwrite jmp to PlaySound
    
    org		$9F5C;us
    ;nop
    ;nop
    ;nop	
    
    org		$9F66;us						; GM_SoundTestLoop
    jsr 	CustomPlaySound					; Overwrite jmp to PlaySound
    
    org 	$9F6C;us
back_to_SoundTestLoop
    if CHEAT
    nop										; enable Stage Selection <---------------------------- CHEAT
    endif

    org		$A1C0;us						; GM_OutsideCastle: Sound Code $9E
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$AF10;us						; player_killed: Sound Code $8A
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    ; Diamonds:---------------------------------------------------------------------
    org		$14B2;us						; Level ? Diamond: Sound Code $99
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org 	$11616;us						; Level ? Diamond: Sound Code $99
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$120AC;us						; Level 1 Diamond: Sound Code $99
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$12A86;us						; Level ? Diamond: Sound Code $99
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$13460;us						; Level ? Diamond: Sound Code $99
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org		$13E40;us						; Level ? Diamond: Sound Code $99
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    ; ------------------------------------------------------------------------------
    
    org 	$7B7AA;us						; Rainbow Bridge: Sound Code $9C
    bra 	CustomPlaySound
    
    org 	$10896;us						; sub_109B2: Mizrabel Defeated: Sound Code $9B
    jsr 	CustomPlaySound					; Overwrite jsr to PlaySound
    
    org 	$7AA9C;us						; GM_StageClearInit; calls function in RAM $FF8A
    jsr 	Level_Clear						; Level Complete
        
    org 	$7A5B0;us						; GM_StageClearInit; calls function in RAM $FF8A
    jsr 	Game_Over						; Game Over
        
    org 	$7AD3A;us						; Castle Music $9E 	jumps to function in RAM $FF8A -> jmp PlaySound
    bra 	CustomPlaySound
    org 	$7B122;us						; Into Level, Doorclose SFX $BF	jumps to function in RAM $FF8A -> jmp PlaySound
    bra 	pause_fade_track_24
    org 	$7B14C;us						; After LevelClear, Out the door, Doorclose SFX $BF	jumps to function in RAM $FF8A -> jmp PlaySound
    bra 	CustomPlaySound
        
    org 	$80000
MSUDRV
    incbin  "msu-drv.bin"        
    
    org 	$80750
CustomPlaySound
    tst.b 	(b_cd_audio).w				; is CD Audio enabled?
    beq.s 	passthrough					; branch if not
    
ready
    tst.b 	MCD_STAT
    bne.s 	ready 						; Wait for Driver ready to receive cmd
    jsr 	find_track
    rts 								; Return to regular game code
    
audio_init
    jsr 	MSUDRV
    nop
    nop
    nop
    
    if PRODUCTION
    tst.b	d0							; if 1: no CD Hardware found
    bne		audio_init_fail				; Return without setting CD enabled
    endif

    sf		b_cd_audio					; Clear CD Audio enabled var
    sf 		TrackToPlay					; Clear Last CD track played var
    move.b 	#$FF,(b_cd_audio).w			; set CD enabled to RAM
    move.w 	#($1500|255),MCD_CMD		; Set CD Volume to MAX
    addq.b 	#1,MCD_CMD_CK 				; Increment command clock
    jmp 	ResumeAfterChecksumCheck
audio_init_fail
    jmp 	lockout
    

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
    move.w 	(CurrentGM).w,d0			; get current game mode
    cmp.b 	#$0A,d0						; $0A = Sound Test
    beq 	track_24_soundtest_handler
    jmp 	$7B7AE;us					; jump back
track_24_soundtest_handler
    rts
    
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
    jmp 	$7AD3E;us
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
    move.w 	(CurrentGM).w,d0			; get current game mode
    cmp.b 	#$0A,d0						; $0A = Sound Test
    beq 	dontfade
    move.w 	#($1300|150),MCD_CMD 		; send cmd: fade track 2sec
    addq.b 	#1,MCD_CMD_CK 				; Increment command clock
    rts
dontfade
    move.w 	#($1300|0),MCD_CMD 			; send cmd: pause track
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
    move.w 	(CurrentGM).w,d0			; get current game mode
    cmp.b 	#$0A,d0						; $0A = Sound Test
    beq 	not_in_sound_test
    move.w 	#$1400,MCD_CMD 				; send cmd: resume
    addq.b 	#1,MCD_CMD_CK 				; Increment command clock
not_in_sound_test
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


    org 	$90000
ENTRY_POINT
    tst.w 	$00A10008  					; Test mystery reset (expansion port reset?)
    bne Main          					; Branch if Not Equal (to zero) - to Main
    tst.w 	$00A1000C  					; Test reset button
    bne Main          					; Branch if Not Equal (to zero) - to Main
Main
    move.b 	$00A10001,d0      			; Move Megadrive hardware version to d0
    andi.b 	#$0F,d0           			; The version is stored in last four bits, so mask it with 0F
    beq 	Skip                  		; If version is equal to 0, skip TMSS signature
    move.l 	#'SEGA',$00A14000 			; Move the string "SEGA" to 0xA14000
Skip
    btst 	#$6,(HW_version).l 			; Check for PAL or NTSC, 0=60Hz, 1=50Hz
    bne 	jump_lockout				; branch if != 0
    jmp 	Game
jump_lockout
    jmp 	lockout
    
    
    org 	$100000						; insert GFX and code for lockout screen
lockout
    incbin  "msuLockout.bin"