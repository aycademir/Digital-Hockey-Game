module hockey(

    input clk,
    input rst,
    
    input BTN_A,
    input BTN_B,
    
    input [1:0] DIR_A,
    input [1:0] DIR_B,
    
    input [2:0] Y_in_A,
    input [2:0] Y_in_B,
   
    output reg LEDA,
    output reg LEDB,
    output reg [4:0] LEDX,
    
    output reg [6:0] SSD7,
    output reg [6:0] SSD6,
    output reg [6:0] SSD5,
    output reg [6:0] SSD4, 
    output reg [6:0] SSD3,
    output reg [6:0] SSD2,
    output reg [6:0] SSD1,
    output reg [6:0] SSD0   
    

    
    );

    reg [2:0] X_COORD;
    reg [2:0] Y_COORD;
    reg turn;
    reg [6:0] timer;
    reg [6:0] timer_constraint = 7'd100;
    reg [4:0] state;
    reg [1:0] dirY;
    reg [1:0] scoreB;
    reg [1:0] scoreA;
    parameter IDLE =0, DISP =1, HIT_B=2, HIT_A=3, SEND_A=4, SEND_B=5, RESP_A=6, RESP_B=7, GOAL_B=8, GOAL_A=9, END_STATE=10;
    reg [6:0] display;
    reg [6:0] a =7'b0001000;
    reg [6:0] b =7'b1100000;
    reg [6:0] zero = 7'b0000001;
    reg [6:0] one =7'b1001111;
    reg [6:0] two =7'b0010010;
    reg [6:0] three =7'b0000110;
    reg [6:0] four =7'b1001100;
    reg [6:0] empty =7'b1111111;
    reg [6:0] dash  =7'b1111110;
    
    reg led_blink = 0;
    // you may use additional always blocks or drive SSDs and LEDs in one always block
    // for state machine and memory elements 

    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            turn <= 0;
            X_COORD <= 3'b0;
            scoreB <= 0;
            scoreA <= 0;
            Y_COORD <= 3'b0;
            timer <= 6'b0;
            state <= IDLE;
            dirY <=0;
            led_blink <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if(BTN_A != 0 | BTN_B != 0) begin
                        if (BTN_A ==1) begin
                            turn <= 0;
                        end
                        else begin
                            turn <= 1;
                        end
                        state <= DISP;
                    end
                    else begin
                        state <= IDLE;
                    end
                end   
                
                DISP: begin
                    if(timer < timer_constraint) begin
                        timer <= timer+1;
                        state <= DISP;
                    end
                    else begin
                        timer <= 6'b0;
                        if(turn==1)begin
                            state<=HIT_B;
                        end
                        else begin
                            state<=HIT_A;
                        end
                    end
                end    
                
                HIT_B: begin
                    if(BTN_B && (Y_in_B < 3'b101)) begin
                        X_COORD <= 3'b100;
                        Y_COORD <= Y_in_B;
                        dirY <= DIR_B;
                        state <= SEND_A;
                    end       
                    else begin
                        state <= HIT_B;
                    end  
                end    
                
                SEND_A:  begin
                    if(timer<timer_constraint) begin
                        timer <= timer + 1;
                        state <= SEND_A;
                    end
                    else begin
                        timer <=6'b0;
                        case(dirY)
                            2'b10: begin
                                if(Y_COORD==3'b0) begin
                                    dirY <= 2'b01;
                                    Y_COORD <= Y_COORD +1;
                                end
                                else begin
                                    Y_COORD <= Y_COORD-1; 
                                end
                            end
                            
                            2'b01: begin
                                if(Y_COORD==3'b100) begin
                                    dirY <= 2'b10;
                                    Y_COORD <= Y_COORD - 1;
                                end
                                else begin
                                    Y_COORD <= Y_COORD + 1; 
                                end
                            end
                            
                            2'b00: begin end
                        
                        endcase
                        if(X_COORD > 3'b001) begin
                            X_COORD <= X_COORD - 1;
                            state <= SEND_A;
                        end
                        else begin 
                            X_COORD <= 0;
                            state <= RESP_A;
                        end
                    end
                end 
                   
                RESP_A: begin
                    if(timer<timer_constraint) begin
                        if(BTN_A && Y_COORD == Y_in_A) begin
                            X_COORD <=1;
                            timer <= 6'b0;
                            case(DIR_A)
                                2'b00: begin
                                    dirY <= DIR_A;
                                    state <= SEND_B;
                                end
                                    
                                2'b01: begin
                                    if(Y_COORD == 3'b100) begin
                                        dirY <= 2'b10;
                                        Y_COORD <= Y_COORD -1;
                                        state <= SEND_B;
                                    end
                                    else begin
                                        dirY <= DIR_A;
                                        Y_COORD <= Y_COORD +1;
                                        state <= SEND_B;
                                    end
                                end
                                    
                                2'b10: begin
                                    if (Y_COORD == 3'b0) begin
                                        dirY <= 2'b01;
                                        Y_COORD <= Y_COORD +1;
                                        state <= SEND_B;
                                    end
                                    else begin
                                        dirY <= DIR_A;
                                        Y_COORD <= Y_COORD -1;
                                        state <= SEND_B;
                                    end
                                end
                            endcase   
                        end
                        else begin
                            timer <= timer +1;
                            state <= RESP_A;
                        end
                    end  
                    else begin
                        timer <= 6'b0;
                        scoreB <= scoreB + 1;
                        state <= GOAL_B;
                    end   
                end
                
                GOAL_B: begin
                    if(timer<timer_constraint) begin
                        timer <= timer + 1;
                        state <= GOAL_B;
                    end
                    else begin
                        timer <= 6'b0;
                        if(scoreB == 2'b11) begin
                            turn <= 1;
                            state <= END_STATE;
                        end
                        else begin
                            state <= HIT_A;
                        end
                    end
                end
                
                HIT_A: begin
                    if(BTN_A && (Y_in_A<3'b101)) begin
                        X_COORD <=0;
                        Y_COORD <= Y_in_A;
                        dirY <= DIR_A;
                        state <= SEND_B;
                    end
                    else begin
                        state <= HIT_A;
                    end
                end   
                
                SEND_B: begin
                    if(timer<timer_constraint) begin
                        timer <= timer + 1;
                        state <= SEND_B;
                    end
                    else begin
                        timer <= 6'b0;
                        case(dirY)
                            2'b00: begin end
                            2'b01: begin
                                if(Y_COORD == 3'b100) begin
                                    dirY <= 2'b10;
                                    Y_COORD <= Y_COORD -1;
                                end
                                else begin
                                    Y_COORD <= Y_COORD +1;
                                end
                            end
                            
                            2'b10: begin
                                if(Y_COORD == 3'b0) begin
                                    dirY <= 2'b01;
                                    Y_COORD <= Y_COORD +1;
                                end
                                else begin
                                    Y_COORD <= Y_COORD -1;
                                end
                            end
                        endcase
                        if(X_COORD < 3'b011) begin
                            X_COORD <= X_COORD +1;
                            state <= SEND_B;
                        end
                        else begin
                            X_COORD <= 4;
                            state <= RESP_B;
                        end
                    end
                end
                
                RESP_B: begin
                    if(timer<timer_constraint) begin
                        if (BTN_B && (Y_COORD==Y_in_B)) begin
                            X_COORD <= 3'b011;
                            timer <= 6'b0;
                            case(DIR_B)
                                2'b00: begin
                                    dirY <= DIR_B;
                                    state <= SEND_A;
                                end
                                2'b01: begin
                                    if(Y_COORD == 3'b100) begin
                                        dirY <= 2'b10;
                                        Y_COORD <= Y_COORD -1;
                                        state <= SEND_A;
                                    end
                                    else begin
                                        dirY <= DIR_B;
                                        Y_COORD <= Y_COORD +1;
                                        state <= SEND_A;
                                    end
                                end
                                2'b10: begin
                                    if(Y_COORD == 3'b0) begin
                                        dirY <= 2'b01;
                                        Y_COORD <= Y_COORD +1;
                                        state <= SEND_A;
                                    end
                                    else begin
                                        dirY <= DIR_B;
                                        Y_COORD <= Y_COORD -1;
                                        state <= SEND_A;
                                    end
                                end
                            endcase
                            
                        end
                        else begin
                            timer <= timer +1;
                            state <= RESP_B;
                        end
                    end
                    else begin
                        timer <= 6'b0;
                        scoreA <= scoreA +1;
                        state <= GOAL_A;
                    end
                end
                
                GOAL_A: begin
                    if(timer<timer_constraint) begin
                        timer <= timer +1;
                        state <= GOAL_A;
                    end
                    else begin
                        timer <= 6'b0;
                        if(scoreA==2'b11) begin
                            turn <= 0;
                            state <= END_STATE;
                        end
                        else begin
                            state <= HIT_B;
                        end
                    end
                end 
                  
                END_STATE: begin
                    state <= END_STATE;
                    if(timer<50) begin
                        timer <= timer + 1;
                    end
                    else begin
                        led_blink <= led_blink ^ 1;
                        timer <= 0;
                    end
                    
                end
                
     
            endcase    
        end        
    end
    
    // for LEDs
    always @ (*)
    begin
        case(state)
            IDLE: begin
                LEDA = 1;
                LEDB = 1;
                LEDX[0] = 0;
                LEDX[1] = 0;
                LEDX[2] = 0;
                LEDX[3] = 0;
                LEDX[4] = 0;
            end
            DISP: begin
                LEDA = 0;
                LEDB = 0;
                LEDX[0] = 1;
                LEDX[1] = 1;
                LEDX[2] = 1;
                LEDX[3] = 1;
                LEDX[4] = 1;
            end
            HIT_B: begin
                LEDA = 0;
                LEDB = 1;
                LEDX[0] = 0;
                LEDX[1] = 0;
                LEDX[2] = 0;
                LEDX[3] = 0;
                LEDX[4] = 0;
            end
            HIT_A: begin
                LEDA = 1;
                LEDB = 0;
                LEDX[0] = 0;
                LEDX[1] = 0;
                LEDX[2] = 0;
                LEDX[3] = 0;
                LEDX[4] = 0;
            end
            SEND_A: begin
                LEDA = 0;
                LEDB = 0;
                LEDX = 0;
                LEDX[4-X_COORD] = 1;
            end
            SEND_B: begin
                LEDA = 0;
                LEDB = 0;
                LEDX = 0;
                LEDX[4-X_COORD] = 1;
            end
            RESP_A: begin
                LEDA = 1;
                LEDB = 0;
                LEDX = 0;
                LEDX[4-X_COORD] = 1;
            end
            RESP_B: begin
                LEDA = 0;
                LEDB = 1;
                LEDX = 0;
                LEDX[4-X_COORD] = 1;
            end
            GOAL_B: begin
                LEDA = 0;
                LEDB = 0;
                LEDX[0] = 1;
                LEDX[1] = 1;
                LEDX[2] = 1;
                LEDX[3] = 1;
                LEDX[4] = 1;
            end
            GOAL_A: begin
                LEDA = 0;
                LEDB = 0;
                LEDX[0] = 1;
                LEDX[1] = 1;
                LEDX[2] = 1;
                LEDX[3] = 1;
                LEDX[4] = 1;
            end
            END_STATE: begin
                LEDA = 0;
                LEDB = 0;
                if(~led_blink) begin
                    LEDX[0] = 1;
                    LEDX[1] = 0;
                    LEDX[2] = 1;
                    LEDX[3] = 0;
                    LEDX[4] = 1;
                end
                else begin
                    LEDX[0] = 0;
                    LEDX[1] = 1;
                    LEDX[2] = 0;
                    LEDX[3] = 1;
                    LEDX[4] = 0;
                end
            end
            
            default: begin
                LEDA = 0;
                LEDB = 0;
                LEDX = 0;
            end
        endcase
    end
    
    
    
    
    
    
    
    
    
    
    //for SSDs
    always @ (*)
    begin
        case (state)
            IDLE: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                SSD4 = empty;
                SSD3 = empty;
                SSD2 = a;
                SSD1 = dash;
                SSD0 = b;
            end
            DISP: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                SSD4 = empty;
                SSD3 = empty;
                SSD2 = zero;
                SSD1 = dash;
                SSD0 = zero;
            end
            HIT_B: begin
                SSD7 = empty;
                SSD6 = empty;
                case(Y_in_B)
                3'b000:begin SSD4 = zero; end
                3'b001:begin SSD4 = one;end
                3'b010:begin SSD4 = two; end
                3'b011:begin SSD4 = three;end
                3'b100:begin SSD4 = four; end
                default: SSD4 = dash;
               endcase
                SSD5 = empty;
                
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;
                end
            HIT_A:begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                case(Y_in_A)
                3'b000:begin SSD4 = zero; end
                3'b001:begin SSD4 = one;end
                3'b010:begin SSD4 = two; end
                3'b011:begin SSD4 = three;end
                3'b100:begin SSD4 = four; end
                default:begin SSD4 = dash;end
                endcase
                
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;  
                end      
            END_STATE:begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                SSD3 = empty;
                if(scoreA==3)begin
                    SSD4 = a;
                end
                else begin 
                    SSD4 =b;
                end
                case(scoreA)
                    2'b00:
                        SSD2 = zero;
                    2'b01:
                        SSD2 = one;
                    2'b10:
                        SSD2 = two;
                    2'b11:
                        SSD2 = three;
                endcase
                
                SSD1 = dash;
                
                case(scoreB)
                    2'b00:
                        SSD0 = zero;
                    2'b01:
                        SSD0 = one;
                    2'b10:
                        SSD0 = two;
                    2'b11:
                        SSD0 = three;
                endcase
            end
            
            SEND_A: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;
                case (Y_COORD)
                    3'b000:
                    SSD4 =zero;
                    3'b001:
                    SSD4 =one;
                    3'b010:
                    SSD4 =two;
                    3'b011:
                    SSD4 =three;
                    3'b100:
                    SSD4 =four;
                    default: begin 
                    SSD4 = empty;
                    end
                endcase
            end
            
            SEND_B: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 =empty;
                
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;
                case (Y_COORD)
                    3'b000:
                    SSD4 =zero;
                    3'b001:
                    SSD4 =one;
                    3'b010:
                    SSD4 =two;
                    3'b011:
                    SSD4 =three;
                    3'b100:
                    SSD4 =four;
                    default: begin 
                    SSD4 = empty;
                    end
                endcase
            end
            
            RESP_A: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;
                case (Y_COORD)
                    3'b000:
                    SSD4 =zero;
                    3'b001:
                    SSD4 =one;
                    3'b010:
                    SSD4 =two;
                    3'b011:
                    SSD4 =three;
                    3'b100:
                    SSD4 =four;
                    default: begin 
                    SSD4 = empty;
                    end
                endcase
            end
            
            RESP_B: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 =empty;
                
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;
                case (Y_COORD)
                    3'b000:
                    SSD4 =zero;
                    3'b001:
                    SSD4 =one;
                    3'b010:
                    SSD4 =two;
                    3'b011:
                    SSD4 =three;
                    3'b100:
                    SSD4 =four;
                    default: begin 
                    SSD4 = empty;
                    end
                endcase
            end
            GOAL_A: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                SSD4 = empty;
                SSD3 = empty;
                
                SSD1 = dash;
                
            
                case(scoreA)
                    2'b00:
                    SSD2 =zero;
                    2'b01:
                    SSD2 =one;
                    2'b10:
                    SSD2 =two;
                    2'b11:
                    SSD2 =three;
                endcase
                case(scoreB)
                    2'b00:
                    SSD0 =zero;
                    2'b01:
                    SSD0 =one;
                    2'b10:
                    SSD0 =two;
                    2'b11:
                    SSD0 =three;
                endcase
            end
            
            GOAL_B: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 = empty;
                SSD4 = empty;
                SSD3 = empty;
                
                SSD1 = dash;
                
            
                case(scoreA)
                    2'b00:
                    SSD2 =zero;
                    2'b01:
                    SSD2 =one;
                    2'b10:
                    SSD2 =two;
                    2'b11:
                    SSD2 =three;
                endcase
                case(scoreB)
                    2'b00:
                    SSD0 =zero;
                    2'b01:
                    SSD0 =one;
                    2'b10:
                    SSD0 =two;
                    2'b11:
                    SSD0 =three;
                endcase
            end
            default: begin
                SSD7 = empty;
                SSD6 = empty;
                SSD5 =empty;
                SSD4 =empty;
                SSD3 = empty;
                SSD2 = empty;
                SSD1 = empty;
                SSD0 = empty;
            end
        endcase
    end
endmodule
