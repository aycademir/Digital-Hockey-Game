# Digital-Hockey-Game

## Overview
This Verilog code implements a simplified version of a hockey game on an FPGA (Field-Programmable Gate Array). The game consists of two players (A and B) controlling their respective players on the field to hit a puck towards the opponent's goal.

## Module Inputs
clk: Clock signal.
rst: Reset signal.
BTN_A: Input signal representing player A's button press.
BTN_B: Input signal representing player B's button press.
DIR_A: Direction signal for player A's movement.
DIR_B: Direction signal for player B's movement.
Y_in_A: Y-coordinate input signal for player A.
Y_in_B: Y-coordinate input signal for player B.

## Module Outputs
LEDA: Output indicating player A's turn.
LEDB: Output indicating player B's turn.
LEDX: Output indicating the X-coordinate of the puck.
SSD7-SSD0: Seven-segment display outputs for score display and game state.
Functionality
The code implements a finite state machine (FSM) to manage the game states and player actions. It includes the following states:

- IDLE: Initial state where both players are inactive.
- DISP: State for displaying game information before starting.
- HIT_B: Player B's turn to hit the puck.
- SEND_A: Player A's turn to send the puck back.
- RESP_A: Player A's response to the puck sent by B.
- GOAL_B: Goal state when B scores.
- HIT_A: Player A's turn to hit the puck.
- SEND_B: Player B's turn to send the puck back.
- RESP_B: Player B's response to the puck sent by A.
- GOAL_A: Goal state when A scores.
- END_STATE: End game state with blinking LEDs.
The module utilizes LED outputs to indicate game states and SSDs to display scores and game information. Players control their actions using buttons (BTN_A and BTN_B) and direction signals (DIR_A and DIR_B).

## Design Considerations
The game is turn-based, with each player taking alternate hits.
Scores are displayed on SSDs, and game states are indicated through LEDs.
There are constraints on time intervals for various game actions, controlled by the timer.
Goal detection and scoring update logic are implemented for both players.

## Note
This readme provides an overview of the code functionality and design. Further details on specific game rules and implementation details can be found by examining the Verilog code itself.
