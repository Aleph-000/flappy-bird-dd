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
    parameter BIRD_WIDTH=16'd21,
    parameter BIRD_HEIGHT=16'd16,
    //状态
    parameter IDLE = 2'b00,
    parameter PLAY = 2'b01,
    parameter GAMEOVER = 2'b10,
    parameter PAUSE =2'b11,
    
    //游戏属性
    parameter signed [15:0]JUMP_V=-9,
    parameter signed [15:0]GRAVITY=1,
    parameter integer FRAC_BITS = 4
    )
    (
        input wire clk,
        input wire rst,
        input wire jump_ctrl,
        input wire pause_ctrl,
        input wire collision,
        input wire [1:0] gravity_sel,
        output wire signed[15:0]bird_x,
        output wire signed[15:0]bird_y,
        output reg[1:0] game_state
        
    );
    assign bird_x=16'd250;
    
    reg signed[23:0] bird_y_fixed;
    reg signed[23:0] bird_v_fixed;
    reg signed[23:0] gravity_fixed;

    assign bird_y = bird_y_fixed >>> FRAC_BITS;

    // SW[7:6] 选择重力档位，使用 4 位小数定点数表示小于 1 像素/帧^2 的加速度。
    always @(*) begin
        case (gravity_sel)
            2'b01: gravity_fixed = 24'sd6;   // 0.375 像素/帧^2
            2'b10: gravity_fixed = 24'sd8;   // 0.500 像素/帧^2
            2'b11: gravity_fixed = 24'sd12;  // 0.750 像素/帧^2
            default: gravity_fixed = 24'sd4;  // 0.250 像素/帧^2
        endcase
    end

    always@(posedge clk or posedge rst)begin
        if(rst)begin
            game_state<=IDLE;
            bird_y_fixed <= (SCREEN_HEIGHT / 2) <<< FRAC_BITS;
            bird_v_fixed <= 24'sd0;
        end
        else begin
            case(game_state)
                //开始菜单
                IDLE:
                begin          
                    bird_y_fixed <= (SCREEN_HEIGHT / 2) <<< FRAC_BITS;
                    bird_v_fixed <= 24'sd0;
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
                            bird_v_fixed <= (JUMP_V <<< FRAC_BITS) + gravity_fixed;
                            bird_y_fixed <= bird_y_fixed + (JUMP_V <<< FRAC_BITS) + gravity_fixed;
                        end
                        else begin
                            bird_v_fixed <= bird_v_fixed + gravity_fixed;
                            bird_y_fixed <= bird_y_fixed + bird_v_fixed + gravity_fixed;
                        end
                    end
                end
                //死亡
                GAMEOVER:
                begin
                end       
                //暂停
                PAUSE:
                begin
                    if(jump_ctrl || pause_ctrl)begin
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
