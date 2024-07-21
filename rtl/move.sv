import utils::*;

module move (
    input vec2dint pos_i,
    input vec2d rem_i,
    input vec2d spd_i,

    output vec2dint pos_o,
    output vec2d rem_o,
    output vec2d spd_o
);
    //localparam MAX_STEP = 6;

    logic [31:0] amt;
    logic [15:0] step;
    
    initial begin
        //$readmemh("map.mem", p8_map);
        //$readmemh("flags.mem", flags);
        
        // 100m hack for berry blocks
        p8_map[4][1] = 1'b1;
        p8_map[4][2] = 1'b1;
        p8_map[5][1] = 1'b1;
        p8_map[5][2] = 1'b1;
    end

    always_comb begin
        rem_o.x = rem_i.x + spd_i.x;
        rem_o.y = rem_i.y + spd_i.y;

        // move x
        amt = (rem_o.x + 32'h00008000) & 32'hffff0000; // + 0.5
        rem_o.x = rem_o.x - amt;
        
        step = amt[31] == 1 ? 16'(amt >> 16)-1 : 16'(amt >> 16) + 1;

        pos_o.x = pos_i.x;
        spd_o.x = spd_i.x;

        pos_o.y = pos_i.y;
        spd_o.y = spd_i.y;

        if (step != 1) begin
            if (!is_solid(step + pos_o.x + 1, pos_o.y + 3, 6, 5)) begin
                pos_o.x = pos_o.x + step;
            end
            else begin
                spd_o.x = '0;
                rem_o.x = '0;
                pos_o.x = step[15] == 1 ? (((step+pos_o.x+1)+8) & 16'hfff8)-1 : ((step+pos_o.x) & 16'hfff8)+1;
            end
        end

        // move y
        amt = (rem_o.y + 32'h00008000) & 32'hffff0000; // + 0.5
        rem_o.y = rem_o.y - amt;

        step = amt[31] == 1 ? 16'(amt >> 16)-1 : 16'(amt >> 16) + 1;

        if (step != 1) begin
            if (!is_solid(pos_o.x + 1, step + pos_o.y + 3, 6, 5)) begin
                pos_o.y = pos_o.y + step;
            end
            else begin
                spd_o.y = '0;
                rem_o.y = '0;
                pos_o.y = step[15] == 1 ? ((((step+pos_o.y)+8) & 16'hfff8)-3) : ((step+pos_o.y) & 16'hfff8);
            end
        end

        //step = signint(amt);

        
        // for (int i = 0; i < MAX_STEP; i = i + 1) begin
        //     if (i == (abs(amt) >> 16)+1) break;
            
        //     if (!is_solid((pos_o.x)+1, (pos_o.y)+(step)+3, 6, 5)) begin
        //         pos_o.y = pos_o.y + step;
        //     end
        //     else begin
        //         spd_o.y = '0;
        //         rem_o.y = '0;
        //         break;
        //     end
            
        // end
    end

endmodule
