#!/bin/bash
# Original Test: /home/alex/websocketd/websocketd --port=8081 bash -c '/usr/bin/stdbuf -o0 /usr/local/bin/npiet /home/web/programs/piet/images/pietquest.png 2>&1'
# Current Command: /home/alex/websocketd/websocketd --port=8081 bash -c '/home/alex/programs/piet-launcher.sh /home/web/programs/piet/images/pietquest.png 2>&1'

# Colors: http://www.lihaoyi.com/post/BuildyourownCommandLinewithANSIescapecodes.html
# Black: \u001b[30m
# Red: \u001b[31m
# Green: \u001b[32m
# Yellow: \u001b[33m
# Blue: \u001b[34m
# Magenta: \u001b[35m
# Cyan: \u001b[36m
# White: \u001b[37m
# Reset: \u001b[0m

black="\u001b[30m"
red="\u001b[31m"
green="\u001b[32m"
yellow="\u001b[33m"
blue="\u001b[34m"
magenta="\u001b[35m"
cyan="\u001b[36m"
white="\u001b[37m"
reset="\u001b[0m"

stdbuf=/usr/bin/stdbuf
npiet=/usr/local/bin/npiet

#stdbuf=/usr/local/bin/stdbuf
#npiet=/usr/local/bin/npiet

if [ $# -lt 1 ]
then
  echo -e $red "You Need To Specify A Command!!!"
  echo -e "./program piet-program-path" $reset
  exit
fi

program="$1"

echo -e $cyan"Rover Piet Server"
echo -e $green"------------------------------------------------"
$npiet $program | $stdbuf -o0 awk '{print "'$(echo -e $cyan)'" $0 "'$(echo -e $reset)'"}'
echo -e $reset