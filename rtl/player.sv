import utils::*;

module player (
    input logic clk,
    input logic rst,
    input vec2dint pos_i,
    input vec2d rem_i,
    input vec2d spd_i,
    input logic [5:0] btn,

    output vec2dint pos_o,
    output vec2d rem_o,
    output vec2d spd_o,
    output logic exit
);

    localparam BTN_LEFT  = 0;
    localparam BTN_RIGHT = 1;
    localparam BTN_UP    = 2;
    localparam BTN_DOWN  = 3;
    localparam BTN_O     = 4;
    localparam BTN_X     = 5;

    localparam HITBOX_X  = 1;
    localparam HITBOX_Y  = 3;
    localparam HITBOX_W  = 6;
    localparam HITBOX_H  = 5;

    logic [1:0] max_djump, djump, djump_r;
    logic [2:0] grace, grace_r, dash_time, jbuffer, jbuffer_r;
    logic jump, dash, p_jump, p_dash, on_ground;
    logic [31:0] dash_effect_time, dash_effect_time_r, maxfall;
    logic [31:0] h_input;
    
    vec2dint pos_hitbox;
    
    //vec2d dash_target, dash_accel;

    logic [31:0] accel, deccel; 

    logic [31:0] wall_dir;

    assign h_input = btn[BTN_RIGHT] ? 32'h00010000 : btn[BTN_LEFT] ? 32'hffff0000 : '0;

    assign pos_hitbox.x = pos_i.x + HITBOX_X;
    assign pos_hitbox.y = pos_i.y + HITBOX_Y;

    always_comb begin
        on_ground = is_solid(pos_hitbox.x, pos_hitbox.y+1);
        jump      = (btn[BTN_O]) && !p_jump;
        dash      = (btn[BTN_X]) && !p_dash;
        jbuffer   = jbuffer_r;
        djump     = djump_r;

        spd_o = spd_i;
        pos_o = pos_i;
        rem_o = rem_i;

        if (jump) begin
            jbuffer = 3'd4;
        end
        else if (jbuffer_r > 0) begin
            jbuffer = jbuffer_r - 1;
        end

        grace = grace_r;

        if (on_ground) begin
            grace = 3'd6;
            djump = max_djump;
        end
        else if (grace_r > 0) begin
            grace = grace_r - 1;
        end

        dash_effect_time = dash_effect_time_r - 1;

        // if dash_time_r

        //else
        //maxrun = 1;
        // TODO ice
        accel = on_ground ? 32'h00009999 : 32'h00006666; // 0.6, 0.4
        deccel = 32'h00002666; // 0.15

        if (abs(spd_i.x) <= 32'h00010000) begin
            spd_o.x = appr(spd_i.x, h_input, accel);
        end
        else begin
            spd_o.x = appr_pos(abs(spd_i.x), 32'h00010000, deccel);
            if (spd_i.x[31]) begin
                spd_o.x = -spd_o.x;
            end
        end

        //if (spd_i.x != 0) begin
        
        // wallslide (TODO: ice)
        if (h_input != '0 && is_solid(pos_hitbox.x+16'(h_input>>16), pos_hitbox.y)) begin
            maxfall = 32'h00006666;
        end 
        else begin
            maxfall = 32'h00020000;
        end

        if (!on_ground) begin
            spd_o.y = appr(spd_i.y, maxfall, (abs(spd_i.y) > 32'h00002666 ? 32'h000035c2 : 32'h00001ae1)); 
        end

        wall_dir = '0;
        if (is_solid(pos_hitbox.x-3, pos_hitbox.y)) begin
            wall_dir = 32'hffff0000;
        end
        else if (is_solid(pos_hitbox.x+3, pos_hitbox.y)) begin
            wall_dir = 32'h00010000;
        end

        // jump
        if (jbuffer > '0) begin
            if (grace > '0) begin
                jbuffer = '0;
                grace = '0;
                spd_o.y = 32'hfffe0000; // -2
            end 
            else if (wall_dir != '0) begin
                jbuffer = '0;
                spd_o.y = 32'hfffe0000; // -2
                spd_o.x = -wall_dir << 1; // -wall_dir * (maxrun + 1)
            end
        end

        // todo dash

    end

    assign exit = $signed(pos_o.y) < $signed(16'hfffc);

    always_ff @(posedge clk) begin
        if (rst) begin
            p_jump    <= 1'b0;
            p_dash    <= 1'b0;
            jbuffer_r <= '0;
            grace_r   <= '0;
            dash_effect_time_r <= '0;
            djump_r   <= '0;
        end
        else begin
            p_dash    <= btn[BTN_X];
            p_jump    <= btn[BTN_O];
            jbuffer_r <= jbuffer;
            grace_r   <= grace;
            dash_effect_time_r <= dash_effect_time;
            djump_r   <= djump;
        end
    end

endmodule
