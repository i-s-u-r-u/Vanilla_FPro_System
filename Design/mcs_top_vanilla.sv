module mcs_top_vanilla #(
    parameter BRG_BASE = 32'hc000_0000
) (
    
    input logic clk,
    input logic reset_n,
    // Switches and LEDs
    input logic [15:0] sw,
    output logic [15:0] led,
    // UART
    input logic rx,
    output logic tx
);
    logic clk_100M;
    logic reset_sys;
    // MCS IO Bus
    logic io_addr_strobe;
    logic io_read_strobe;
    logic io_write_strobe;
    logic [3:0] io_byte_enable;
    logic [31:0] io_address;
    logic [31:0] io_write_data;
    logic [31:0] io_read_data;
    logic io_ready;
    //FPro Bus
    logic fp_mmio_cs;
    logic fp_wr;
    logic fp_rd;
    logic [20:0] fp_addr;
    logic [31:0] fp_wr_data;
    logic [31:0] fp_rd_data;

    assign clk_100M = clk;
    assign reset_sys = ~reset_n;

    cpu cpu_unit
    (
        .Clk(clk),
        .Reset(reset_sys),
        .IO_Addr_Strobe(io_addr_strobe),
        .IO_Read_Strobe(io_read_strobe),
        .IO_Write_Strobe(io_write_strobe)
        .IO_Address(io_address),
        .IO_Byte_Enable(io_byte_enable),
        .IO_Write_Data(io_write_data),
        .IO_Read_Data(io_read_data),
        .IO_Ready(io_ready)     
    );

    mcs_bridge #(.BRG_BASE(BRG_BASE)) bridge_unit (.*, .fp_video_cs());

    mmio_sys_vanilla #(.N_SW(16), .N_LED(16)) mmio_unit
    (
        .clk(clk),
        .reset(reset),
        .mmio_cs(fp_mmio_cs),
        .mmio_wr(fp_wr),
        .mmio_rd(fp_rd),
        .mmio_addr(fp_addr),
        .mmio_wr_data(fp_wr_data),
        .mmio_rd_data(fp_rd_data),
        .sw(sw),
        .led(led),
        .rx(rx),
        .tx(tx)
    );

endmodule