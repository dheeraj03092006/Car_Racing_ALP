.MODEL SMALL
.STACK 100h
.DATA
    CAR_X           DW  160     ; Car X-coordinate
    CAR_Y           DW  150     ; Car Y-coordinate
    SPEED           DW  5       ; Movement speed
    SCREEN_WIDTH    DW  320     ; Screen width
    SCREEN_HEIGHT   DW  200     ; Screen height
    
    OBSTACLE_X      DW  100     ; Obstacle X-coordinate
    OBSTACLE_Y      DW  0       ; Obstacle Y-coordinate
    
    SCORE           DW  0       ; Player score
    LIVES           DB  3       ; Player lives
    GAME_OVER_FLAG  DB  0       ; Game over flag

    ; Keyboard status flags
    KEY_W           DB  0
    KEY_A           DB  0
    KEY_S           DB  0
    KEY_D           DB  0

    CAR_COLOR       DB  04h     ; Red car color
    OBSTACLE_COLOR  DB  02h     ; Green obstacle color
    BACKGROUND      DB  01h     ; Blue background

    PREV_CAR_X      DW  0
    PREV_CAR_Y      DW  0
    
    ; Winner message strings
    WINNER_BEGINNER   DB 'Beginner Driver$'
    WINNER_AMATEUR    DB 'Amateur Driver$'
    WINNER_EXPERT     DB 'Expert Driver$'
    WINNER_CHAMPION   DB 'Racing Champion$'
    WINNER_PREFIX     DB 'Score: $'

.CODE
MAIN PROC FAR
    ; Setup data segment
    MOV AX, @DATA
    MOV DS, AX

    ; Set video mode (320x200 graphics mode)
    MOV AX, 0013h
    INT 10h

    ; Initialize game
    CALL INIT_GAME

    ; Main game loop
GAME_LOOP:
    ; Clear previous frame
    CALL CLEAR_SCREEN

    ; Handle continuous input
    CALL HANDLE_INPUT

    ; Update game state
    CALL UPDATE_GAME

    ; Render game
    CALL RENDER_GAME

    ; Control game speed
    CALL DELAY

    ; Check for game over
    CMP GAME_OVER_FLAG, 0
    JE GAME_LOOP

    ; Exit game
    CALL GAME_EXIT
MAIN ENDP

; Clear screen procedure
CLEAR_SCREEN PROC NEAR
    PUSH ES
    MOV AX, 0A000h  ; Video memory segment
    MOV ES, AX
    MOV DI, 0
    MOV CX, 32000   ; Total video memory
    MOV AL, 0       ; Black color
    REP STOSB       ; Repeat store byte
    POP ES
    RET
CLEAR_SCREEN ENDP

; Initialize game state
INIT_GAME PROC NEAR
    ; Reset game variables
    MOV AX, 160
    MOV CAR_X, AX
    MOV AX, 150
    MOV CAR_Y, AX
    MOV AX, 100
    MOV OBSTACLE_X, AX
    MOV AX, 0
    MOV OBSTACLE_Y, AX
    MOV SCORE, AX
    MOV LIVES, 3
    MOV GAME_OVER_FLAG, 0
    
    ; Reset key states
    MOV KEY_W, 0
    MOV KEY_A, 0
    MOV KEY_S, 0
    MOV KEY_D, 0

    MOV AX, 160
    MOV PREV_CAR_X, AX
    MOV AX, 150
    MOV PREV_CAR_Y, AX
    RET
INIT_GAME ENDP

; Handle continuous input
HANDLE_INPUT PROC NEAR
    ; Check for key press
    MOV AH, 01h
    INT 16h
    JZ CHECK_KEY_RELEASE

    ; Read key
    MOV AH, 00h
    INT 16h

    ; Check specific keys
    CMP AL, 'w'
    JE MOVE_UP
    CMP AL, 'a'
    JE MOVE_LEFT
    CMP AL, 's'
    JE MOVE_DOWN
    CMP AL, 'd'
    JE MOVE_RIGHT
    CMP AL, 27      ; ESC key
    JE TERMINATE_GAME
    JMP HANDLE_INPUT_END

MOVE_UP:
    MOV AX, CAR_Y
    SUB AX, SPEED
    MOV CAR_Y, AX
    CALL DRAW_CAR_PATH
    JMP CHECK_BOUNDARIES
MOVE_DOWN:
    MOV AX, CAR_Y
    ADD AX, SPEED
    MOV CAR_Y, AX
    CALL DRAW_CAR_PATH
    JMP CHECK_BOUNDARIES
