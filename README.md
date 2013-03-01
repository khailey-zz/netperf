Tests below tests


* 8K send  (what is typical latency for an oracle block transfer)
* 128K send  (throughout test)
* 1M send (throughout test)
* 8K receive  (what is typical latency for an oracle block transfer)
* 128K receive  (throughout test)
* 1M receive  (throughout test)

output


           mss:  1448
       local_recv_size (beg,end):      128000     128000
       local_send_size (beg,end):       49152      49152
      remote_recv_size (beg,end):       87380    3920256
      remote_send_size (beg,end):       16384      16384

    mn_ms av_ms max_ms s_KB r_KB r_MB/s s_MB/s <100u <500u  <1ms  <5ms <10ms <50ms <100m <1s >1s p90  p99
      .08   .12  10.91                          15.69 83.92   .33  .38   .01   .01              .12  .54
      .10   .16  12.25    8       48.78               99.10   .30   .82   .07   .08              .15  .57
      .10   .14   5.01         8         54.78        99.04   .88  .96                          .15  .60
      .22   .34  63.71  128      367.11               97.50  1.57  2.42   .06   .07   .01        .35  .93
      .43   .60  16.48       128        207.71        84.86 11.75 15.04   .05   .10              .90 1.42
      .99  1.30 412.42 1024      767.03                       .05 99.90   .03   .08       .03   1.30 2.25
     1.77  2.28  15.43      1024        439.20                    99.27   .64   .73             2.65 5.35

columns

* mn_ms - minimum latency ms
* av_ms - average latency ms
* max_ms - maximum latency ms
* s_KB - send KB per operation
* r_KB - receive KB per operation
* r_MB/s - MB/s received
* s_MB/s  - MB/s sent
* p90 - 90 percentile latency
* p99 - 99 percentile latency
* <100u , ... ,  >1s - latency buckets, ie histogram of latency

