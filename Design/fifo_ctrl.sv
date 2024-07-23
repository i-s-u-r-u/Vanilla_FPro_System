module fifo_ctrl
    #(parameter ADDR_WIDTH=3)(
    input logic clk, reset,
    input logic wr, rd,
    output logic full, empty,
    output logic [ADDR_WIDTH-1:0] w_addr,
    output logic [ADDR_WIDTH-1:0] r_addr
    );
    logic [ADDR_WIDTH-1:0] w_ptr_logic, w_ptr_next, w_ptr_succ;
    logic [ADDR_WIDTH-1:0] r_ptr_logic, r_ptr_next, r_ptr_succ;
    logic full_logic, empty_logic, full_next, empty_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            w_ptr_logic <= 0;
            r_ptr_logic <= 0;
            full_logic <= 1'b0;
            empty_logic <= 1'b1;
        end else begin
            w_ptr_logic <= w_ptr_next;
            r_ptr_logic <= r_ptr_next;
            full_logic <= full_next;
            empty_logic <= empty_next;
        end
    end

    always_comb begin
        w_ptr_succ = w_ptr_logic + 1;
        r_ptr_succ = r_ptr_logic + 1;
        w_ptr_next = w_ptr_logic;
        r_ptr_next = r_ptr_logic;
        full_next = full_logic;
        empty_next = empty_logic;

        unique case ({wr, rd})
            2'b01: // read
                if (~empty_logic) begin
                    r_ptr_next = r_ptr_succ;
                    full_next = 1'b0;
                    if (r_ptr_succ == w_ptr_logic) begin
                        empty_next = 1'b1;
                    end
                end
            2'b10: // write
                if (~full_logic) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr_logic) begin
                        full_next = 1'b1;
                    end
                end
            2'b11: begin // read and write
                w_ptr_next = w_ptr_succ;
                r_ptr_next = r_ptr_succ;    
            end
            default: ;
        endcase
    end

    assign w_addr = w_ptr_logic;
    assign r_addr = r_ptr_logic;
    assign full = full_logic;
    assign empty = empty_logic;

endmodule