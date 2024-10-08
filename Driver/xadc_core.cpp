#include "xadc_core.h"

XadcCore::XadcCore(uint32_t core_base_addr)
{
    base_addr = core_base_addr;
}

XadcCore::~XadcCore(){}

uint16_t XadcCore::read_raw(int n)
{
    uint16_t rd_data;
    rd_data = (uint16_t) io_read(base_addr, ADC_0_REG + n) & 0x0000ffff;
    return (rd_data);
}

double XadcCore::read_adc_in(int n)
{
    uint16_t raw;
    
    raw = read_raw(n) >> 4;
    return ((double) raw / 4096.0);
}

double XadcCore::read_fpga_vcc()
{
    return (read_adc_in(VCC_REG) * 3.0);
}

double XadcCore::read_fpga_temp()
{
    return (read_adc_in(TMP_REG) * 503.975 - 273.15);
}