set ns [new Simulator]

set f0 [open out0.tr w]
set f1 [open out1.tr w]
set f2 [open out2.tr w]
set f3 [open out3.tr w]

#Define different colors for data flows (for NAM)
$ns color 1 red
$ns color 2 green
$ns color 3 blue
$ns color 4 yellow
 
#Open the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set r1 [$ns node]
set n4 [$ns node]



$ns duplex-link $n0 $r1 2Mb 10ms DropTail
$ns duplex-link $n1 $r1 2Mb 10ms DropTail
$ns duplex-link $n2 $r1 2Mb 10ms DropTail
$ns duplex-link $n3 $r1 2Mb 10ms DropTail
$ns duplex-link $r1 $n4 0.5Mb 20ms DropTail

#Give node position (for NAM)
$ns duplex-link-op $n0 $r1 orient right-down
$ns duplex-link-op $n1 $r1 orient right-center
$ns duplex-link-op $n2 $r1 orient right-up
$ns duplex-link-op $n3 $r1 orient left-up
$ns duplex-link-op $r1 $n4 orient right-center
 
#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $r1 $n4 queuePos 0.5
#$ns duplex-link-op $n1 $r1 queuePos 0.5

#Define a 'finish' procedure
proc finish {} {
global f0 f1 f2 f3 ns nf
$ns flush-trace
#Close the output files
close $nf
close $f0
close $f1
close $f2
close $f3
#Call xgraph to display the results
exec xgraph out0.tr out1.tr out2.tr out3.tr -geometry 600x400 &
exec nam out.nam &
exit 0


}



set tcp0 [new Agent/TCP]
$tcp0 set class_ 2
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n4 $sink0
$ns connect $tcp0 $sink0
$tcp0 set fid_ 1


set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
$ns attach-agent $n1 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n4 $sink1
$ns connect $tcp1 $sink1
$tcp1 set fid_ 2


set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
$ns attach-agent $n2 $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $n4 $sink2
$ns connect $tcp2 $sink2
$tcp2 set fid_ 3


set tcp3 [new Agent/TCP]
$tcp3 set class_ 2
$ns attach-agent $n3 $tcp3
set sink3 [new Agent/TCPSink]
$ns attach-agent $n4 $sink3
$ns connect $tcp3 $sink3
$tcp3 set fid_ 4



set exp0 [new Application/Traffic/Exponential]
$exp0 attach-agent $tcp0 
$exp0 set packet_size_ 210 
$exp0 set burst_time_ 2ms
$exp0 set idle_time_ 1ms 
$exp0 set rate_ 100k

set exp1 [new Application/Traffic/Exponential]
$exp1 attach-agent $tcp1 
$exp1 set packet_size_ 210 
$exp1 set burst_time_ 2ms
$exp1 set idle_time_ 1ms 
$exp1 set rate_ 100k

set exp2 [new Application/Traffic/Exponential]
$exp2 attach-agent $tcp2 
$exp2 set packet_size_ 210 
$exp2 set burst_time_ 2ms
$exp2 set idle_time_ 1ms 
$exp2 set rate_ 100k

set exp3 [new Application/Traffic/Exponential]
$exp3 attach-agent $tcp3 
$exp3 set packet_size_ 210 
$exp3 set burst_time_ 2ms
$exp3 set idle_time_ 1ms 
$exp3 set rate_ 100k



#set sink00 [new Agent/LossMonitor]
#set sink11 [new Agent/LossMonitor]
#set sink22 [new Agent/LossMonitor]
#$ns attach-agent $n4 $sink00
#$ns attach-agent $n4 $sink11
#$ns attach-agent $n4 $sink22

#$ns attach-agent $exp0 $sink0
#$ns attach-agent $exp1 $sink1
#$ns attach-agent $exp2 $sink2


proc record {} {
global sink0 sink1 sink2 sink3 f0 f1 f2 f3
#Get an instance of the simulator
set ns [Simulator instance]
#Set the time after which the procedure should be called again
set time 0.5
#How many bytes have been received by the traffic sinks?
set bw0 [$sink0 set bytes_]
set bw1 [$sink1 set bytes_]
set bw2 [$sink2 set bytes_]
set bw3 [$sink3 set bytes_]
#Get the current time
set now [$ns now]
#Calculate the bandwidth (in MBit/s) and write it to the files
puts $f0 "$now [expr $bw0/$time*8/1000000]"
puts $f1 "$now [expr $bw1/$time*8/1000000]"
puts $f2 "$now [expr $bw2/$time*8/1000000]"
puts $f3 "$now [expr $bw3/$time*8/1000000]"
#Reset the bytes_ values on the traffic sinks
$sink0 set bytes_ 0
$sink1 set bytes_ 0
$sink2 set bytes_ 0
$sink3 set bytes_ 0
#Re-schedule the procedure
$ns at [expr $now+$time] "record"
}


#Start logging the received bandwidth
$ns at 0.0 "record"
#Start the traffic sources
$ns at 10.0 "$exp0 start"
$ns at 15.0 "$exp1 start"
$ns at 20.0 "$exp2 start"
$ns at 25.0 "$exp3 start"
#Stop the traffic sources
$ns at 40.0 "$exp0 stop"
$ns at 45.0 "$exp1 stop"
$ns at 50.0 "$exp2 stop"
$ns at 55.0 "$exp3 stop"
#Call the finish procedure after 60 seconds simulation time
$ns at 60.0 "finish"
#Run the simulation
$ns run
