module uart (
    input logic clk,
    input logic rst,

    input logic [7:0] data_i,
    input logic data_valid_i,

    output logic TX,
    output logic ready_o
);
    
    localparam BAUD_RATE   = 115200;
    localparam CLK_FREQ    = 20_250_000;
    localparam PULSE_WIDTH = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] { 
        IDLE, START, DATA, STOP
    } state_t;

    state_t state, next_state;
    logic [31:0] clk_count;
    logic [2:0] data_count;

    logic [7:0] data_r;

    assign ready_o = next_state == IDLE;

    always_comb begin
        next_state = state;

        unique case (state)
            IDLE: begin
                if (data_valid_i)
                    next_state = START;  
            end
            START: begin
                if (clk_count == PULSE_WIDTH-1) 
                    next_state = DATA;
            end
            DATA: begin
                if (data_count == 3'd7 && clk_count == PULSE_WIDTH-1)
                    next_state = STOP;     
            end
            STOP: begin
                if (clk_count == PULSE_WIDTH-1)
                    next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
           data_count <= '0;
           clk_count  <= '0;
        end 
        else begin
            if (state == IDLE) begin
                data_count <= '0;
                clk_count  <= '0;
            end
            if (state == DATA && clk_count == PULSE_WIDTH-1) begin
                data_count <= data_count + 1;
                clk_count <= '0;
            end
            else if (state != DATA && state != next_state) begin
                clk_count <= '0;
            end
            else begin
                clk_count <= clk_count + 1'b1;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst) begin
           data_r     <= '0;
           TX         <= 1'b1;
        end
        else begin
            unique case (state)
                IDLE: begin
                    TX <= 1'b1;
                    data_r <= data_i;
                end
                START: begin
                    TX <= 1'b0;
                end
                DATA: begin
                    TX <= data_r[data_count];
                end
                STOP: begin
                    TX <= 1'b1;
                end
            endcase
        end
    end


endmodule