MOVE_LEFT:
    MOV AX, CAR_X
    SUB AX, SPEED
    MOV CAR_X, AX
    CALL DRAW_CAR_PATH
    JMP CHECK_BOUNDARIES
MOVE_RIGHT:
    MOV AX, CAR_X
    ADD AX, SPEED
    MOV CAR_X, AX
    CALL DRAW_CAR_PATH
    JMP CHECK_BOUNDARIES

CHECK_BOUNDARIES:
    ; Horizontal boundary
    MOV AX, CAR_X
    CMP AX, 100     ; Left boundary
    JL FIX_LEFT
    CMP AX, 220     ; Right boundary
    JG FIX_RIGHT
    JMP HANDLE_INPUT_END

FIX_LEFT:
    MOV AX, 100
    MOV CAR_X, AX
    JMP HANDLE_INPUT_END
FIX_RIGHT:
    MOV AX, 220
    MOV CAR_X, AX
    JMP HANDLE_INPUT_END

CHECK_KEY_RELEASE:
    ; Reset all key flags
    MOV KEY_W, 0
    MOV KEY_A, 0
    MOV KEY_S, 0
    MOV KEY_D, 0
    JMP HANDLE_INPUT_END

TERMINATE_GAME:
    MOV GAME_OVER_FLAG, 1
    JMP HANDLE_INPUT_END

HANDLE_INPUT_END:
    RET
HANDLE_INPUT ENDP

; Update game state
UPDATE_GAME PROC NEAR
    ; Move obstacle down
    MOV AX, OBSTACLE_Y
    ADD AX, 2       ; Slower obstacle speed
    MOV OBSTACLE_Y, AX

    ; Reset obstacle when it goes off screen
    CMP AX, SCREEN_HEIGHT
    JL CONTINUE_GAME

    ; Randomize obstacle position
    MOV AH, 00h
    INT 1Ah
    MOV AX, DX
    AND AX, 0FFh
    ADD AX, 100     ; Ensure within road
    MOV OBSTACLE_X, AX
    MOV OBSTACLE_Y, 0
    INC SCORE

CONTINUE_GAME:
    ; Check for collision
    CALL CHECK_COLLISION
    RET
UPDATE_GAME ENDP

; Collision detection
CHECK_COLLISION PROC NEAR
    ; Simple collision logic
    MOV AX, CAR_X
    MOV BX, OBSTACLE_X
    SUB AX, BX
    CMP AX, 20      ; Increased collision area
    JG NO_COLLISION
    CMP AX, -20     ; Increased collision area
    JL NO_COLLISION

    MOV AX, CAR_Y
    MOV BX, OBSTACLE_Y
    SUB AX, BX
    CMP AX, 20      ; Increased collision area
    JG NO_COLLISION
    CMP AX, -20     ; Increased collision area
    JL NO_COLLISION

    ; Collision occurred
    DEC LIVES
    CMP LIVES, 0
    JE SET_GAME_OVER

NO_COLLISION:
    RET

SET_GAME_OVER:
    MOV GAME_OVER_FLAG, 1
    RET
CHECK_COLLISION ENDP

; Render game graphics
RENDER_GAME PROC NEAR
    CALL DRAW_BACKGROUND
    CALL DRAW_OBSTACLE
    CALL DRAW_CAR
    RET
RENDER_GAME ENDP

; Draw background (road)
DRAW_BACKGROUND PROC NEAR
    ; Draw road boundaries
    MOV AH, 0Ch
    MOV AL, 08h     ; Dark gray color

    ; Left boundary
    MOV CX, 100
    MOV DX, 0
LEFT_BOUNDARY:
    INT 10h
    INC DX
    CMP DX, 200
    JL LEFT_BOUNDARY

    ; Right boundary
    MOV CX, 220
    MOV DX, 0
RIGHT_BOUNDARY:
    INT 10h
    INC DX
    CMP DX, 200
    JL RIGHT_BOUNDARY

    RET
DRAW_BACKGROUND ENDP

; Draw car
DRAW_CAR PROC NEAR
    MOV AH, 0Ch
    MOV AL, 04h     ; Red color
    MOV CX, CAR_X
    MOV DX, CAR_Y

    ; Draw 10x10 car
    PUSH CX
    MOV BH, 10
CAR_ROW:
    PUSH CX
    MOV BL, 10
CAR_PIXEL:
    INT 10h
    INC CX
    DEC BL
    JNZ CAR_PIXEL
    POP CX
    INC DX
    DEC BH
    JNZ CAR_ROW
    POP CX

    RET
