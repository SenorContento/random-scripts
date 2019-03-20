#!/bin/bash
# Original Test: /home/alex/websocketd/websocketd --port=8081 bash -c '/usr/bin/stdbuf -o0 /usr/local/bin/npiet /home/web/programs/piet/images/pietquest.png 2>&1'
# Old Command: /home/alex/websocketd/websocketd --port=8081 bash -c '/home/alex/programs/piet-launcher.sh /home/web/programs/piet/images/pietquest.png 2>&1'
# Current Command: /home/alex/websocketd/websocketd --port=8081 bash -c '/usr/bin/setuidgid piet /home/alex/programs/piet-launcher.sh 2>&1'

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

# websocketd Information
# https://github.com/joewalnes/websocketd/wiki/Environment-variables

username="piet"
passwordFile="piet-password.txt"
database="piet"

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
dirname=/usr/bin/dirname
mysql=/usr/bin/mysql
cat=/bin/cat
echo=echo #/bin/echo
printf=/usr/bin/printf
cut=/usr/bin/cut
awk=/usr/bin/awk
#sed=/bin/sed
tr=/usr/bin/tr

executeMySQL() {
  # 's/-\([0-9.]\+\)/(\1)/g'
  #stripChars="s/\(\[a-z\]||[A-Z]||[0-9]\)/g" #/([a-z]||[A-Z]||[0-9])\w+/g
  querystart="$1"
  queryend="$2"
  userinput="$3"

  # https://stackabuse.com/substrings-in-bash/
  limiturl=$($echo ${userinput:1:10}) # Limit String to 10 Characters Max
  cleanurl=$($echo "$limiturl" | $cut -d/ -f2)
  #$echo "Clean URL: $cleanurl"

  # https://stackoverflow.com/a/20007549/6828099
  #stripped=$($echo "$userinput" | $sed $stripChars)
  stripped=$($echo "$cleanurl" | $tr -cd '[:alnum:]')
  #$echo "Stripped: $stripped"

  #$echo "Not Sanitized: ""$querystart$cleanurl$queryend"

  # Sanitize MySQL Input - https://stackoverflow.com/a/4383994/6828099
  sanitized=$($printf "%q" "$stripped")
  $echo "Sanitized: ""$querystart$sanitized$queryend"
  # Printf is Not Perfect: hellothere\'\"
  #$echo "\"$sanitized\""

  if [ "$sanitized" == "''" ]; then # Empty String
    # TODO: Set Default Program ID Here
    #mysqlOut="/home/web/programs/piet/images/pietquest.png"
    #echo "Empty"
    return 0 # Remove Me When Added Default Program ID
  fi
  #echo "Ran"

  mysqlOut=$({
    $echo $password
  } | $mysql -u $username -D $database -e "$querystart$sanitized$queryend" -p 2>&1) # TODO: Remove Redirect Error For Output
}

#stdbuf=/usr/local/bin/stdbuf
#npiet=/usr/local/bin/npiet

cd $($dirname "$0") # Changes to Program Directory
password=$($cat "$passwordFile")

# https://stackoverflow.com/a/39754497/6828099
executeMySQL "select * from programs where programid=" " LIMIT 1;" "$PATH_INFO"

$echo -e $cyan"Rover Piet Server"$reset
#$echo -e $red"Linux User: "`whoami`$reset # To Test Privileges Were Dropped Succesfully
#$echo -e $yellow"PWD: $PWD"$reset
#$echo -e $red"PW: $password"$reset
$echo -e $red"MySQL Output: $mysqlOut"$reset


program="/home/web/programs/piet/images/pietquest.png"
#$echo -e $yellow"Path: $PATH_INFO" # This environment variable is created by WebSocketd!!!
$echo -e $green"------------------------------------------------"$reset
$npiet "$program" | $stdbuf -o0 $awk '{print "'$($echo -e $cyan)'" $0 "'$($echo -e $reset)'"}'
$echo -e $reset

# Todo: Add Support for STDIN input with echo "$uservar-from-pathinfo" | $npiet...