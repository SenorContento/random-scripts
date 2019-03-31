#!/bin/bash
maldet=/usr/local/sbin/maldet
dirname=/usr/bin/dirname
mysql=/usr/bin/mysql
cat=/bin/cat
echo=echo #/bin/echo
cd=cd
tail=/usr/bin/tail
nice=/usr/bin/nice

mysqlAuth=/home/alex/mysql_auth/maldet-password.cnf
database="$2"

uploadDirectory="/var/web/term-uploads/"
niceValue=19

programid="$1"

$cd $($dirname "$0") # Changes to Program Directory

$echo "Scanning For Viruses"
#$echo "$maldet --scan-all $uploadDirectory piet_ $programid .png && echo passed || echo failed"
maldet_output=$($nice -n $niceValue $maldet --scan-all $uploadDirectory"piet_"$programid".png" && $echo "Passed" || $echo "Failed")
#exitcode="$?"
$echo "Finished Scan!!!"

$echo -e "$maldet_output"
maldet_output=$($echo -e "$maldet_output" | $tail -n 1)

# https://stackoverflow.com/a/8230301/6828099
#$echo "Exit Code: \"$exitcode\"";
$echo "Maldet Output: $maldet_output"
if [ "$maldet_output" == "Failed" ]; then
  $echo "Failed Virus Scan!!!"
  query="UPDATE programs SET allowed='0', banreason='Failed Virus Scan' WHERE programid='$programid';"

  $mysql --defaults-file="$mysqlAuth" --silent -D $database -e "$query" 2>/dev/null

  # create table VirusScans (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, programid TEXT NOT NULL, failed INT)
  query="insert into VirusScans (programid, failed) VALUES ('$programid', 1);"

  $mysql --defaults-file="$mysqlAuth" --silent -D $database -e "$query" 2>/dev/null
else
  $echo "Passed Virus Scan!!!"

  # create table VirusScans (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, programid TEXT NOT NULL, failed INT)
  query="insert into VirusScans (programid, failed) VALUES ('$programid', 0);"

  # https://stackoverflow.com/a/12513143/6828099
  # --defaults-extra-file
  $mysql --defaults-file="$mysqlAuth" --silent -D $database -e "$query" 2>/dev/null
fi