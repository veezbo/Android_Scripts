#!/bin/bash


#USAGE Statement
usage()
{
	echo "
Runs the Emulator for testing KNOX and Persona development
No Required Parameters
Run like:
bash emulator.sh <optional-arguments>

Optional Parameters: 
	-w wipe all user data before starting the emulator (not usually suggested)
	-v set the emulator to run in verbose mode
	-h display this usage message
	-u <num_Users> sets the android propery for multiple users
	"
}


#Check that we are in the correct directory
current_dir=${PWD##*/}

if [[ ! $current_dir =~ ^AOSP ]]; then
	echo ""
	echo "***************ERROR: Please Enter the appropriate directory: (must be in AOSP)***************"
	exit 1
fi


#Read in Optional Arguments
wipe="false"
verbose="false"
users="false"
numUsers=1
while getopts ":wvhu:" opt; do
	case $opt in
		w)
			wipe="true"
			;;
		v)
			verbose="true"
			;;
		h)
			usage
			exit 1
			;;
		u)
			users="true"
			numUsers=$OPTARG
			;;
		\?)
			echo "Invalid Argument: -$OPTARG" >&2
			usage
			exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))


#Define Optional Parameter Strings
readonly WIPE_STRING=" -wipe-data"
readonly VERBOSE_STRING=" -verbose"
readonly USERS_STRING=" -prop fw.max_users=$numUsers"


#Append to the Original Call any necessary command line arguments
call="emulator -skin WSVGA -scale 0.8 -memory 1024 -partition-size 1024"
if [ $wipe = "true" ]; then
	call+=$WIPE_STRING
fi

if [ $verbose = "true" ]; then
	call+=$VERBOSE_STRING
fi

if [ $users = "true" ]; then
	call+=$USERS_STRING
fi


#Make the call
$call