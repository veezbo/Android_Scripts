#!/bin/bash


#Usage Statement
usage()
{
	echo "
USAGE:
Used to Build a Particular AOSP Project
This scipt MUST be sourced, example:
source build.sh -D manta <optional_args>
Furthermore, you must be in the AOSP directory.

Required Arguments:
	-D <device name> Set up Environment/Build for the Given Device
	-e/E Set up Environment/Build for the Emulator (e is regular, E is with KVM acceleration)

Optional Arguments: 
	-b Exclude the Build (i.e. only set up the environment)
	-h Display this usage message
	-u Display this usage message
	-U Supress the UiAutomator Build (built by default)
	-j <# threads> build with number of threads (default 16)

More Examples:
  source build.sh -e [build for regular emulator]
  source build.sh -D maguro -U [build for maguro device, excluding UiAutomator]
  source build.sh -E -b [set up accelerated emulator environment while supressing build]
	"
}


error()
{
	error_message="ERROR "
	error_message+="$1"
	len=${#error_message}
	diff=$(( (80-len) / 2 ))
	if (( diff <= 0 )); then
		echo ""
		echo "$error_message"
		usage
	else
		astString=$(getAstString $diff)
		error_message="${astString}${error_message}${astString}"
		if (( $len%2 == 1 )); then
			error_message+="*"
		fi
		echo ""
		echo "$error_message"
		usage
	fi
}
getAstString()
{
	str=""
	num="$1"
	for (( i=1; i <= num ; i++ ))
	do
		str+="*"
	done
	echo "$str"
}


containsElement () 
{
  for val in "${@:2}"; do [[ "$val" == "$1" ]] && echo "true"; done
  echo "false"
}


call()
{
	echo ""
	echo Calling: $1
	$1
}


finish()
{
	echo ""
	echo FINISHED
	echo ""
}



#Check that this script has been sourced
if (( $SHLVL == 2 )); then
	error "Please Source this bash script"
	exit 1
fi


#Check that we are in the correct directory
current_dir=${PWD##*/}

if [[ ! "$current_dir" =~ ^AOSP ]]; then
	error "Please Enter the appropriate directory: (must be in AOSP)"
	return 1
fi


#Make Sure that we have at least the Required Argument
if (( ! $# >= 1 )); then
	error "Please Enter the Required Argument"
	return 1
fi


OPTIND=1 #Necessary in a Sourced Script

#Read in Arguments
build="true"
build_UiAutomator="true"
build_for=""
device=""
threads=16
while getopts ":bhuUD:eEj:" opt; do
	case $opt in
		b)
			build="false"
			;;
		h)
			usage
			return 1
			;;
		u)
			usage
			return 1
			;;
		U)
			usage
			build_UiAutomator="false"
			;;
		D)
			build_for="device"
			arg=$OPTARG
			devices=("mako" "maguro" "manta" "arndale" "toroplus" "toro" "panda" "tuna")
			valid_arg=$(containsElement $arg ${devices[@]})
			if [ "$valid_arg" = "false" ]; then
				error "Please Enter a Valid Device after the Required Arg '-D'"
				return 1
			fi
			device=$arg
			;;
		e)
			build_for="emulator"
			;;
		E)
			build_for="fast_emulator"
			;;
		j)
			arg=$OPTARG
			if [[ ! "$arg" =~ [0-9]+ ]]; then
				error "ERROR Please Enter a Number after the Optional Arg '-j'"
				return 1
			fi
			threads=$arg
			;;
		:)
			error "Option -$OPTARG requires an argument"
			return 1
			;;
		\?)
			echo "Invalid Argument: -$OPTARG" >&2
			usage
			return 1
			;;
	esac
done
shift $(( OPTIND - 1 ))


#Confirm that the Required Argument was Given
if [[ "$build_for" = "" ]]; then
	error "Please Enter the Required Argument"
	return 1
fi


#Run Environment Setup
env_setup="source ./build/envsetup.sh"
call "$env_setup"


#Set up Proper Lunch Environment
lunch_command="lunch full"
if [ "$build_for" = "device" ]; then
	lunch_command+="_"
	lunch_command+="$device"
fi

if [ "$build_for" = "fast_emulator" ]; then
	lunch_command+="_x86"
fi

lunch_command+="-eng"
call "$lunch_command"


#Build UiAutomator if Indicated (by default, yes)
if [ "$build" = "true" ] && [ "$build_UiAutomator" = "true" ]; then
	touch frameworks/testing/uiautomator/cmds/uiautomator/src/com/android/commands/uiautomator/DumpCommand.java
	call "mm uiautomator"
fi


#Build Source Code if Indicated (by default, yes)
make_command="make -j"
make_command+=$threads
if [ "$build" = "true" ]; then
	touch frameworks/base/services/java/com/android/server/accessibility/AccessibilityManagerService.java
	call "$make_command"
fi


finish