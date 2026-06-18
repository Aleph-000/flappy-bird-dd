`timescale 1ns / 1ps

module tb_bg_layer;

    reg [9:0] pixel_x;
    reg [9:0] pixel_y;

    wire [11:0] bg_rgb;

    bg_layer uut(
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .bg_rgb(bg_rgb)
    );

    task check_rgb;
        input [9:0] x;
        input [9:0] y;
        input [11:0] expected;
        input [1023:0] message;
        begin
            pixel_x = x;
            pixel_y = y;
            #1;

            if (bg_rgb == expected) begin
                $display("[PASS] %s", message);
            end
            else begin
                $display("[FAIL] %s", message);
                $display("       At x=%d, y=%d", x, y);
                $display("       Expected RGB = %h", expected);
                $display("       Got      RGB = %h", bg_rgb);
            end
        end
    endtask

    initial begin
        // sky
        check_rgb(10'd250, 10'd50, 12'h6BF,
                  "bg sky should be light blue");

        // cloud
        check_rgb(10'd80, 10'd90, 12'hFFF,
                  "bg cloud should be white");

        // mountain
        check_rgb(10'd90, 10'd300, 12'h8CD,
                  "bg mountain should be light blue green");

        // building
        check_rgb(10'd65, 10'd350, 12'h8DE,
                  "bg building body should be light cyan");

        // window
        check_rgb(10'd55, 10'd350, 12'hFFA,
                  "bg building window should be light yellow");

        // grass
        check_rgb(10'd100, 10'd420, 12'h2C2,
                  "bg grass edge should be green");

        // ground
        check_rgb(10'd100, 10'd430, 12'hB72,
                  "bg ground should be brown");

        // flower center
        check_rgb(10'd80, 10'd398, 12'hFE0,
                  "bg flower center should be yellow");

        $display("bg_layer simulation finished.");
        $finish;
    end

endmodule
