# MSU-MD: CASTLE OF ILLUSION
Romhack for Sega Genesis/Mega Drive that adds CD audio to the game by using krikzz' MSU-MD driver

### Thanks and credits:

* [Dustin M. O'Dell](https://twitter.com/32mbit) who introduced me to s-record-patching, vasm and his asm for krikzz' msu-md-driver.
* [Krikzz](https://twitter.com/krikzz) for producing the [Mega Everdrive pro](https://krikzz.com/store/home/59-mega-everdrive-pro.html) and made his msu-md-driver [freely available](https://github.com/krikzz/msu-md).
* evilhamwizard for his valuable [notes](https://forums.sonicretro.org/index.php?threads/castle-of-illusion-j-crap.34919/) and [disassembly](https://www.mediafire.com/download/9f63iw0otlfsu26/castle+of+illusion+disassembly+11-2-2015.7z).


### Compatibility Goals
The final release of this patch shall keep compatibility on real hardware intact, either via Mega Everdrive pro or via cart/CD combo. 
Since the only Emulator I found this working on was [Kega Fusion](https://www.carpeludum.com/kega-fusion/) 3.64*, I'm only targeting real hardware.

*If the option "CartBootEnabled=1" is present in fusion.ini, load rom first, then cue.


### Build Requirements

I'm on Win10/64, so I can't tell you how to set things up for other OS'es.

* JAP version of the game rom (CRC:CE8333C6) padded to 8MBIT/1024Bytes/1MByte (typical name is Castle of Illusion - Fushigi no Oshiro Daibouken (Japan).md)
* [VASM](http://sun.hasenbraten.de/vasm/) ([vasmm68k_mot_win32.exe](http://www.alphatron.co.uk/vasm/)) <- Win-compiled by Rob
* [supertails66](https://github.com/suppertails66) [yuitools](https://github.com/suppertails66/yuitools) [srecpatch.exe](https://github.com/suppertails66/yuitools/blob/master/new_tools/srecpatch.exe)

Please see the wiki for further information
https://github.com/ArcadeTV/msu-md_castleOfIllusion/wiki


### Patching

Use the BPS patch file from the current release to patch your ROM.
I recommend [FLIPS](https://dl.smwcentral.net/11474/floating.zip). Please see the wiki page for a guide on patching.
