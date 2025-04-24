#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'  
rm -rf transcript 

if ./compile.sh
then
    echo "Success"
else
    echo "Failure"
    exit 1
fi

printf "${RED}\nSimulating${NC}\n"
if [[ "$@" =~ --gui ]]
then
    echo vsim -coverage -assertdebug -voptargs="+acc" test_hdlc bind_hdlc -do "log -r *; coverage report -file coverage_report.txt -details" &
    exit
else
    if vsim -coverage -assertdebug -c -voptargs="+acc" test_hdlc bind_hdlc -do "log -r *; run -all; coverage report -file coverage_report.txt -details; exit" 
    then
        echo "Success"
    else
        echo "Failure"
        exit 1
    fi
fi