#ifndef PROGRAMMER_H
#define PROGRAMMER_H

#include <cstddef>
#include <cstdint>

#ifdef __cplusplus
extern "C" {
#endif

extern const char *fpga_program_diagnostic();
extern void fpga_reload_boot_core();
extern bool fpga_persist_core(bool verify=true);
extern bool fpga_persist_asset(unsigned id,bool verify);
extern bool fpga_activate_staged();
extern bool fpga_stage_core(const char *fname);
extern bool fpga_activate_asset(unsigned id);
extern const char *fpga_persist_diagnostic();
extern const char *fpga_boot_flash_diagnostic();

// main function: program FPGA with a bitstream (.bin) file
// return true if successful
extern bool fpga_program(const char *fname);

#ifdef __cplusplus
}
#endif

#endif // PROGRAMMER_H
