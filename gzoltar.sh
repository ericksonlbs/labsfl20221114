#!/bin/sh

export _JAVA_OPTIONS="-Xms7168m -Xmx7168m -XX:MaxHeapSize=7168M"
export MAVEN_OPTS="-Xms7168m -Xmx7168m"
export ANT_OPTS="-Xms7168m -Xmx7168m -XX:MaxHeapSize=7168M"

#
# Configure GZoltar
#

export GZOLTAR_AGENT_JAR="/gzoltar/com.gzoltar.agent.rt/target/com.gzoltar.agent.rt-1.7.4-SNAPSHOT-all.jar"
export GZOLTAR_CLI_JAR="/gzoltar/com.gzoltar.cli/target/com.gzoltar.cli-1.7.4-SNAPSHOT-jar-with-dependencies.jar"

#
# Configure D4J
#

export D4J_HOME="/defects4j"
export TZ='America/Los_Angeles' # some D4J's requires this specific TimeZone

work_dir="$1"
PID="$2"
BID="$3"

# Compile
cd "$work_dir/$PID-${BID}b" || exit


# Collect metadata
cd "$work_dir/$PID-${BID}b" || exit
test_classpath=$($D4J_HOME/framework/bin/defects4j export -p cp.test)
src_classes_dir=$($D4J_HOME/framework/bin/defects4j export -p dir.bin.classes)
src_classes_dir="$work_dir/$PID-${BID}b/$src_classes_dir"
test_classes_dir=$($D4J_HOME/framework/bin/defects4j export -p dir.bin.tests)
test_classes_dir="$work_dir/$PID-${BID}b/$test_classes_dir"
echo "$PID-${BID}b's classpath: $test_classpath" >&2
echo "$PID-${BID}b's bin dir: $src_classes_dir" >&2
echo "$PID-${BID}b's test bin dir: $test_classes_dir" >&2

#
# Collect unit tests to run GZoltar with
#

cd "$work_dir/$PID-${BID}b" || exit
unit_tests_file="$work_dir/$PID-${BID}b/unit_tests.txt"
relevant_tests="*"  # Note, you might want to consider the set of relevant tests provided by D4J, i.e., $D4J_HOME/framework/projects/$PID/relevant_tests/$BID

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

cd "$work_dir/$PID-${BID}b" || exit

loaded_classes_file="$D4J_HOME/framework/projects/$PID/loaded_classes/$BID.src"
normal_classes=$(cat "$loaded_classes_file" | sed 's/$/:/' | sed ':a;N;$!ba;s/\n//g')
inner_classes=$(cat "$loaded_classes_file" | sed 's/$/$*:/' | sed ':a;N;$!ba;s/\n//g')
classes_to_debug="$normal_classes$inner_classes"
echo "Likely faulty classes: $classes_to_debug" >&2

#
# Run GZoltar
#

cd "$work_dir/$PID-${BID}b" || exit

ser_file="$work_dir/$PID-${BID}b/gzoltar.ser"
java -XX:MaxPermSize=4096M -javaagent:$GZOLTAR_AGENT_JAR=destfile=$ser_file,buildlocation=$src_classes_dir,includes=$classes_to_debug,excludes="",inclnolocationclasses=false,output="FILE" \
  -cp "$src_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR" \
  com.gzoltar.cli.Main runTestMethods \
    --testMethods "$unit_tests_file" \
    --collectCoverage

#
# Generate fault localization report
#

cd "$work_dir/$PID-${BID}b" || exit

java -cp "$src_classes_dir:$D4J_HOME/framework/projects/lib/junit-4.11.jar:$test_classpath:$GZOLTAR_CLI_JAR" \
    com.gzoltar.cli.Main faultLocalizationReport \
      --buildLocation "$src_classes_dir" \
      --granularity "line" \
      --inclPublicMethods \
      --inclStaticConstructors \
      --inclDeprecatedMethods \
      --dataFile "$ser_file" \
      --outputDirectory "$work_dir/$PID-${BID}b/target/" \
      --family "sfl" \
      --formula "ochiai" \
      --metric "entropy" \
      --formatter "txt"