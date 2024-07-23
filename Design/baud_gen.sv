module baud_gen(
    input logic clk, reset,
    input logic [10:0] dvsr,
    output logic tick
);
    logic [10:0] r_reg;
    logic [10:0] r_next;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            r_reg <= 0;
        end else begin
            r_reg <= r_next;
        end
    end

    assign r_next = (r_reg == dvsr) ? 0 : r_reg + 1;

    assign tick (r_reg == 1);
    
endmodule