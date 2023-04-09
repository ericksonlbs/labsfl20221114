#!/bin/sh

nanoToMili=1000000
work_dir="$1"
PID="$2"
BID="$3"
COUNT="$4"
projD4J="$work_dir/projects/${PID}${BID}"
RESULT="$work_dir/test/execution.csv"

#define MAVEN_OPTS to memory start and limit
export _JAVA_OPTIONS="-Xmx6144M -XX:MaxHeapSize=4096M"
export MAVEN_OPTS="-Xmx6144M"

cd "$projD4J" || exit

echo "Start Verify - ${PID}${BID}b - ${COUNT}"
start=$(date +%s%N)
mvn verify
end=$(date +%s%N)
TIME=$(((end - start) / nanoToMili))

if [ ! -f "$RESULT" ]; then
    echo "application;project;bug id;count;compile;execution;sum;fileGenerated" >>"$RESULT"
fi
echo "Verify;$PID;$BID;$COUNT;$TIME;0;$TIME;true" >>"$RESULT"  

echo "Final Verify - ${PID}${BID}b - ${COUNT}"
