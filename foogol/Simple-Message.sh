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

# The null bytes are to separate the text from the
# variables without causing a visible difference
# They don't even show up in the output in hex
message=$red"Hello World!!!\x00$reset
$cyan\x00Coolio!!!$reset"

#echo -e "$message"

program='begin prints ("'$(echo -e "$message")'") end'

#echo -e "$program"

echo -e "$program" | npiet-foogol -
npiet npiet-foogol.png