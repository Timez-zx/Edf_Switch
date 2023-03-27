#!/bin/bash

#sh的全局变量，由于arr_file采用递归，只可用一个总变量
arr_file=()

#getdir:将路径下的所有文件路径读出添加到arr_file数组中
function getdir(){
    for element in `ls $1`
    do  
        dir_or_file=$1"/"$element
        if [ -d $dir_or_file ]
        then 
            getdir $dir_or_file
        else
            length=${#dir_or_file}
            if [ ${dir_or_file:0-2:2} == ".v" ]
            then
                arr_file=(${arr_file[@]} $dir_or_file)
            fi
        fi  
    done
}

#读取路径下的文件，并返回值，参数输入例子:get_file $src_path
#函数传入参数不可改变，可以通过echo返回参数，接收返回值 src_array=($(get_file $src_path))
#若没有接受，则直接输出
function get_file(){
    unset arr_file
    getdir $1
    local arr=(${arr_file[*]})
    echo ${arr[*]}
}