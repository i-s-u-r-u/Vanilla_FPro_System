module uart_rx #(
    parameter DBIT = 8, SB_TICK = 16
) (
    input logic clk, reset,
    input logic rx, s_tick,
    output logic rx_done_tick,
    output logic [7:0] dout
);
    typedef enum { IDLE, START, DATA, STOP } state;

    state state_reg, state_next;
    logic [3:0] s_reg, s_next; // Keeps track of number of sampling ticks
    logic [2:0] n_reg, n_next; // Keeps track of the number of bits received
    logic [7:0] b_reg, b_next; // Reassemble the retrieved bits
    
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
        end
    end

    always_comb begin
        state_next = state_reg;
        rx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;

        case (state_reg)
            IDLE:
                if (~rx) begin
                    state_next = START;
                    s_next = 0;
                end
            START:
                if (s_tick) begin // s_tick is the enable tick from baud rate generator
                    if (s_reg == 7) begin // counts 7 sampling ticks to start the receiving
                        state_next = DATA;
                        s_next = 0;
                        n_next = 0;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            DATA:
                if (s_tick) begin
                    if (s_reg == 15) begin // counts 15 sampling ticks to receive each bit
                        s_next = 0;        // reset sampling tick count after reading each bit
                        b_next = {rx, b_reg[7:1]}; // concat the received bit in the MSB position
                        if (n_reg == (DBIT-1)) begin // stop condition for data retrieval (all 8 bits received)
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1; // updates bit counter after each retrieval
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            STOP:
                if (s_tick) begin
                    if (s_reg == (SB_TICK-1)) begin // counts SB_TICK-1 sampling ticks to stop receiving
                        state_next = IDLE;
                        rx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
        endcase
    end

    assign dout = b_reg;

endmodule