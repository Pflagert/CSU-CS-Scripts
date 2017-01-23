#!/bin/bash

COMMAND=$1
ASSIGNMENT=$2
FILENAME=$3

# your username
USERNAME="pflagert"
# the server you want to connect to
REMOTESERVER="lincoln.cs.colostate.edu"
# the directory where files will be sent.
# this will on be used when using the checkin command
REMOTEDIRECTORY="~/CS/cs455/.checkin"
# the class you are using this script for
CLASS="cs455"

# This is used to see if the script is running on the CS machines.  If it is then we won't need to use ssh
IS_LOCAL=0
DNSNAME=`dnsdomainname`
if [[ "$DNSNAME" == "cs.colostate.edu" ]]
    then
    IS_LOCAL=1
fi

# prints usage and exits
usage() {
    echo -ne "Usage: $0 <COMMAND> <ASSIGNMENT> <FILENAME>\n\n"
    echo -ne "COMMAND:\n"
    echo -ne "\n\tcheckin:\n\t\tSUBMITS <FILENAME> FOR <ASSIGNMENT>\n\t\tEXAMPLE:\n\t\t\t$0 checkin HW1 John-Smith-HW1.tar\n"
    echo -ne "\n\tpeek:\n\t\tTHIS COMMAND WILL SHOW EVERY SUBMITION FOR <ASSIGNMENT>\n\t\tEXAMPLE:\n\t\t\t$0 peek HW1\n"
    echo -ne "\n\tgrade:\n\t\tTHIS COMMAND WILL SHOW THE GRADE FOR <ASSIGNMENT>\n"
    echo -ne "\t\tEXAMPLES:\n\t\t\t$0 grade HW1 (this will show the grade for HW1)\n"
    echo -ne "\t\t\t$0 grade (this will show the grades for all assignments)\n"
    echo -ne "\nASSIGNMENT:\n\tTHE NAME OF THE ASSIGNMENT\n\tTHIS IS ONLY NEEDED WITH THE checkin / peek COMMANDS\n"
    echo -ne "\nFILENAME:\n\tTHE NAME OF THE FILENAME THAT YOU WOULD LIKE TO SUBMIT\n\tTHIS IS ONLY NEEDED WITH THE checkin COMMAND\n"
    exit 0
}

# produces error messages
error() {
    echo "Error"
    #unkown command error
    [[ $1 -eq 0 ]] && echo "Unknown COMMAND: $COMMAND"
    #incorrect number of arguments for peek
    [[ $1 -eq 1 ]] && echo -e "Incorrect number of arguments for COMMAND: $COMMAND\n\tExpected argument for <ASSIGNMENT>"
    #incorrect number of arguments for checkin
    [[ $1 -eq 2 ]] && echo -e "Incorrect number of arguments for COMMAND: $COMMAND\n\tExpected arguments for <ASSIGNMENT> <FILENAME>"
    # no command was given
    [[ $1 -eq 3 ]] && echo -e "No Arguments given"
    echo -e "\n"
    usage
}

# runs commands via ssh
runRemote() {
    # copy file to remote and run the checkin program via ssh
    if [[ "$COMMAND" == "checkin" ]] 
        then
        REMOTEFILE="$REMOTEDIRECTORY/`basename $FILENAME`"
        ssh $USERNAME@$REMOTESERVER "cat - > $REMOTEFILE; ~$CLASS/bin/checkin $ASSIGNMENT $REMOTEFILE" < $FILENAME 

    # ssh and run the peek program
    elif [[ "$COMMAND" == "peek" ]] 
        then
        ssh $USERNAME@$REMOTESERVER "~$CLASS/bin/peek $ASSIGNMENT"

    # ssh and run the grade program
    elif [[ "$COMMAND" == "grade" ]]
        then
        ssh $USERNAME@$REMOTESERVER "~$CLASS/bin/grade $ASSIGNMENT"
    fi
}

# runs commands locally
runLocal() {
    # copy file to remote and run the checkin program via ssh
    if [[ "$COMMAND" == "checkin" ]] 
        then
        exec ~$CLASS/bin/checkin $ASSIGNMENT $FILENAME 

    # ssh and run the peek program
    elif [[ "$COMMAND" == "peek" ]] 
        then
        exec ~$CLASS/bin/peek $ASSIGNMENT

    # ssh and run the grade program
    elif [[ "$COMMAND" == "grade" ]]
        then
        exec ~$CLASS/bin/grade $ASSIGNMENT
    fi
}

# start error checking
# check if at least one argument was passed
if [[ $# -lt 1 ]]
    then
    error 3

# check if there is a valid command
elif [ "$COMMAND" != "checkin" ]  && [ "$COMMAND" != "peek" ]  && [ "$COMMAND" != "grade"  ]
then
    error 0
    
# check if it is the peek command and if we have at least 2 arguments
elif [ "$COMMAND" == "peek" ]  &&  [ $# -lt 2 ]
then
    error 1

# check if it is the checkin command, if so we need 3 arguments
elif [ "$COMMAND" == "checkin" ]  && [ $# -lt 3 ] 
    then
    error 2
fi
# end error checking 

# run commands locally or remotely depending on if the machine is a CSU CS machine
if [[ $IS_LOCAL == 1 ]]
    then
    runLocal
else
    runRemote
fi


