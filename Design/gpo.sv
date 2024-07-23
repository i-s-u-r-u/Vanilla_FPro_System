module gpo #(
    parameter W = 8
) (
    input logic clk,
    input logic reset,
    // Slot Interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // External Signal
    output logic [W-1:0] dout
);
    logic [W-1:0] buf_reg;
    logic wr_en;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            buf_reg <= 0;
        end else begin
            if (wr_en) begin
                buf_reg <= wr_data[W-1:0];
            end
        end
    end

    assign wr_en = cs && write;
    assign rd_data = 0;
    assign dout = buf_reg;
    
endmodule