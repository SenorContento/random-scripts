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

uploadDirectory="/var/web/term-uploads/"

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
  limiturl=$($echo ${userinput:1:13}) # Limit String to 13 Characters Max (For PHP uniqid)
  cleanurl=$($echo "$limiturl" | $cut -d/ -f2)
  #$echo "Clean URL: $cleanurl"

  # https://stackoverflow.com/a/20007549/6828099
  #stripped=$($echo "$userinput" | $sed $stripChars)
  stripped=$($echo "$cleanurl" | $tr -cd '[:alnum:]')
  #$echo "Stripped: $stripped"

  #$echo "Not Sanitized: ""$querystart$cleanurl$queryend"

  # Sanitize MySQL Input - https://stackoverflow.com/a/4383994/6828099
  sanitized=$($printf "%q" "$stripped")
  #$echo "Sanitized: ""$querystart$sanitized$queryend"
  # Printf is Not Perfect: hellothere\'\"
  #$echo "\"$sanitized\""

  if [ "$sanitized" == "''" ]; then # Empty String
    # TODO: Set Default Program ID Here
    mysqlOut="0	5c92cd6054ce1	Piet Quest	pietquest.png	Admin	Default Program For Server"
    return 0
  fi
  #echo "Ran"

  # Format of Response
  # id  programid programname filename  uploaderipaddress programabout
  # "1	5c92c662a53ef	Not Set	cowsay.png	71.31.185.234	Not Set" # Only this is output
  mysqlOut=$({
    $echo $password
  } | $mysql --silent -u $username -D $database -e "$querystart$sanitized$queryend" -p 2>/dev/null)
}

#stdbuf=/usr/local/bin/stdbuf
#npiet=/usr/local/bin/npiet

cd $($dirname "$0") # Changes to Program Directory
password=$($cat "$passwordFile")

# https://stackoverflow.com/a/39754497/6828099
executeMySQL "select * from programs where programid=\"" "\" LIMIT 1;" "$PATH_INFO"

$echo -e $cyan"Rover Piet Server"$reset
#$echo -e $red"Linux User: "`whoami`$reset # To Test Privileges Were Dropped Succesfully
#$echo -e $yellow"PWD: $PWD"$reset
#$echo -e $red"PW: $password"$reset
#$echo -e $red"MySQL Output: $mysqlOut"$reset

# TODO: Why does injecting tabs into the column data not break parsing the parameters?
rowID=$($echo "$mysqlOut" | $cut -f1)
programID=$($echo "$mysqlOut" | $cut -f2)
programName=$($echo "$mysqlOut" | $cut -f3) # Tab is default delimiter
originalfilename=$($echo "$mysqlOut" | $cut -f4)
uploaderIP=$($echo "$mysqlOut" | $cut -f5)
aboutProg=$($echo "$mysqlOut" | $cut -f6)

program=$uploadDirectory"piet_"$programID".png"

# id  programid programname filename  uploaderipaddress programabout
# "1	5c92c662a53ef	Not Set	cowsay.png	71.31.185.234	Not Set" # Only this is output

arguments=$($echo "$PATH_INFO" | $cut -d/ -f3)

if [ -z $arguments ]; then
  transarguments="None"
else
  transarguments=$arguments
fi

$echo -e $green"------------------------------------------------"$reset
#$echo -e $yellow"Path: $PATH_INFO" # This environment variable is created by WebSocketd!!!
$echo -e $yellow"Program Name: $programName"
$echo -e $yellow"Program ID: $programID"
$echo -e $yellow"Original File Name: $originalfilename"
$echo -e $yellow"Arguments: $transarguments"
#$echo -e $yellow"Uploader IP: $uploaderIP"
#$echo -e $yellow"About Program: $aboutProg"
$echo -e $green"------------------------------------------------"$reset

if [ -z $arguments ]; then
  # 2>/dev/null disables showing stderr
  $npiet "$program" 2>/dev/null | $stdbuf -o0 $awk '{print "'$($echo -e $cyan)'" $0 "'$($echo -e $reset)'"}'
  #$npiet "$program" | $stdbuf -o0 $awk '{print "'$($echo -e $cyan)'" $0 "'$($echo -e $reset)'"}'
else
  $echo -e "$arguments" | $npiet "$program" 2>/dev/null | $stdbuf -o0 $awk '{print "'$($echo -e $cyan)'" $0 "'$($echo -e $reset)'"}'
  #$echo -e "$arguments" | $npiet "$program" | $stdbuf -o0 $awk '{print "'$($echo -e $cyan)'" $0 "'$($echo -e $reset)'"}'
fi
$echo -e $reset

# Todo: Add Support for STDIN input with echo "$uservar-from-pathinfo" | $npiet...