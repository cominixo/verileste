import utils::*;

module fpga (
    input logic clk_27,
    input logic reset,

    output logic uart_tx,
    input logic uart_rx,
    output logic led2,
    output logic led
);

    localparam MSG_SIZE = 8+8+8 + 7+8 + 6;

    logic [5:0] inputs [460];

    logic [15:0] frame_count;
    logic  [5:0] btn;
    logic exit;

    logic [7:0] data;
    logic data_valid;
    logic [MSG_SIZE-1:0] char_sel;
    logic uart_ready;
    logic [MSG_SIZE*8 - 1:0] msg; 
    logic do_uart;

    vec2d    rem_result;
    vec2dint pos_result;

    vec2d    rem;
    vec2dint pos;
    vec2d    spd;

    logic clk;


    Gowin_rPLL pll (
        .clkout(clk),
        .clkin(clk_27)
    );

    assign led = exit;
    assign led2 = !exit;

    initial begin
        $readmemh("../inputs.mem", inputs);
    end

    assign msg[MSG_SIZE*8 - 1: (MSG_SIZE-11)*8] = "exit! pos: ";

    always_comb begin 
        for (int i = 25; i < 29; i++) begin
            msg [i*8 +: 8] = tohex(pos_result.y[(i-25)*4 +: 4]);
        end
    end

    assign msg[29*8 +: 8] = " ";

    always_comb begin
        for (int i = 30; i < 34; i++) begin
            msg [i*8 +: 8] = tohex(pos_result.x[(i-30)*4 +: 4]);
        end
    end   

    assign msg[199 : 19*8] = " rem: ";
   

    always_comb begin
        for (int i = 2; i < 10; i++) begin
            msg [i*8 +: 8] = tohex(rem_result.y[(i-2)*4 +: 4]);
        end
    end

    assign msg[10*8 +: 8] = " ";
    
    always_comb begin
        for (int i = 11; i < 19; i++) begin
            msg [i*8 +: 8] = tohex(rem_result.x[(i-11)*4 +: 4]);
        end
    end

    assign msg[15:0] = 16'h0d0a; // newline

    always_ff @(posedge clk) begin
        if (reset) begin
            btn <= '0;
            frame_count <= '0;
        end
        else begin
            frame_count <= frame_count + 1;
            btn <= inputs[9'(frame_count)];
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            data_valid <= '0;
            data <= '0;
            char_sel <= '0;
            do_uart <= '0;
            rem_result <= '0;
            pos_result <= '0;
        end
        else begin
            
            if (do_uart) begin
                if (uart_ready) begin
                    data <= msg[((MSG_SIZE-char_sel)<<3)-1 -: 8];
                    data_valid <= 1'b1;
                    char_sel <= char_sel + 1;
                    if (char_sel == MSG_SIZE-1) begin
                        do_uart <= 1'b0;
                    end
                end
            end
            else if (exit) begin
                do_uart <= 1'b1;
                rem_result <= rem;
                pos_result <= pos;
            end
            

            if (data_valid) begin
                data_valid <= 1'b0;
            end
        end
    end

    uart uart (
        clk,
        reset,
        data,
        data_valid,
        uart_tx,
        uart_ready
    );

    verileste verileste (
        clk,
        reset,
        btn,
        rem,
        pos,
        spd,
        exit
    );

endmodule
