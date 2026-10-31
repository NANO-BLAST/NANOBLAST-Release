create_project -force -name nanoblast_snes -dir {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2/project} -pn GW2AR-LV18QN88C8/I7 -device_version C
cd {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2}
set_device GW2AR-LV18QN88C8/I7 -device_version C
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/nanoblast/config.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/ALU.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/AddSubBCD.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/AddrGen.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/BCDAdder.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/P65C816.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/adder4.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/bit_adder.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/common.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/65C816/mcode.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/CEGen.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/chip/DSP/DSP_LHRomMap.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/chip/DSP/DSPn.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/chip/DSP/OBC1.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/chip/DSP/SRTC.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/cpu.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/dsp.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/dual_clk_fifo.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/dualshock_controller.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/main.v}
add_file -type verilog {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2/ppu_pause.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/ppucgram.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/ppuhoam.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/ppuoam.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/smc_parser.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/smp.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/snes.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/controller_adapter.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/controller_ds2.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/controller_snes.v}
add_file -type verilog {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2/snestang_top.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/_spc700_package.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/addrgen.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/addsub.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/alu.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/bcdadj.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/mcode.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/muldiv.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700/spc700.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/swram.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/uart_tx_V2.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/nanoblast/rtl/snes_regfile.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/nanoblast/rtl/snes_echo_history.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/nanoblast/rtl/snes_hdmi_audio_buffer.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/audio_clock_regeneration_packet.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/audio_info_frame.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/audio_sample_packet.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/auxiliary_video_information_info_frame.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/hdmi.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/packet_assembler.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/nanoblast/hdmi/packet_picker.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/serializer.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/source_product_description_info_frame.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hdmi2/tmds_channel.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/src/sdram_nano.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/src/snes2hdmi_nano.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/menu_background.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/cdc_mailbox.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/reset_release.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/hw_uart.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/iosys/mcu_uart.v}
add_file -type verilog {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2/textdisp.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/iosys/nanoblast_iosys.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/iosys/nanoblast_menu_link.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/iosys/nanoblast_sd_spi.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/nanoblast/rtl/snes_rom_diagnostics.sv}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/src/pllr/gowin_pll_snes.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang/src/pllr/gowin_pll_hdmi.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/gowin_dpb_cgram.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/gowin_dpb_hoam.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/gowin_dpb_oam.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/chip/dsp/dsp_data_ram.v}
add_file -type verilog {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/nanoblast/src/iosys/gowin_dpb_menu.v}
add_file -type cst {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2/snes.cst}
add_file -type sdc {/Users/ryan/.codex/.chatgpt-projects/g-p-6acffe418adc8191a51ffd9aaac8af25/nanoblast-setup/hardware-tests/solid-loading/snes-pixel-pipeline2/snes.sdc}
set_option -synthesis_tool gowinsynthesis
set_option -top_module snestang_top
set_option -verilog_std sysv2017
set_option -include_path {/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src;/Users/ryan/Documents/Codex/2026-10-14/is-x20/work/snestang-v09-reference/src/spc700}
set_option -output_base_name snestang_nano20k
set_option -rw_check_on_ram 1
set_option -place_option 2
set_option -route_option 2
set_option -use_mspi_as_gpio 1
set_option -use_sspi_as_gpio 1
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1
set_option -use_i2c_as_gpio 1
set_option -use_cpu_as_gpio 1
set_option -multi_boot 1
run all
