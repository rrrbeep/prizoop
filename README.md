![Options Screen](/Screens/Options.png?raw=true)

Prizoop
=======

Prizoop is a Game Boy and Game Boy Color emulator for the Casio Prizm series graphing calculator, with intense focus on optimization and decent feature set for the target device. As such, it is not a very accurate emulator but is very fast and compatible. The emulator now supports fx-CG10, fx-CG20, and the new fx-CG50. 

It got its name because it started out as a fork of the multiplatform Game Boy emulator, Cinoop, by CTurt. It has since undergone an almost total rewrite and shares some of the cpu code, organization and constructs from Cinoop, but for the most part resembles Cinoop much less than a normal fork.

## Install

Copy the prizoop.g3a file to your Casio Prizm calculator's root path when linked via USB. Gameboy and Gameboy Color roms (.gb and .gbc) also should go inside of the root directory. The filenames for these files should be simple and less than 8 characters, such as MyGame.gbc. 

Additionally, Windows users can compress a .gb and .gbc ROM file into a smaller .gbz file that is also compatible, though the game will be slightly slower when starting a new level, etc due to needing to decompress data on the fly. Some games such as Ghosts and Goblins will compress to ~10% of their original size, enabling you to have a much larger library on your calculator. To compress a ROM file, simply run comp-gb.exe and select the ROM to compress. The tool will automatically create a .gbz file in the same folder.

## Support

![Game Banner](/Screens/GameBanner.png?raw=true)

The emulator now plays over 95% of the games I have been able to test smoothly at this point. Some games where timing accuracy is very important suffer, specifically racing games. Road Rash and F1 Race are playable but have some visual issues, and F1 Pole Position does not play at all. Pokemon Rouge (the French Pokemon Red) now officially works.

The emulator does not yet support real time clock based games such as Pokemon Crystal.

## Sound

The emulator has full support for sound, though it is somewhat limited due to the 1-bit nature of the Prizm serial port. If you have a 2.5 mm to 3.5 mm headphone adapter, you can enjoy low-lag sound with a decent frequency range in one earphone (left or right, depending on the adaptor). Some adaptors seem to have different voltage output, so you may get some distortion or unusually high volume. Volume and distortion can be simultaneously adjusted with the + and - keys.

## Building

Project root must be within /projects directory of publicly available community SDK v0.3 for Prizm. The SDK must be patched with the latest version of libFXCG as well which has the latest syscalls defined. To build on a Windows machine simply run make.bat. For other systems please refer to your Prizm SDK documentation on how to compile projects.

If you use Visual Studio, a project is included that uses a Windows Simulator I wrote that wraps Prizm OS functions so that the code and emulator can easily be tested and iterated on within Visual Studio. See the prizmsim.cpp/h code for details on its usage.

## Usage

In the menu system use the arrow keys and SHIFT to select.

F1 - Select ROM
F2 - Settings (most are self explanatory)
F6 - Play ROM (it will first show diagnostic information)

When inside a game, the MENU key will exit to the settings screen, and pressing MENU again will take you back to the calculator OS.

A single save state is supported per ROM, which can be loaded/saved using the remappable keys mentioned in the Controls section.

### Prizm Controls

You can configure your own keys in the Settings menu, these are the default I found to work well:

- B: OPTN
- A: SHIFT
- Select: F5
- Start: F6
- Dpad : Dpad
- Save State : X (multiply), which is the alpha 's' key for save
- Load State : -> (store), which is the alpha 'l' key for load
- Increase Volume/Distortion : + 
- Decrease Volume/Distortion : -

## Special Thanks

BGB was a huge part of bug fixing and obtaining great ROM compatibility. It is a Gameboy emulator with great debugging and memory visualization tools:
http://bgb.bircd.org/

A huge special thanks obviously goes to CTurt, who's simple explanations and easy to read source got this project rolling by making it seem much less scary. See the original Cinoop source code here:
https://github.com/CTurt/Cinoop
