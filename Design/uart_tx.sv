module name #(
    parameter DBIT = 8, SB_TICK = 16
) (
    input logic clk, reset,   
    input logic tx_start, s_tick,
    input logic [7:0] din,
    output logic tx_done_tick,
    output logic tx
);
    typedef enum { IDLE, START, DATA, STOP } state;

    state state_reg, state_next;
    logic [3:0] s_reg, s_next; // Keeps track of number of sampling ticks
    logic [2:0] n_reg, n_next; // Keeps track of the number of bits transmitted
    logic [7:0] b_reg, b_next; // Store the bits to tx
    logic tx_reg, tx_next;     // Transmitting bit (One bit buffer) Filter out any potential glitch

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1; // Keeps medium IDLE
        end else begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
        end
    end
    
    always_comb begin
        state_next = state_reg;
        tx_done_tick = 1'b0;
        s_next = s_reg;
        n_next = n_reg;
        b_next = b_reg;
        tx_next = tx_reg;

        case (state_reg)
            IDLE: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = START;
                    s_next = 0;
                    b_next = din;
                end
            end
            START: begin
                tx_next = 1'b0; // denotes the start of the tx
                if (s_tick) begin // s_tick is the enable tick from baud rate generator
                    if (s_reg == 15) begin // counts 15 sampling ticks to start the transmission
                        state_next = DATA;
                        s_next = 0; // reset the sampling ticks counter
                        n_next = 0; // reset the transmitted bits counter
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            DATA: begin
                tx_next = b_reg[0]; // sends bit by bit to the tx buffer (tx buffer sends bit to the outside world)
                if (s_tick) begin // s_tick is the enable tick from baud rate generator
                    if (s_reg == 15) begin // counts 15 sampling ticks to send each bit
                        s_next = 0;        // reset sampling tick count after sending each bit
                        b_next = b_reg >> 1; // right shift the data buffer (in each tx stage LSB bit is transmitted)
                        if (n_reg == (DBIT-1)) begin // stop condition for data transmission
                            state_next = STOP;
                        end else begin
                            n_next = n_reg + 1; // update bit counter after each transmission
                        end
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
            STOP: begin
                tx_next = 1'b1; // denotes the end of the tx
                if (s_tick) begin
                    if (s_reg == (SB_TICK-1)) begin // counts SB_TICK-1 sampling ticks to stop receiving
                        state_next = IDLE;
                        tx_done_tick = 1'b1;
                    end else begin
                        s_next = s_reg + 1;
                    end
                end
            end
        endcase
    end

    assign tx = tx_reg;

endmodule