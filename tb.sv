import utils::*;

module tb ();

logic [5:0] btn;

localparam SF = 2.0**-16.0; 

logic clk = 0;
logic rst;


always begin
    #10 clk <= ~clk;
end

logic [5:0] inputs [460];

vec2d    rem;
vec2dint pos;
vec2d    spd;

logic exit;

always_comb begin
    if (exit) begin
        $display("level exit");
        //$finish;
    end
end

initial begin
    $dumpfile("verileste.fst");
    $dumpvars;
    rst = 1'b1;
    btn = 6'b000000;

    $readmemh("inputs.mem", inputs);

    #20;
    rst = 1'b0;
    @(posedge clk);

    for (int i = 0; i < 460; i = i + 1) begin
        btn = inputs[i];
        $display("x = %8h, y = %8h, remx = %8h, remy = %8h spdx = %8h spdy = %8h", pos.x, pos.y, rem.x, rem.y, spd.x, spd.y);
        $display("btn: %b", btn);
        @(posedge clk);
    end

    //btn = 6'b000001;

    //for (int i = 0; i < 1000; i = i + 1) begin
    //    @(posedge clk);
    //end

    $finish;
end


verileste verileste (
    clk,
    rst,
    btn,

    rem,
    pos,
    spd,

    exit
);

endmodule
