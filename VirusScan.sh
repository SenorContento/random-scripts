#!/bin/bash
maldet=/usr/local/sbin/maldet
dirname=/usr/bin/dirname
mysql=/usr/bin/mysql
cat=/bin/cat
echo=echo #/bin/echo
cd=cd

username="maldet"
passwordFile="maldet-password.txt"
database="piet"

uploadDirectory="/var/web/term-uploads/"
niceValue=19

programid="$1"

$cd $($dirname "$0") # Changes to Program Directory
password=$($cat "$passwordFile")

$echo "Scanning For Viruses"
$maldet --scan-all $uploadDirectory"piet_"$programid".png";

# https://stackoverflow.com/a/8230301/6828099
if [ "$?" != "0" ]; then
  $echo "Failed Virus Scan!!!"
  query="UPDATE programs SET allowed='0', banreason='Failed Virus Scan' WHERE programid='$programid';"

  mysqlOut=$({
    $echo "$password"
  } | $mysql --silent -u $username -D $database -e "$query" -p 2>/dev/null)

  # create table VirusScans (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, programid TEXT NOT NULL, failed INT)
  query="insert into VirusScans (programid, failed) VALUES ('$programid', 1);"

  mysqlOut=$({
    $echo "$password"
  } | $mysql --silent -u $username -D $database -e "$query" -p 2>/dev/null)
else
  $echo "Passed Virus Scan!!!"

  # create table VirusScans (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, programid TEXT NOT NULL, failed INT)
  query="insert into VirusScans (programid, failed) VALUES ('$programid', 0);"

  mysqlOut=$({
    $echo "$password"
  } | $mysql --silent -u $username -D $database -e "$query" -p 2>/dev/null)

  $echo "MySQL: $mysqlOut"
  $echo "PW: $password"
fi