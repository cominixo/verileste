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

logic p8_map [16][16] = '{{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1}, {1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1}, {1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, {1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, {1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}, {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1}, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1}, {0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {0, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1}, {1, 1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1}, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1}};
//logic [7:0] flags [128];

parameter SF = 2.0**-16.0; 

function logic solid_at (logic [15:0] x, logic [15:0] y);
    solid_at = p8_map[4'(y)][4'(x)];
endfunction

function logic [31:0] appr (logic signed [31:0] val, logic signed [31:0] target, logic signed [31:0] amount);
    logic signed [31:0] val_minus;
    logic signed [31:0] val_plus;
    val_minus = val-amount;
    val_plus = val+amount;
    
    appr = val > target ? (val_minus > target ? val_minus : target) : (val_plus < target ? val_plus : target);
endfunction

function logic is_solid (logic [15:0] obj_x, logic [15:0] obj_y, int w, int h);
    
    // TODO these can be smaller
    logic [15:0] tile_x; 
    logic [15:0] tile_y;
    
    logic flag_00;
    logic flag_01;
    logic flag_10;
    logic flag_11;
    
    // TODO if obj_x[31] == 1'b1
    if (obj_x[15] == 1'b1) begin
        obj_x = '0;
    end

    if (obj_y[15] == 1'b1) begin
        obj_y = '0;
    end

     // TODO also limit (obj_x+w-1) and (obj_y+h-1) to 15

    tile_x = obj_x >> 3;
    tile_y = obj_y >> 3;
    
    flag_00 = solid_at(tile_x, tile_y);
    flag_01 = solid_at(tile_x, tile_y+1);
    flag_10 = solid_at(tile_x+1, tile_y);
    flag_11 = solid_at(tile_x+1, tile_y+1);

    // TODO maybe can simplify this
    if (tile_x < (obj_x+16'(w-1))>>3) begin
        if (tile_y < (obj_y+16'(h-1)) >> 3) begin
            is_solid = flag_00 || flag_01 || 
                       flag_10 || flag_11;
        end
        else begin
            is_solid = flag_00 || flag_10;
        end
    end
    else begin
        if (tile_y < (obj_y+16'(h-1)) >> 3) begin
            is_solid = flag_00 || flag_01;
        end
        else begin
            is_solid = flag_00;
        end
    end
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
