#!/bin/bash
dev=$1

ZabbixSender="/usr/bin/zabbix_sender -c /usr/local/etc/zabbix_agentd.conf"
DF="/bin/df -B G"
GREP="/bin/grep"
AWK="/usr/bin/awk"
SED="/bin/sed"
CAT="/bin/cat"
ECHO="/bin/echo"
BC="/usr/bin/bc"

## size free %
all=`$DF | $GREP $dev`
free_percent=`$ECHO $all | $AWK  {'print "100-",$5'}| $SED 's/%//g'| $BC`
aviable_size=`$ECHO $all | $AWK  {'print $4'}| $SED 's/G//g'`
total=`$ECHO $all | $AWK  {'print $2'}| $SED 's/G//g'`
$ZabbixSender -k hdd.state_${dev}_aviable_size -o $aviable_size > /dev/null
$ZabbixSender -k hdd.state_${dev}_total -o $total > /dev/null
$ZabbixSender -k hdd.state_${dev}_free_percent -o $free_percent > /dev/null
file="/var/tmp/iostat_zabbix_${dev}"

dev_nodigits=`$ECHO $dev | $SED 's/[0-9]*//g'`

iostat -xk  1 11  | grep $dev_nodigits | tail -n10 > $file

readcnt=` cat $file | awk {'print $4'}  | paste -sd+ | bc | awk {'print $1,"/10" '}|bc`
writecnt=`cat $file | awk {'print $5'}  | paste -sd+ | bc | awk {'print $1,"/10" '}|bc`
readkb=`  cat $file | awk {'print $6'}  | paste -sd+ | bc | awk {'print $1,"/10" '}|bc`
writekb=` cat $file | awk {'print $7'}  | paste -sd+ | bc | awk {'print $1,"/10" '}|bc`
await=`   cat $file | awk {'print $10'} | paste -sd+ | bc | awk {'print $1,"/10" '}|bc`

$ZabbixSender -k hdd_readcnt_${dev_nodigits}  -o $readcnt  > /dev/null
$ZabbixSender -k hdd_writecnt_${dev_nodigits} -o $writecnt > /dev/null 
$ZabbixSender -k hdd_readkb_${dev_nodigits}   -o $readkb   > /dev/null
$ZabbixSender -k hdd_writekb_${dev_nodigits}  -o $writekb  > /dev/null
$ZabbixSender -k hdd_await_${dev_nodigits}    -o $await    > /dev/null
