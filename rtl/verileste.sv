import utils::*;

module verileste (
    input logic clk,
    input logic rst,

    input logic [5:0] btn,

    output vec2d    rem_o,
    output vec2dint pos_o,
    output vec2d    spd_o,

    output logic exit
);
    localparam SF = 2.0**-16.0; 

    vec2d    rem;
    vec2dint pos;
    vec2d    spd;

    vec2d    player_rem;
    vec2dint player_pos;
    vec2d    player_spd;


    
    always_ff @(posedge clk) begin
        if (rst) begin
            rem      <= '0;
            spd      <= '0;
            pos.x    <= 16'h0008;
            pos.y    <= 16'h0060;
        end
        else begin
            pos <= pos_o;
            rem <= rem_o;
            spd <= spd_o;
            //$display("x = %f, y = %f, remx = %f, remy = %f spdx = %f spdy = %f", $signed(pos_o.x), $signed(pos_o.y), $itor($signed(rem_o.x))*SF, $itor($signed(rem_o.y))*SF, $itor($signed(spd_o.x))*SF, $itor($signed(spd_o.y))*SF);
        end
    end

    move move (
        pos,
        rem,
        spd,

        player_pos,
        player_rem,
        player_spd
    );
    

    player player (
        clk,
        rst,
        player_pos,
        player_rem,
        player_spd,
        btn,

        pos_o,
        rem_o,
        spd_o,
        exit
    );

endmodule
