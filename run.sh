#!/bin/sh

PATHLOCAL=$PWD

#Execute Jsoup - version 1b Defects4J
bash ./sfl.sh projects/Jsoup1b "$REPEAT"
cd "$PATHLOCAL" || exit

#Execute Time - version 1b Defects4J
bash ./sfl.sh projects/Time1b "$REPEAT"
cd "$PATHLOCAL" || exit

#Execute Gson - version 1b Defects4J
bash ./sfl.sh projects/Gson1b/gson "$REPEAT"
cd "$PATHLOCAL" || exit

#Execute Lang - version 1b Defects4J
bash ./sfl.sh projects/Lang1b "$REPEAT"
cd "$PATHLOCAL" || exit

#Execute Csv - version 1b Defects4J
bash ./sfl.sh projects/Csv1b "$REPEAT"
cd "$PATHLOCAL" || exit

#Execute Collections - version 25b Defects4J
bash ./sfl.sh projects/Collections25b "$REPEAT"
cd "$PATHLOCAL" || exit
