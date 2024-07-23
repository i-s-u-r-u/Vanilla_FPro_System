module timer (
    input logic clk,
    input logic reset,
    // Slot Interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
);
    logic [47:0] count_reg;
    logic ctrl_reg;
    logic wr_en, clear, go;

    // Counter
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else begin
            if (clear) begin
                count_reg <= 0;
            end else if (go) begin
                count_reg <= count_reg + 1;
            end
        end
    end
    
    // Wrapper
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            ctrl_reg <= 0;
        end else begin
            if (wr_en) begin
                ctrl_reg <= wr_data[0];
            end
        end
    end

    assign wr_en = write && cs && (addr[1:0] == 2'b10);
    assign clear = wr_en && wr_data[1];
    assign go = ctrl_reg;

    assign rd_data = (addr[0] == 0) ? count_reg[31:0] : {16'h0000, count_reg[47:32]};

endmodule