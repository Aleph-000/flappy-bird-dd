open_project flappy-bird.xpr

# 防止 Vivado 工程文件漏源：每次构建前都确保所有 RTL 在 sources_1 中。
set rtl_files [list \
    src/rtl/game/bird.v \
    src/rtl/game/collision.v \
    src/rtl/game/pipe.v \
    src/rtl/control/input_control.v \
    src/rtl/control/skin_control.v \
    src/rtl/core/game_core.v \
    src/rtl/display/vga_ctrl.v \
    src/rtl/display/bg_layer.v \
    src/rtl/display/pipe_layer.v \
    src/rtl/display/bird_sprite_rom.v \
    src/rtl/display/bird_layer.v \
    src/rtl/display/ui_layer.v \
    src/rtl/display/display.v \
    src/rtl/audio/audio_effects.v \
    src/rtl/top/top_k7.v \
]

foreach rtl_file $rtl_files {
    set normalized_file [file normalize $rtl_file]
    if {[llength [get_files -quiet $normalized_file]] == 0} {
        add_files -fileset sources_1 -norecurse $normalized_file
    }
}

set_property top top_k7 [get_filesets sources_1]
update_compile_order -fileset sources_1

# 关闭增量综合，避免引用不存在的 utils_1/imports/synth_1/top_k7.dcp。
catch {set_property AUTO_INCREMENTAL_CHECKPOINT false [get_runs synth_1]}
catch {set_property INCREMENTAL_CHECKPOINT "" [get_runs synth_1]}
catch {set_property AUTO_INCREMENTAL_CHECKPOINT false [get_runs impl_1]}

reset_run synth_1
reset_run impl_1
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_run impl_1

set impl_status [get_property STATUS [get_runs impl_1]]
puts "impl_1 status: $impl_status"

if {[string first "Complete" $impl_status] < 0} {
    puts "ERROR: implementation did not complete"
    exit 1
}

if {![file exists "flappy-bird.runs/impl_1/top_k7.bit"]} {
    puts "ERROR: bitstream file was not generated"
    exit 1
}

puts "Bitstream generated: flappy-bird.runs/impl_1/top_k7.bit"
exit 0
