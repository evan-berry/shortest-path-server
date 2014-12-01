#!/bin/bash
time for i in `ls -1 map*.bin`
 do
     echo $(cat $i | netcat 127.0.0.1 7777) \
     >> /tmp/shortest-path-output.txt
 done
