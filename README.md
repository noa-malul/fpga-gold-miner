# FPGA Gold Miner Game

Hardware implementation of the classic Gold Miner game using SystemVerilog,
running on an FPGA with VGA output.

## Demo
<img width="798" height="520" alt="image" src="https://github.com/user-attachments/assets/764d2923-0122-4920-a2d4-77d207c9a9ed" />
<img width="811" height="464" alt="image" src="https://github.com/user-attachments/assets/f83d4369-7bce-4a03-b41c-884562282b41" />
<img width="865" height="464" alt="image" src="https://github.com/user-attachments/assets/815df4ef-541c-4e2a-8825-3a9568011954" />
<img width="764" height="528" alt="image" src="https://github.com/user-attachments/assets/3887cc59-7e2b-493a-aa3d-1c976042d95c" />

## Features
- Real-time VGA rendering
- Player-controlled hook mechanic
- Score tracking and game logic in hardware

## Technologies
- SystemVerilog
- FPGA
- VGA protocol

## Architecture
<img width="1580" height="887" alt="image" src="https://github.com/user-attachments/assets/bec31147-7869-48a5-9f4e-993cd9bee2bd" />


## How to Run
1. Open the project in **Intel Quartus Prime**.
2. Compile the design using **Processing → Start Compilation**.
3. Connect and power the FPGA:
   - Connect the **DE1-SoC** board to your computer via USB.
   - Ensure the board is powered on.
4. Open **Programmer** in Quartus and upload the generated `.sof` file to the FPGA.
5. Connect external devices:
   - VGA monitor for video output
   - PS/2 keyboard for user input
   - Headphones or speakers for audio output (if supported)
6. Once programmed, the game will start automatically. Use the keyboard to play.
