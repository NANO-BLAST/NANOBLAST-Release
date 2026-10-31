// Only first-stage synchronizer DATA inputs are asynchronous. Keep the
// second-stage and all destination-domain logic timed normally.
set_false_path -to [get_pins {u_hdmi/audio_bridge/req_meta*/D u_hdmi/audio_bridge/ack_meta*/D u_hdmi/overlay_meta*/D background/req_meta*/D background/ack_meta*/D background/enable_meta*/D background/overlay_meta*/D iosys/background_pixel_meta*/D iosys/background_underflow_meta*/D iosys/disp/panel_bridge/req_meta*/D iosys/disp/panel_bridge/ack_meta*/D}]

// Reset assertion is asynchronous. Its release is local and two-stage;
// exclude only the asynchronous clear inputs of the reset-release chains.
set_false_path -from [get_pins {sys_resetn*/Q}] -to [get_pins {reset_pixel/pipe*/CLEAR}]
set_false_path -from [get_pins {sys_resetn*/Q}] -to [get_pins {iosys/disp/panel_release/pipe*/CLEAR}]

// Bundled words are held through acknowledgment. Bound their physical
// path delay instead of assuming a fixed inter-PLL clock phase. Hold is
// guaranteed by the acknowledgment round trip, not by an edge relationship.
set_max_delay -from [get_pins {u_hdmi/audio_bridge/held_data*/Q}] -to [get_pins {u_hdmi/audio_bridge/dst_data*/D}] 12.0
set_false_path -hold -from [get_pins {u_hdmi/audio_bridge/held_data*/Q}] -to [get_pins {u_hdmi/audio_bridge/dst_data*/D}]
set_max_delay -from [get_pins {iosys/disp/panel_bridge/held_data*/Q}] -to [get_pins {iosys/disp/panel_bridge/dst_data*/D}] 12.0
set_false_path -hold -from [get_pins {iosys/disp/panel_bridge/held_data*/Q}] -to [get_pins {iosys/disp/panel_bridge/dst_data*/D}]
set_max_delay -from [get_pins {background/requested_line*/Q}] -to [get_pins {background/writing_line*/D background/bg_addr*/D}] 12.0
set_false_path -hold -from [get_pins {background/requested_line*/Q}] -to [get_pins {background/writing_line*/D background/bg_addr*/D}]
report_timing -hold -max_paths 100 -max_common_paths 1
report_timing -setup -max_paths 100 -max_common_paths 1
report_timing -setup -from [get_clocks {pixel}] -to [get_clocks {pixel}] -max_paths 10
