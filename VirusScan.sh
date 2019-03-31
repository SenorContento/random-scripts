#!/bin/bash
maldet=/usr/local/sbin/maldet
dirname=/usr/bin/dirname
mysql=/usr/bin/mysql
cat=/bin/cat
echo=echo #/bin/echo
cd=cd

mysqlAuth=/home/alex/mysql_auth/maldet-password.cnf
database="piet"

uploadDirectory="/var/web/term-uploads/"
niceValue=19

programid="$1"

$cd $($dirname "$0") # Changes to Program Directory

$echo "Scanning For Viruses"
$maldet --scan-all $uploadDirectory"piet_"$programid".png";

# https://stackoverflow.com/a/8230301/6828099
if [ "$?" != "0" ]; then
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