#ifndef _XADC_CORE_H_INCLUDED
#define _XADC_CORE_H_INCLUDED

#include "init.h"
#include "io_rw.h"

class XadcCore
{
private:
    uint32_t base_addr;
public:
    enum {
        ADC_0_REG = 0,
        TMP_REG = 4,
        VCC_REG = 5,
    };
    XadcCore(uint32_t core_base_addr);
    ~XadcCore();
    uint16_t read_raw(int n);
    double read_adc_in(int n);
    double read_fpga_vcc();
    double read_fpga_temp();
};

#endif // _XADC_CORE_H_INCLUDED