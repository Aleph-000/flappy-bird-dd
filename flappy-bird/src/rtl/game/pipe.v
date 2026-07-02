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
    parameter signed [15:0] PIPE_V=-4,
    parameter signed [15:0] GROUND_Y=16'sd420,
    parameter signed [15:0] MIN_GAP_TOP=16'sd60,
    parameter signed [15:0] GAP_HEIGHT=16'sd140,
    parameter signed [15:0] GAPWIDTH=16'sd120,
    parameter signed [15:0] PIPE_SPACING=16'sd200
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
        integer i;
        //random
        reg [15:0]random= 16'hACE1;
        reg signed [15:0]max_right;
        reg signed [15:0]new_gap_top;
        reg signed [15:0]speed_bonus;
        
        always@(posedge clk)begin
            max_right = SCREEN_WIDTH;
            for(i=0;i<=4;i=i+1)begin
                if (gap_right[i] > max_right)
                   max_right = gap_right[i];
            end
            // 分数越高略微加速，但限幅，避免后期管子速度失控。
            if (score >= 16'd20)
                speed_bonus = 16'sd4;
            else
                speed_bonus = score[15:0] / 16'sd5;

            random<={random[14:0],random[15]^random[10]^random[5]^random[0]};
            case(game_state)                
                PLAY:
                begin
                    for(i=0;i<=4;i=i+1)begin
                        if(gap_right[i]<0)begin
                            // 缺口固定高度，随机上边界限制在天空区域，避免倒置或穿进地面。
                            new_gap_top = MIN_GAP_TOP + (random % (GROUND_Y - MIN_GAP_TOP - GAP_HEIGHT));
                            gap_left[i]   <= max_right + PIPE_SPACING;
                            gap_right[i]  <= max_right + PIPE_SPACING + GAPWIDTH;
                            gap_top[i]    <= new_gap_top;
                            gap_bottom[i] <= new_gap_top + GAP_HEIGHT;
                        end
                        else begin
                            gap_left[i]<=gap_left[i]+PIPE_V-speed_bonus;
                            gap_right[i]<=gap_right[i]+PIPE_V-speed_bonus;
                        end
                    end

               end
                PAUSE:
                begin
                    // 暂停时保持当前管道位置，恢复游戏后从原位置继续移动。
                end
                default:
                begin
                    for(i=0;i<=4;i=i+1)begin
                        gap_left[i]<=SCREEN_WIDTH+PIPE_SPACING*i;
                        gap_right[i]<=SCREEN_WIDTH+GAPWIDTH+PIPE_SPACING*i;
                        gap_top[i]<=16'sd100+16'sd35*i;
                        gap_bottom[i]<=16'sd100+16'sd35*i+GAP_HEIGHT;
                    end     
                end

            endcase
            
        end
endmodule