DRAW_CAR ENDP

; Draw obstacle
DRAW_OBSTACLE PROC NEAR
    MOV AH, 0Ch
    MOV AL, 02h     ; Green color
    MOV CX, OBSTACLE_X
    MOV DX, OBSTACLE_Y

    ; Draw 10x10 obstacle
    PUSH CX
    MOV BH, 10
OBSTACLE_ROW:
    PUSH CX
    MOV BL, 10
OBSTACLE_PIXEL:
    INT 10h
    INC CX
    DEC BL
    JNZ OBSTACLE_PIXEL
    POP CX
    INC DX
    DEC BH
    JNZ OBSTACLE_ROW
    POP CX

    RET
DRAW_OBSTACLE ENDP

; Draw car path
DRAW_CAR_PATH PROC NEAR
    MOV AH, 0Ch
    MOV AL, 04h     ; Red color

    ; Draw line from previous car position to current car position
    MOV CX, PREV_CAR_X
    MOV DX, PREV_CAR_Y
DRAW_CAR_PATH_LINE:
    INT 10h
    INC CX
    CMP CX, CAR_X
    JL DRAW_CAR_PATH_LINE

    ; Update previous car position
    MOV AX, CAR_X
    MOV PREV_CAR_X, AX
    MOV AX, CAR_Y
    MOV PREV_CAR_Y, AX

    RET
DRAW_CAR_PATH ENDP

; Delay to control game speed
DELAY PROC NEAR
    PUSH CX
    MOV CX, 0FFFFh
DELAY_LOOP:
    LOOP DELAY_LOOP
    POP CX
    RET
DELAY ENDP

; Get winner category based on score
GET_WINNER_CATEGORY PROC NEAR
    ; Based on score value, determine winner category
    ; Return category as string address in DX
    
    MOV AX, SCORE
    
    CMP AX, 5       ; Score less than 5
    JL BEGINNER_WINNER
    
    CMP AX, 10      ; Score between 5-9
    JL AMATEUR_WINNER
    
    CMP AX, 15      ; Score between 10-14
    JL EXPERT_WINNER
    
    ; Score 15 or greater
    MOV DX, OFFSET WINNER_CHAMPION
    JMP GET_WINNER_END
    
BEGINNER_WINNER:
    MOV DX, OFFSET WINNER_BEGINNER
    JMP GET_WINNER_END
    
AMATEUR_WINNER:
    MOV DX, OFFSET WINNER_AMATEUR
    JMP GET_WINNER_END
    
EXPERT_WINNER:
    MOV DX, OFFSET WINNER_EXPERT
    
GET_WINNER_END:
    RET
GET_WINNER_CATEGORY ENDP

; Display numeric score
DISPLAY_SCORE PROC NEAR
    MOV AX, SCORE
    MOV CX, 0       ; Digit counter
    MOV BX, 10      ; Divisor

CONVERT_LOOP:
    MOV DX, 0
    DIV BX          ; Divide by 10
    PUSH DX         ; Push remainder (digit)
    INC CX          ; Increment counter
    TEST AX, AX     ; Check if quotient is 0
    JNZ CONVERT_LOOP

DISPLAY_LOOP:
    POP DX          ; Pop digit
    ADD DL, '0'     ; Convert to ASCII
    MOV AH, 02h     ; Function to display character
    INT 21h
    LOOP DISPLAY_LOOP

    RET
DISPLAY_SCORE ENDP

; Exit game procedure
GAME_EXIT PROC NEAR
    ; Clear screen and set text mode
    MOV AX, 0003h
    INT 10h
    
    ; Display score prefix
    MOV AH, 09h
    MOV DX, OFFSET WINNER_PREFIX
    INT 21h
    
    ; Display score value
    CALL DISPLAY_SCORE
    
    ; New line
    MOV AH, 02h
    MOV DL, 13      ; Carriage return
    INT 21h
    MOV DL, 10      ; Line feed
    INT 21h
    
    ; Get winner category based on score
    CALL GET_WINNER_CATEGORY
    
    ; Display winner category
    MOV AH, 09h
    INT 21h
    
    ; Delay for 5 seconds
    MOV CX, 0FFFFh
DELAY_LOOP_EXIT1:
    PUSH CX
    MOV CX, 0FFFFh
DELAY_LOOP_EXIT2:
    LOOP DELAY_LOOP_EXIT2
    POP CX
    LOOP DELAY_LOOP_EXIT1

    ; Return to DOS
    MOV AX, 4C00h
    INT 21h
    RET
GAME_EXIT ENDP

END MAIN