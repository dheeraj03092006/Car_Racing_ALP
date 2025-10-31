# Car Racing (Assembly)

Simple 16-bit DOS VGA car-racing demo written in x86 Assembly.

## Overview

This repository contains a small car-racing game implemented in 16-bit x86 assembly using BIOS/DOS interrupts and VGA mode 13h (320x200, 256 colors). The main source is `car341.asm`.

The program was written for a real-mode DOS environment (MASM/TASM style syntax, `.MODEL SMALL`) and uses INT 10h for graphics and INT 16h/21h for input and DOS services.

## Files

- `car341.asm` — Main assembly source implementing the game loop, rendering, input handling, collision, scoring, and exit behavior.

## Requirements

- A DOS real-mode environment (recommended: DOSBox) or a vintage DOS system.
- An assembler/linker that supports MASM/TASM-style 16-bit syntax (examples below use MASM or TASM/TLINK).

Note: Modern 64-bit Windows cannot run this binary natively. Use DOSBox (https://www.dosbox.com/) or a similar emulator.

## Build & Run (recommended: DOSBox)

Two common workflows are shown: using MASM or TASM inside DOSBox.

1. Place `car341.asm` in a folder (already at the repo root).

2. Start DOSBox and mount the folder as a drive. Example DOSBox commands (run inside DOSBox):

```
mount c d:\2-2_semister\Car_Racing_ALP
c:
```

3. Assemble & link using MASM (if available inside DOSBox):

```
masm car341.asm
link car341.obj
car341.exe
```

Or using TASM/TLINK:

```
tasm car341.asm
tlink car341.obj
car341.exe
```

You can also run DOSBox from PowerShell and pass commands directly. Example (if `dosbox` is in PATH):

```
# Example PowerShell one-liner (runs MASM inside DOSBox and executes)

dosbox -c "mount c d:\2-2_semister\Car_Racing_ALP" -c "c:" -c "masm car341.asm" -c "link car341.obj" -c "car341.exe" -c "exit"
```

If you don't have MASM/TASM inside DOSBox, copy the assembler/linker executables into the mounted folder or install a DOS assembler package inside your DOSBox environment.

## Controls

- W — Move up
- A — Move left
- S — Move down
- D — Move right
- ESC — Exit game

## Gameplay / Notes

- The code uses VGA mode 13h (INT 10h, AX=0x0013) and writes pixels directly to segment `0xA000`.
- Scores and lives are tracked in data variables. When the game ends the program switches back to text mode and displays the score and a category message.
- The program depends on BIOS/DOS interrupts and 16-bit addressing; it is not compatible with modern Win32/64 execution without an emulator.

## Limitations & Assumptions

- Assumes a 16-bit real-mode assembler (MASM/TASM syntax).
- Uses DOS interrupts (INT 10h/16h/21h) and will fail outside a DOS-compatible environment.
- Timing/delay uses busy loops and is not calibrated; speed will vary with the emulator or host.

## Modifying the Code

- Open `car341.asm` in any text editor. Look for procedures like `INIT_GAME`, `HANDLE_INPUT`, `UPDATE_GAME`, and `RENDER_GAME` to change behavior, controls, or graphics.

## Credits

Author: Soma Dheeraj (source file: `car341.asm` in this repo)

---

If you want, I can add an optional batch/script to launch DOSBox with the correct mount/build/run commands, or add small comments inside `car341.asm` to document key routines. Tell me which you'd prefer.
