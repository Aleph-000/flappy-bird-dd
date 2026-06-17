`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/16 21:21:22
// Design Name: 
// Module Name: pipe
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


module pipe#(
    //basic parameter
    parameter SCREEN_WIDTH = 16'd640,
    parameter SCREEN_HEIGHT = 16'd480,
    parameter BIRD_WIDTH=16'd64,
    parameter BIRD_HEIGHT=16'd48,
    //state
    parameter IDLE = 2'b00,
    parameter PLAY = 2'b01,
    parameter GAMEOVER = 2'b10,
    parameter PAUSE =2'b11,
    //game parameter
    //bird
    parameter signed [15:0]JUMP_V=-9,
    parameter signed [15:0]GRAVITY=1,
    //pipe
    parameter signed [15:0]PIPE_V=-9,
    parameter MINGAP=16'd100,
    parameter GAPWIDTH=16'd120
    )
    (
        input wire clk,
        input wire [15:0]score,
        input wire[1:0] game_state,
        
        output wire signed[15:0]gap_left0,
        output wire signed[15:0]gap_right0,
        output wire signed[15:0]gap_top0,
        output wire signed[15:0]gap_bottom0,
       //
        output wire signed[15:0]gap_left1,
        output wire signed[15:0]gap_right1,
        output wire signed[15:0]gap_top1,
        output wire signed[15:0]gap_bottom1,
       //       
        output wire signed[15:0]gap_left2,
        output wire signed[15:0]gap_right2,
        output wire signed[15:0]gap_top2,
        output wire signed[15:0]gap_bottom2,
       //      
        output wire signed[15:0]gap_left3,
        output wire signed[15:0]gap_right3,
        output wire signed[15:0]gap_top3,
        output wire signed[15:0]gap_bottom3,
       //      
        output wire signed[15:0]gap_left4,
        output wire signed[15:0]gap_right4,
        output wire signed[15:0]gap_top4,
        output wire signed[15:0]gap_bottom4   
    );
        reg signed[15:0]gap_left[0:4];
        reg signed[15:0]gap_right[0:4];
        reg signed[15:0]gap_top[0:4];
        reg signed[15:0]gap_bottom[0:4];
        
        assign gap_left0=gap_left[0];
        assign gap_right0=gap_right[0];
        assign gap_top0=gap_top[0];
        assign gap_bottom0=gap_bottom[0];
        
        assign gap_left1=gap_left[1];
        assign gap_right1=gap_right[1];
        assign gap_top1=gap_top[1];
        assign gap_bottom1=gap_bottom[1];
        
        assign gap_left2=gap_left[2];
        assign gap_right2=gap_right[2];
        assign gap_top2=gap_top[2];
        assign gap_bottom2=gap_bottom[2];
        
        
        assign gap_left3=gap_left[3];
        assign gap_right3=gap_right[3];
        assign gap_top3=gap_top[3];
        assign gap_bottom3=gap_bottom[3];
        
        assign gap_left4=gap_left[4];
        assign gap_right4=gap_right[4];
        assign gap_top4=gap_top[4];
        assign gap_bottom4=gap_bottom[4];
        //velocity
        reg signed[15:0]pipe_v;
        integer i;
        integer j;
        //random
        reg [15:0]random= 16'hACE1;
        reg signed [15:0]max_right;
        
        always@(posedge clk)begin
            max_right = SCREEN_WIDTH;
            for(i=0;i<=4;i=i+1)begin
                if (gap_right[i] > max_right)
                   max_right = gap_right[i];
            end
            random<={random[14:0],random[15]^random[10]^random[5]^random[0]};
            case(game_state)
                IDLE:
                begin
                    for(i=0;i<=4;i=i+1)begin
                        gap_left[i]<=SCREEN_WIDTH+200*i;
                        gap_right[i]<=SCREEN_WIDTH+GAPWIDTH+200*i;
                        gap_bottom[i]<=SCREEN_HEIGHT-40*i;
                        gap_top[i]<=40*i;
                    end     
                end
                
                PLAY:
                begin
                    for(i=0;i<=4;i=i+1)begin
                        if(gap_right[i]<0)begin
    
                            gap_left[i]<=max_right+(random%150);
                            gap_right[i]<=max_right+(random%150)+GAPWIDTH;
                            gap_bottom[i]<=MINGAP+(random%(SCREEN_HEIGHT-MINGAP));
                            gap_top[i]<=(random%(SCREEN_HEIGHT-MINGAP))-(random%200);
                        end
                        else begin
                            gap_left[i]<=gap_left[i]+PIPE_V-score/5;
                            gap_right[i]<=gap_right[i]+PIPE_V-score/5;;
                        end
                    end

               end
                default:
                begin
                end

            endcase
            
        end
endmodule