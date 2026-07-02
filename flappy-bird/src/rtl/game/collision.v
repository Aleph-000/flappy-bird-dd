`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/17 13:17:06
// Design Name: 
// Module Name: collision
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module collision#(
    //basic parameter
    parameter SCREEN_WIDTH = 16'd640,
    parameter SCREEN_HEIGHT = 16'd480,
    parameter BIRD_WIDTH=16'd21,
    parameter BIRD_HEIGHT=16'd16,
    //state
    parameter IDLE = 2'b00,
    parameter PLAY = 2'b01,
    parameter GAMEOVER = 2'b10,
    parameter PAUSE =2'b11,
    //game parameter
    //bird
    parameter signed [15:0]JUMP_V=-9,
    parameter signed [15:0]GRAVITY=1,
    parameter signed [15:0]GROUND_Y=16'sd420,
    //pipe
    parameter signed [15:0]PIPE_V=-9,
    parameter MINGAP=16'd100,
    parameter GAPWIDTH=16'd60
    )
    (
        input wire clk,
        input wire [15:0]score,
        input wire[1:0] game_state,
        
        input wire signed[15:0]bird_x,
        input wire signed[15:0]bird_y,

        input wire signed[15:0]gap_left0,
        input wire signed[15:0]gap_right0,
        input wire signed[15:0]gap_top0,
        input wire signed[15:0]gap_bottom0,
       //
        input wire signed[15:0]gap_left1,
        input wire signed[15:0]gap_right1,
        input wire signed[15:0]gap_top1,
        input wire signed[15:0]gap_bottom1,
       //       
        input wire signed[15:0]gap_left2,
        input wire signed[15:0]gap_right2,
        input wire signed[15:0]gap_top2,
        input wire signed[15:0]gap_bottom2,
       //      
        input wire signed[15:0]gap_left3,
        input wire signed[15:0]gap_right3,
        input wire signed[15:0]gap_top3,
        input wire signed[15:0]gap_bottom3,
       //      
        input wire signed[15:0]gap_left4,
        input wire signed[15:0]gap_right4,
        input wire signed[15:0]gap_top4,
        input wire signed[15:0]gap_bottom4,
        
        //output wire [15:0]score,
        output wire collision   
    );
        wire signed[15:0]gap_left[0:4];
        wire signed[15:0]gap_right[0:4];
        wire signed[15:0]gap_top[0:4];
        wire signed[15:0]gap_bottom[0:4];
        
        assign gap_left[0]=gap_left0;
        assign gap_right[0]=gap_right0;
        assign gap_top[0]=gap_top0;
        assign gap_bottom[0]=gap_bottom0;
        
        assign gap_left[1]=gap_left1;
        assign gap_right[1]=gap_right1;
        assign gap_top[1]=gap_top1;
        assign gap_bottom[1]=gap_bottom1;
        
        assign gap_left[2]=gap_left2;
        assign gap_right[2]=gap_right2;
        assign gap_top[2]=gap_top2;
        assign gap_bottom[2]=gap_bottom2;
        
        assign gap_left[3]=gap_left3;
        assign gap_right[3]=gap_right3;
        assign gap_top[3]=gap_top3;
        assign gap_bottom[3]=gap_bottom3;
        
        assign gap_left[4]=gap_left4;
        assign gap_right[4]=gap_right4;
        assign gap_top[4]=gap_top4;
        assign gap_bottom[4]=gap_bottom4;
        
        reg judge=1'b0;
        assign collision=judge;
        integer i;
        always@(posedge clk)begin
            judge<=1'b0;
            case(game_state)
            PLAY:
                begin
                    if(bird_y+BIRD_HEIGHT/2>=GROUND_Y||bird_y-BIRD_HEIGHT/2<=0)
                    begin
                        judge<=1;
                    end
                    else begin
                        for(i=0;i<=4;i=i+1)begin
                           if(bird_x+BIRD_WIDTH/2>=gap_left[i]&&bird_x-BIRD_WIDTH/2<=gap_right[i])
                             begin
                                 if(bird_y+BIRD_HEIGHT/2>=gap_bottom[i]||bird_y-BIRD_HEIGHT/2<=gap_top[i])
                                    begin
                                       judge<=1'b1;
                                    end
                            end
                        end
                    end      
                end
            default:
                begin
                   judge<=1'b0;
                end
            endcase
        end
endmodule
