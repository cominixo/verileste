package utils;

typedef struct packed {
    logic [31:0] x, y;
} vec2d;

typedef struct packed {
    logic [15:0] x, y;
} vec2dint;

typedef struct packed {
    logic [31:0] x, y, w, h;
} box;

logic solid_map [128][128];

parameter SF = 2.0**-16.0; 


function logic [31:0] appr (logic signed [31:0] val, logic signed [31:0] target, logic signed [31:0] amount);
    logic signed [31:0] val_minus;
    logic signed [31:0] val_plus;
    val_minus = val-amount;
    val_plus = val+amount;
    
    appr = val > target ? (val_minus > target ? val_minus : target) : (val_plus < target ? val_plus : target);
endfunction

function logic [31:0] appr_pos (logic signed [31:0] val, logic signed [31:0] target, logic signed [31:0] amount);
    logic signed [31:0] val_minus;
    val_minus = val-amount;

    appr_pos = (val_minus > target ? val_minus : target);
endfunction

function logic is_solid (logic [15:0] obj_x, logic [15:0] obj_y);

    if (obj_x[15] == 1'b1) begin
        obj_x = '0;
    end

    if (obj_y[15] == 1'b1) begin
        obj_y = '0;
    end
    
    is_solid = solid_map[7'(obj_y)][7'(obj_x)];

endfunction

function logic [31:0] abs (logic [31:0] num);
    abs = num[31] == 1'b1 ? -num : num;
endfunction

function logic [31:0] sign (logic [31:0] num);
    sign = num[31] == 1'b1 ? 32'hffff0000 : num == '0 ? '0 : 32'h00010000;
endfunction

function logic [15:0] signint (logic [31:0] num);
    signint = num[31] == 1'b1 ? 16'hffff : num == '0 ? '0 : 16'h0001;
endfunction

function logic [7:0] tohex (logic [3:0] nibble);
    if (nibble > 4'h9) begin
        tohex = {4'b0, nibble} + 8'h57;
    end
    else begin
        tohex = {4'h3, nibble};
    end
endfunction

endpackage
