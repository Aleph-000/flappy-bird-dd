`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/06/16 19:57:29
// Design Name: 
// Module Name: bird
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


module bird#(
    //基本参数
    parameter SCREEN_WIDTH = 16'd640,
    parameter SCREEN_HEIGHT = 16'd480,
    parameter BIRD_WIDTH=16'd64,
    parameter BIRD_HEIGHT=16'd48,
    //状态
    parameter IDLE = 2'b00,
    parameter PLAY = 2'b01,
    parameter GAMEOVER = 2'b10,
    parameter PAUSE =2'b11,
    
    //游戏属性
    parameter signed [15:0]JUMP_V=-9,
    parameter signed [15:0]GRAVITY=1
    )
    (
        input wire clk,
        input wire rst,
        input wire jump_ctrl,
        input wire pause_ctrl,
        input wire collision,
        output wire signed[15:0]bird_x,
        output reg signed[15:0]bird_y,
        output reg[1:0] game_state
        
    );
    assign bird_x=16'd250;
    
    reg signed[15:0]bird_v;  
    always@(posedge clk or posedge rst)begin
        if(rst)begin
            game_state<=IDLE;
            bird_y<=SCREEN_HEIGHT/2;
            bird_v<=16'sd0;
        end
        else begin
            case(game_state)
                //开始菜单
                IDLE:
                begin          
                    bird_y<=SCREEN_HEIGHT/2;
                    bird_v<=16'sd0;
                    if(jump_ctrl)begin
                        game_state<=PLAY;
                    end
                end
                
                //游戏中
                PLAY:
                begin
                    if(collision)begin
                        game_state<=GAMEOVER;
                    end
                    else if(pause_ctrl)begin
                        game_state<=PAUSE;
                    end
                    else begin
                        if(jump_ctrl)begin
                            bird_v<=bird_v+JUMP_V+GRAVITY;
                        end
                        else begin
                            bird_v<=bird_v+GRAVITY;
                        end
                        bird_y<=bird_y+bird_v;
                    end
                end
                //死亡
                GAMEOVER:
                begin
                end       
                //暂停
                PAUSE:
                begin
                    if(jump_ctrl)begin
                        game_state<=PLAY;
                    end
                end 
                //排错
                default:
                begin
                    game_state<=IDLE;
                end 
            endcase  
       end 
    end
endmodule
