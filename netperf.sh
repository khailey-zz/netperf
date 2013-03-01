#!/bin/bash
#
#
function usage
{
       echo "Usage: $(basename $0) <server> "
       echo "  server        machine running ttcpserver"
       exit 2
}

[[ $# -lt 1 ]] && usage
[[ $# -gt 1 ]] && usage

VDB_HOST=$1


TIME="-l 5"

CUSTOM="-s 64k"
CUSTOM=""

VDB_HOST=172.16.102.209 # perfIBM-target1
VDB_HOST=172.16.102.206 # perf250-target1
VDB_HOST=172.16.102.207 # perfibm-delphix1
VDB_HOST=172.16.102.209 # perfibm-target1
VDB_HOST=172.16.102.201 # perf250-target1

# OPTIONS two values with not spaces separated by a comma
# are send_message_size,receive_message_size 
# script will loop through the list 
OPTIONS="1,1 8K,1  32K,1 128K,1  1024K,1  1,8K  1,32K 1,128K  1,1024K "

OUTPUT="output/"
if [ ! -d $OUTPUT ] ; then
  mkdir $OUTPUT
fi

HOSTNAME=$(hostname)
MACHINE=`uname -a | awk '{print $1}'`
case $MACHINE  in
    AIX)
         # AIX stats
         #  460532 data packets (902304524 bytes) retransmitted
         #   20971 path MTU discovery terminations due to retransmits
         #  125167 retransmit timeouts
         # 1440114 out-of-order packets (168854085 bytes)
            IPCONF=$( /etc/ifconfig -a )
            IP=$(/etc/ifconfig -a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
            NETSTAT="netstat -s -p tcp"
            RETRANS_SEGS="grep retransmitted | awk '{print \$1}'  "
            ;;
    SunOS)
         # open solaris stats
         #        tcpRetransSegs      =  2525     tcpRetransBytes     =3484231
         #        tcpInUnorderSegs    = 49421     tcpInUnorderBytes   =71322692
            IPCONF=$( /sbin/ifconfig -a )
            IP=$(/sbin/ifconfig -a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
            NETSTAT="netstat -s -P tcp"
            RETRANS_SEGS="grep tcpRetransSegs | sed -e 's/=/ /g' | awk '{print \$2}'"
            ;;
    HP-UX)
         # HP stats
         #      10 data packets (820 bytes) retransmitted
         #       6 retransmit timeouts
         #       2 out of order packets (264 bytes)
            IPCONF=$( netstat -in )
            IP=$( netstat -in | grep lan | awk '{print$3}' )
            RETRANS_SEGS="grep retransmitted | awk '{print \$1}'"
            NETSTAT="netstat -s -p tcp"
            ;;
    Linux)
         # LINUX stats
         #    1186 segments retransmited
         #     573 fast retransmits
         #      1         0 forward retransmits
         #     122 retransmits in slow start
         #     396 other TCP timeouts
         #       2 sack retransmits failed
            RETRANS_SEGS="grep retransmited | awk '{print \$1}'"
            IPCONF=$( /sbin/ifconfig -a )
            IP=$(/sbin/ifconfig -a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | sed -e 's/.*addr://' )
            NETSTAT="netstat -s -t"
            ;;
    *)
            IPCONF=$( ifconfig -a )
            IP=$(   ifconfig -a | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')
            NETSTAT="netstat -s -P tcp"
            ;;
esac
echo "Machine $MACHINE "

  for i in 1; do
  cat << EOF
   REMOTE:$VDB_HOST 
   LOCAL NAME:$HOSTNAME 
   LOCAL MACHINE:$MACHINE
   LOCAL IP:$IP
   LOCAL ifconfig:
   $IPCONF"
EOF
done > ${OUTPUT}ttcp_config_${HOSTNAME}.out


for  OPTION in $OPTIONS; do
   opts=$(echo $OPTION | sed -e 's/,/_/g')
   ROOT="${OUTPUT}netperf_${opts}_${hostname}"
   netstatbeg="${ROOT}_netstat_beg.out"
   netstatend="${ROOT}_netstat_end.out"
   output=${ROOT}_output.out
   cmd="./netperf.opensolaris -t TCP_RR -H $VDB_HOST -v 2  $TIME -- $CUSTOM -r $OPTION  -k MIN_LATENCY,P50_LATENCY,P90_LATENCY,P99_LATENCY,MAX_LATENCY,THROUGHPUT,LSS_SIZE_END,LSR_SIZE_END,RSR_SIZE_END,RSS_SIZE_END,REQUEST_SIZE,RESPONSE_SIZE,THROUGHPUT,ELAPSED_TIME,LOCAL_TRANSPORT_RETRANS,REMOTE_TRANSPORT_RETRANS,TRANSPORT_MSS,LSS_SIZE_REQ,LSS_SIZE,LSR_SIZE_REQ,LSR_SIZE,RSS_SIZE_REQ,RSS_SIZE,RSR_SIZE_REQ,RSR_SIZE"
   echo $cmd
   # create outputfile name based on OPTION, which is send and receive message size
   #output="output_${opts}.out"

   eval "$NETSTAT > $netstatbeg"
   echo $cmd  > $output
   eval $cmd  >> $output
   eval "$NETSTAT > $netstatend"

   cat $output


   cmd="cat $netstatbeg | $RETRANS_SEGS "
   BEG_RETRANS=$(eval $cmd)

   cmd="cat $netstatend | $RETRANS_SEGS "
   END_RETRANS=$(eval $cmd)

   echo "RETRANS:${BEG_RETRANS}:${END_RETRANS}" >>  $output

done


