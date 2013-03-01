#!/bin/bash 


usage()
{
cat << EOF
usage: $0 options  [output files]
 
parse netperf.sh output files, output parsed results

OPTIONS:
   -h              Show this message
   -v              verbose, include histograms in output
EOF
}

# bit of a hack
# shell script takes command line args
# these args are then passed into perl at command line args
# the perl looks at each commandline arge and sets a 
# variable with that name = 1
#
AGRUMENTS=""
VERBOSE=0
while getopts .dC:J:chpR:vr. OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         v)
             ARGUMENTS="$ARGUMENTS verbose"
             VERBOSE=1
             ;;
         ?)
             usage
             exit
             ;;
     esac
done
shift $((OPTIND-1))

for i in $*; do
  echo "filename=$i"
  cat $i 
  echo "FILE_END"
done | \
perl -e '

  $SEP="";
  use POSIX;

  $first=1;

  $ouputrows=0;
  $DEBUG=0;
  $CLAT=0;

     if  ( 1 == $DEBUG ) { $debug=1; }

     foreach $argnum (0 .. $#ARGV) {
        ${$ARGV[$argnum]}=1;
       #print "$ARGV[$argnum]=${$ARGV[$argnum]}\n";
     }
     print "continuting ... \n" if defined ($debug);

     $| = 1;
     printf("before input\n") if defined ($debug);
     while (my $line = <STDIN>) {
        printf("after input\n") if defined ($debug);
        chomp($line);
        printf("line: %s\n", $line) if defined ($debug);
        if ( $line =~ m/filename/ ) {
             $dir=$line;
             $dir =~ s/filename=//;
             $dir =~ s/\/.*//;
             #print "dir=$dir;\n"
        }
        if ( $line =~ m/RETRANS/ ) { ($name,$retrans_beg,$retrans_end)      = split(":", $line); }
        if ( $line =~ m/LSS_SIZE_END=/ ) { ($name,$local_send_size_end)   = split("=", $line); }
        if ( $line =~ m/LSR_SIZE_END=/ ) { ($name,$local_recv_size_end)   = split("=", $line); }
        if ( $line =~ m/RSR_SIZE_END=/ ) { ($name,$remote_recv_size_end)   = split("=", $line); }
        if ( $line =~ m/RSS_SIZE_END=/ ) { ($name,$remote_send_size_end)   = split("=", $line); }
        if ( $line =~ m/LSS_SIZE=/ ) { ($name,$local_send_size)   = split("=", $line); }
        if ( $line =~ m/LSR_SIZE=/ ) { ($name,$local_recv_size)   = split("=", $line); }
        if ( $line =~ m/RSR_SIZE=/ ) { ($name,$remote_recv_size)   = split("=", $line); }
        if ( $line =~ m/RSS_SIZE=/ ) { ($name,$remote_send_size)   = split("=", $line); }
	if ( $line =~ m/TRANSPORT_MSS=/ ) { ($name,$mss)= split("=", $line); } 

        if ( $line =~ m/REQUEST_SIZE=/ ) { ($name,$send_size)   = split("=", $line); }
        if ( $line =~ m/RESPONSE_SIZE=/) { ($name,$recv_size)   = split("=", $line); }
        if ( $line =~ m/ELAPSED_TIME=/) { ($name,$elapsed)   = split("=", $line); }
        if ( $line =~ m/THROUGHPUT=/   ) { ($name,$ops)   = split("=", $line); 
                    #printf("throughout %s\n", $ops) ; 
        }
        if ( $line =~ m/UNIT_USEC/ ) { ($name,$s[0],$s[1],$s[2],$s[3],$s[4],$s[5],$s[6],$s[7],$s[8],$s[9],) = split(":", $line); }
        if ( $line =~ m/TEN_USEC/ ) { ($name,$s[10],$s[11],$s[12],$s[13],$s[14],$s[15],$s[16],$s[17],$s[18],$s[19],) = split(":", $line);}
        if ( $line =~ m/HUNDRED_USEC/ ) { ($name,$s[20],$s[21],$s[22],$s[23],$s[24],$s[25],$s[26],$s[27],$s[28],$s[29],) = split(":", $line); }
        if ( $line =~ m/UNIT_MSEC/ ) { ($name,$s[30],$s[31],$s[32],$s[33],$s[34],$s[35],$s[36],$s[37],$s[38],$s[39],) = split(":", $line);} 
        if ( $line =~ m/TEN_MSEC/ ) { ($name,$s[40],$s[41],$s[42],$s[43],$s[44],$s[45],$s[46],$s[47],$s[48],$s[49],) = split(":", $line);} 
        if ( $line =~ m/HUNDRED_MSEC/ ) { ($name,$s[50],$s[51],$s[52],$s[53],$s[54],$s[55],$s[56],$s[57],$s[58],$s[59],) = split(":", $line);} 
        if ( $line =~ m/UNIT_SEC/ ) { ($name,$s[60],$s[61],$s[62],$s[63],$s[64],$s[65],$s[66],$s[67],$s[68],$s[69],) = split(":", $line);} 
        if ( $line =~ m/TEN_SEC/ ) { ($name,$s[70],$s[71],$s[72],$s[73],$s[74],$s[75],$s[76],$s[77],$s[78],$s[79],) = split(":", $line);} 
        if ( $line =~ m/100_SECS/ ) { ($name,$s[80])= split(":", $line); } 
        if ( $line =~ m/P99_LATENCY/ ) { ($name,$p99)= split("=", $line); } 
        if ( $line =~ m/P90_LATENCY/ ) { ($name,$p90)= split("=", $line); } 
        if ( $line =~ m/P50_LATENCY/ ) { ($name,$p50)= split("=", $line); } 
        if ( $line =~ m/MAX_LATENCY/ ) { ($name,$maxl)= split("=", $line); } 
	if ( $line =~ m/MIN_LATENCY/ ) { ($name,$minl)= split("=", $line); } 

 # ====================================================================
 #
 #   PRINTING OUT
 #

    if ( $line =~ m/FILE_END/ ) {

      if ( $first==1 ) {
        printf("         ");
        printf("%5s ", "mn_ms"); printf("%s",$SEP);
        printf("%6s ", "avg_ms"); printf("%s",$SEP);
        printf("%6s ", "max_ms"); printf("%s",$SEP);
        printf("%4s ", "s_KB"); printf("%s",$SEP);
        printf("%4s ", "r_KB"); printf("%s",$SEP);
        printf("%8s ", "s_MB/s" ); printf("%s",$SEP);
        printf("%8s ", "r_MB/s" ); printf("%s",$SEP);
        printf("%5s ", "<100u"); printf("%s",$SEP);
        printf("%5s ", "<500u"); printf("%s",$SEP);
        printf("%5s ", "<1ms"); printf("%s",$SEP);
        printf("%5s ", "<5ms"); printf("%s",$SEP);
        printf("%5s ", "<10ms"); printf("%s",$SEP);
        printf("%5s ", "<50ms"); printf("%s",$SEP);
        printf("%5s ", "<100m"); printf("%s",$SEP);
        printf("%5s ", "<1s"); printf("%s",$SEP);
        printf("%5s ", ">1s"); printf("%s",$SEP);
        printf("%5s ", "p90"); printf("%s",$SEP);
        printf("%5s ", "p99"); printf("%s",$SEP);
        printf("\n");

        $first=0;
        printf(" %40s:  %10s %10s\n", "local_send_size (beg,end)", $local_send_size,$local_send_size_end);
        printf(" %40s:  %10s %10s\n", "local_recv_size (beg,end)", $local_recv_size , $local_recv_size_end );
        printf(" %40s:  %10s %10s\n", "remote_recv_size (beg,end)", $remote_recv_size, $remote_recv_size_end);
        printf(" %40s:  %10s %10s\n", "remote_send_size (beg,end)", $remote_send_size, $remote_send_size_end);
        printf(" %30s:  %s \n", "mss", $mss);
        printf(" \n");
      }

      $total_sum=0; for ( $i=0; $i < 81 ; $i++ ) { $total_sum=$total_sum+$s[$i]; }    

      # if total_sum=0 it means all the values are zero
      # which means a problem - should probably flag but for
      # now just avoiding divide by zero 
      if ( $total_sum < 1 ) { $total_sum=1; }

      $sMBsec=($send_size*$ops)/(1024*1024);
      $rMBsec=($recv_size*$ops)/(1024*1024); 

      $sz=1;
      if ( $send_size == 1 ) { $sMBsec=0; $sz=$recv_size+1; }
      if ( $recv_size == 1 ) { $rMBsec=0; $sz=$send_size; }

      printf("%8s ",    $sz);  printf("%s",$SEP);
      printf("%5.2f ",  $minl/1000 );  printf("%s",$SEP);
      printf("%6.2f ",  1000/$ops) ;   printf("%s",$SEP);# average
      printf("%6.2f ",  $maxl/1000 );  printf("%s",$SEP);
      printf("%4d ",    $send_size/1024); printf("%s",$SEP);
      printf("%4d ",    $recv_size/1024); printf("%s",$SEP);
      printf("%8.3f  ", $sMBsec); printf("%s",$SEP);
      printf("%8.3f  ", $rMBsec); printf("%s",$SEP);

        # sum us and ten-us
        $sum=0;
        for ( $j=0; $j < 20 ; $j++ ) { $sum=$sum+$s[$j]; }
        printf("%5.2f ", 100*($sum/$total_sum) );  printf("%s",$SEP);
        
        # for c-us, ms, t-ms zoom in 
        $sum=0;
        for ( $i=20; $i < 41 ; $i=$i+10 ) {
           for ( $j=0; $j < 6 ; $j++ ) { $sum=$sum+$s[$i+$j]; }
           printf("%5.2f ", 100*($sum/$total_sum) );  printf("%s",$SEP);
           $sum=0;
           for ( $j=6; $j < 11 ; $j++ ) { $sum=$sum+$s[$i+$j]; }
           printf("%5.2f ", 100*($sum/$total_sum) );  printf("%s",$SEP);
        }

        # cms
        $sum=0;
        for ( $j=50; $j < 61 ; $j++ ) { $sum=$sum+$s[$j]; }
        printf("%5.2f ", 100*($sum/$total_sum) );  printf("%s",$SEP);

        # sum sec,t-sec,csec
        $sum=0;
        for ( $j=60; $j < 81 ; $j++ ) { $sum=$sum+$s[$i+$j]; }
        printf("%5.2f ", 100*($sum/$total_sum) );  printf("%s",$SEP);

        printf("%5.2f ", $p90/1000 );  printf("%s",$SEP);
        printf("%5.2f ", $p99/1000 ); 
        printf("%5d ", $retrans_end - $retrans_beg);

      printf("\n"); 
    } # end of line=END
 } # end of STDIN

   
printf("at end\n") if defined ($debug);

' $ARGUMENTS  | \
 sed -e 's/ 0.00 /      /g' |\
 sed -e 's/ 0 /   /g' |\
 sed -e 's/ 0.000 /       /g' | \
 sed -e 's/^.........//g' | \
 sed -e 's/ 0\./  ./g' | \
 sort -n

