#!/bin/sh
nanoToMili=1000000
work_dir="$1"
PID="$2"
BID="$3"
COUNT="$4"
D4J_HOME="$5"
PREFIX="$work_dir/test/${PID}_${BID}b"
projD4J="$work_dir/projects/${PID}${BID}"
RESULT="$work_dir/test/execution.csv"

echo "Start GZoltar(CLI) - ${PID}${BID}b - ${COUNT}"

#define MAVEN_OPTS to memory start and limit
export _JAVA_OPTIONS="-Xmx6144M -XX:MaxHeapSize=4096M"
export MAVEN_OPTS="-Xmx1024M"

#
# Configure GZoltar
#

export GZOLTAR_AGENT_JAR="/gzoltar/com.gzoltar.agent.rt/target/com.gzoltar.agent.rt-1.7.4-SNAPSHOT-all.jar"
export GZOLTAR_CLI_JAR="/gzoltar/com.gzoltar.cli/target/com.gzoltar.cli-1.7.4-SNAPSHOT-jar-with-dependencies.jar"


cd "$projD4J" || exit

mvn clean
start=$(date +%s%N)
mvn process-test-classes

end=$(date +%s%N)
TIMECOMPILE=$(((end - start) / nanoToMili))

# Collect metadata
test_classpath=$($D4J_HOME/framework/bin/defects4j export -p cp.test)
src_classes_dir=$($D4J_HOME/framework/bin/defects4j export -p dir.bin.classes)
src_classes_dir="$projD4J/$src_classes_dir"
test_classes_dir=$($D4J_HOME/framework/bin/defects4j export -p dir.bin.tests)
test_classes_dir="$projD4J/$test_classes_dir"
echo "$PID-${BID}b's classpath: $test_classpath"
echo "$PID-${BID}b's bin dir: $src_classes_dir"
echo "$PID-${BID}b's test bin dir: $test_classes_dir"

# Collect unit tests to run GZoltar with
#
"$D4J_HOME/framework/bin/defects4j" compile
# cd "$projD4J" || exit
unit_tests_file="$projD4J/unit_tests.txt"
relevant_tests="*"  # Note, you might want to consider the set of relevant tests provided by D4J, i.e., $D4J_HOME/framework/projects/$PID/relevant_tests/$BID

start=$(date +%s%N)
java -cp "$test_classpath:$test_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$GZOLTAR_CLI_JAR" \
  com.gzoltar.cli.Main listTestMethods \
    "$test_classes_dir" \
    --outputFile "$unit_tests_file" \
    --includes "$relevant_tests"
head "$unit_tests_file"

#
# Collect classes to perform fault localization on
# Note: the `sed` commands below might not work on BSD-based distributions such as MacOS.
#

# cd "$projD4J" || exit

loaded_classes_file="$D4J_HOME/framework/projects/$PID/loaded_classes/$BID.src"
normal_classes=$(cat "$loaded_classes_file" | sed 's/$/:/' | sed ':a;N;$!ba;s/\n//g')
inner_classes=$(cat "$loaded_classes_file" | sed 's/$/$*:/' | sed ':a;N;$!ba;s/\n//g')
classes_to_debug="$normal_classes$inner_classes"
echo "Likely faulty classes: $classes_to_debug"

#
# Run GZoltar
#

# cd "$projD4J" || exit

ser_file="$projD4J/gzoltar.ser"
java -XX:MaxPermSize=4096M -javaagent:$GZOLTAR_AGENT_JAR=destfile=$ser_file,buildlocation=$src_classes_dir,includes=$classes_to_debug,excludes="",inclnolocationclasses=false,output="FILE" \
  -cp "$src_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR" \
  com.gzoltar.cli.Main runTestMethods \
    --testMethods "$unit_tests_file" \
    --collectCoverage

#
# Generate fault localization report
#

# cd "$projD4J" || exit

java -cp "$src_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR" \
    com.gzoltar.cli.Main faultLocalizationReport \
      --buildLocation "$src_classes_dir" \
      --granularity "line" \
      --inclPublicMethods \
      --inclStaticConstructors \
      --inclDeprecatedMethods \
      --dataFile "$ser_file" \
      --outputDirectory "$projD4J/target/" \
      --family "sfl" \
      --formula "ochiai" \
      --metric "entropy" \
      --formatter "txt"
end=$(date +%s%N)
TIMECLI=$(((end - start) / nanoToMili))
fileGenerated="false"

nameFileGenerated="$projD4J/target/sfl/txt/ochiai.ranking.csv" 

if [ -f "$nameFileGenerated" ]; then
    myfilesize=$(stat --format=%s "$nameFileGenerated")
    size=$(wc -l "$nameFileGenerated")
    if [ "${myfilesize}" != "0" ]; then
        if [ "${size}" != "1 $nameFileGenerated" ]; then
            fileGenerated="true"
        fi
    fi
fi


if [ ! -f "$RESULT" ]; then
    echo "application;project;bug id;count;compile;execution;sum;fileGenerated" >> "$RESULT"
fi
echo "GZoltarCLI;$PID;$BID;$COUNT;$TIMECOMPILE;$TIMECLI;$((TIMECOMPILE + TIMECLI));$fileGenerated" >> "$RESULT"

cp "$projD4J/target/sfl/txt/ochiai.ranking.csv" "$PREFIX-$COUNT-cli-gzoltar.ochiai.ranking.csv"

echo "Final GZoltar(CLI) - ${PID}${BID}b - ${COUNT}"