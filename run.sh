#!/bin/bash
source getfile.sh
#需要编译文件的总路径，根据不同工程修改
origin="./Switch/EDF_switch"
#tb的路径和文件，根据不同测试需要修改
tb_path=$origin"/tb/"
tb_file="top_testbench_ddl.v"
#src需要的路径和文件，一般按照规则创建，不需要修改
src_path=$origin"/src/"
src_array=($(get_file $src_path))



echo ${src_array[*]} $tb_path$tb_file
echo "开始编译"
iverilog -o $origin"/wave" ${src_array[*]} $tb_path$tb_file
echo "编译完成"
echo "生成波形文件"
vvp $origin/wave
echo "打开波形文件"
#open -a Scansion wave.vcd
open -a gtkwave wave.vcd





