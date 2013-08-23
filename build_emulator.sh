#!/bin/bash


#README -------------------------------------------------------------------------------------------------------------
#Note: This MUST be run with the source (or dot operator) command, so it is run in the current shell
#README	-------------------------------------------------------------------------------------------------------------


usage()
{
	echo "
USAGE:
Used to Build a Particular AOSP Project
No Required Arguments
However, this scipt MUST be sourced, example:
source build.sh <optional_args>
Furthermore, you must be in the AOSP directory.

Optional Arguments: 
	-b Exclude the latter two build commands (which only must be run once per project, and are time-consuming)
	-h Display this usage message
	"
}


#Check that this script has been sourced
if (( $SHLVL == 2 )); then
	echo ""
	echo "***************ERROR Please Source this bash scipt***************"
	usage
	exit 1
fi


#Check that we are in the correct directory
current_dir=${PWD##*/}

if [[ ! $current_dir =~ ^AOSP ]]; then
	echo ""
	echo "***************ERROR Please Enter the appropriate directory: (must be in AOSP)***************"
	exit 1
fi


#Read in Optional Arguments
build="true"
while getopts ":bhu" opt; do
	case $opt in
		b)
			build="false"
			;;
		h)
			usage
			exit 1
			;;
		u)
			usage
			exit 1
			;;
		\?)
			usage
			echo "Invalid Argument: -$OPTARG" >&2
			exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))


#Build
source ./build/envsetup.sh
lunch full-eng
if [ $build = "true" ]; then
	echo ""
	echo "BUILDING"
	echo ""
	# make update-api
	make -j16
fi