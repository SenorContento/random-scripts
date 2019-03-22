#!/bin/bash

black="\x1b[30m"
red="\x1b[31m"
green="\x1b[32m"
yellow="\x1b[33m"
blue="\x1b[34m"
magenta="\x1b[35m"
cyan="\x1b[36m"
white="\x1b[37m"
reset="\x1b[0m"

# I have to explicitly convert
# the ansi codes to bin before
# passing it through with sed!!!
black_bin=$(echo -e $black)
red_bin=$(echo -e $red)
green_bin=$(echo -e $green)
yellow_bin=$(echo -e $yellow)
blue_bin=$(echo -e $blue)
magenta_bin=$(echo -e $magenta)
cyan_bin=$(echo -e $cyan)
white_bin=$(echo -e $white)
reset_bin=$(echo -e $reset)

program=$(cat "$1")

colorize=$(echo "$program" |
sed s/\$black/$black_bin/g |
sed s/\$red/$red_bin/g |
sed s/\$green/$green_bin/g |
sed s/\$yellow/$yellow_bin/g |
sed s/\$blue/$blue_bin/g |
sed s/\$magenta/$magenta_bin/g |
sed s/\$cyan/$cyan_bin/g |
sed s/\$white/$white_bin/g |
sed s/\$reset/$reset_bin/g)

#echo -e "$colorize"
#rm npiet-foogol.png
echo -e "$colorize" | npiet-foogol -
npiet npiet-foogol.png