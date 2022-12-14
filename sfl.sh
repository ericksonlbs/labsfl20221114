#!/bin/sh

execute() {
    i=0
    guid=$(uuidgen)
    proj=$3
    #define MAVEN_OPTS to memory start and limit
    export MAVEN_OPTS="-Xms7168m -Xmx7168m"
    
    resultPath="$PWD/test"

    if [ -n "${1}" ]; then
        path=$1
    else
        path=$HOME
    fi  

    if [ -n "${2}" ]; then
        repeat=$2
    else
        repeat=1
    fi 
    
    LOGFILE=$4

    if [ ! -d "$resultPath" ]; then
        mkdir "$resultPath"
    fi
    
    pathProj="$PWD/$path"

    prefix="$resultPath/$proj-$guid"
    
    while [ $i -lt "$repeat" ]; do

        cd "$pathProj" || exit
        i=$((i + 1))

        startmain=$(date +%s%N)
        nanoToMili=1000000

        #clean
        mvn clean

        #flacoco pre vuild
        start=$(date +%s%N)
        mvn verify
        end=$(date +%s%N)

        build=$(((end - start) / nanoToMili))
                
        echo "init flacoco sfl - path: $path - $i of $repeat"
        #flacoco sfl
        start=$(date +%s%N)
        java -Xms7168m -Xmx7168m -jar ~/.m2/repository/com/github/spoonlabs/flacoco/1.0.6-SNAPSHOT/flacoco-1.0.6-SNAPSHOT-jar-with-dependencies.jar \
            --projectpath . \
            -o target/flacoco.csv  
            
        end=$(date +%s%N)
        flacoco=$(((end - start) / nanoToMili))
        sort --field-separator=',' --key=3 -r "target/flacoco.csv" > "$prefix-$i-flacoco.csv"

        echo "init jaguar sfl - path: $path - $i of $repeat"
        #jaguar sfl
        start=$(date +%s%N)
        PROJECT_DIR="$PWD"
        JAGUAR_JAR="$HOME/.m2/repository/br/usp/each/saeg/jaguar/br.usp.each.saeg.jaguar.core/1.0.0/br.usp.each.saeg.jaguar.core-1.0.0-jar-with-dependencies.jar"
        JACOCO_JAR="$HOME/.m2/repository/org/jacoco/org.jacoco.agent/0.8.7/org.jacoco.agent-0.8.7-runtime.jar"
        LOG_LEVEL="ERROR" # ERROR / INFO / DEBUG / TRACE

        java -Xms7168m -Xmx7168m -javaagent:"$JACOCO_JAR"=output=tcpserver -cp "$PROJECT_DIR"/target/classes/:"$PROJECT_DIR"/target/test-classes/:"$JAGUAR_JAR":"$JACOCO_JAR" \
            "br.usp.each.saeg.jaguar.core.cli.JaguarRunner" \
            --outputType F \
            --output "control-flow" \
            --logLevel "$LOG_LEVEL" \
            --projectDir "$PROJECT_DIR" \
            --classesDir "$PROJECT_DIR/target/classes/" \
            --testsDir "$PROJECT_DIR/target/test-classes/" \
            --testsListFile "$PROJECT_DIR/testListFile.txt" \
            --heuristic "Ochiai" 
            
        end=$(date +%s%N)
        jaguar=$(((end - start) / nanoToMili))
        cp ".jaguar/control-flow.xml" "$prefix-$i-jaguar-control-flow.xml"

        mvn clean


        echo "init jaguar2 - path: $path - $i of $repeat"
        #jaguar2
        start=$(date +%s%N)
        mvn -f pom-jaguar.xml verify
        end=$(date +%s%N)
        jaguar2=$(((end - start) / nanoToMili))
        cp "target/jaguar2.csv" "$prefix-$i-jaguar2.csv"

        mvn clean
        
        echo "init gzoltar - path: $path - $i of $repeat"
        #gzoltar
        start=$(date +%s%N)
        mvn -f pom-gzoltar.xml verify
        end=$(date +%s%N)
        gzoltarVerify=$(((end - start) / nanoToMili))
        start=$(date +%s%N)
        mvn -f pom-gzoltar.xml gzoltar:fl-report
        end=$(date +%s%N)
        gzoltarReport=$(((end - start) / nanoToMili))
        cp "target/site/gzoltar/sfl/txt/ochiai.ranking.csv" "$prefix-$i-gzoltar.ochiai.ranking.csv"
        cp "target/gzoltar.ser" "$prefix-$i-gzoltar.ser"
                      
        end=$(date +%s%N)
        runtime=$(((end - startmain) / nanoToMili))
        buildJaguar=$((build + jaguar))
        buildFlacoco=$((build + flacoco))
        gzoltar=$((gzoltarVerify + gzoltarReport))

        mvn clean

        case "${proj}" in
        'JacksonDatabind80b')
            PID="JacksonDatabind"
            BID="80"
        ;;
        'Math104b')
            PID="Math"
            BID="104"
        ;;
        'JacksonXML2b')
            PID="JacksonXml"
            BID="2"
        ;;
        'Compress47b')
            PID="Compress"
            BID="47"
        ;;
        'Codec18b')
            PID="Codec"
            BID="18"
        ;;
        'Csv1b')
            PID="Csv"
            BID="1"
        ;;
        'Jsoup93b')
            PID="Jsoup"
            BID="93"
        ;;
        'Time1b')
            PID="Time"
            BID="1"
        ;;
        'Gson18b')
            PID="Gson"
            BID="18"
        ;;
        'Lang1b')
            PID="Lang"
            BID="1"
        ;;
        'Collections25b')
            PID="Collections"
            BID="25"
        ;;
        esac
        
        projD4J="/labsfl20221114/projects/$PID-${BID}b"
        if [ -d "$projD4J" ]; then
            rm -rf "$projD4J"
        fi
      
        echo "defects4j checkout $projD4J"
        "/defects4j/framework/bin/defects4j" checkout -p "$PID" -v "${BID}b" -w "$projD4J" >> "$LOGFILE"
        start=$(date +%s%N)
        cd "$projD4J" || exit
        "/defects4j/framework/bin/defects4j" compile
        end=$(date +%s%N)
        compileD4J=$(((end - start) / nanoToMili))

        #gzoltarcli
        echo "init gzoltarcli - path: $projD4J - $i of $repeat"
        start=$(date +%s%N)
        bash /labsfl20221114/gzoltar.sh "/labsfl20221114/projects" $PID $BID >> "$LOGFILE"                
        end=$(date +%s%N)
        gzoltarcli=$(((end - start) / nanoToMili))
        cp "$projD4J/target/sfl/txt/ochiai.ranking.csv" "$prefix-$i-cli-gzoltar.ochiai.ranking.csv"
     
        compileGzoltarCLI=$((compileD4J + gzoltarcli))
        file="$prefix-execution.csv"
        if [ ! -f "$file" ]; then
            echo "application;execution;number;build;compileD4J;flacoco;jaguar;gzoltarVerify;gzoltarReport;gzoltarcli;build+flacoco;build+jaguar;build with jaguar2;gzoltar;compile+gzoltarcli;total time" >> "$file"
        fi

        echo "${proj##*/};$guid;$i of $repeat;$build;$compileD4J;$flacoco;$jaguar;$gzoltarVerify;$gzoltarReport;$gzoltarcli;$buildFlacoco;$buildJaguar;$jaguar2;$gzoltar;$compileGzoltarCLI;$runtime" >> "$file"
    done
}

execute "$@"
