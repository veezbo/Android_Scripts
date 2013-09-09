#!/bin/bash


#Usage Statement
usage()
{
	echo "
USAGE:
Flashes a Device (must have already built)
No Required Parameters
You must be in the AOSP directory.
Run like:
bash device.sh <optional-arguments>

Optional Parameters: 
	-u unlock the device if needed
	-h display this usage message
	
Examples Uses:
	bash device.sh [flash the device]
	bash device.sh -u [flash the device, while unlocking it]

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


#Check that we are in the correct directory
current_dir=${PWD##*/}

if [[ ! $current_dir =~ ^AOSP ]]; then
	error "Please Enter the appropriate directory: (must be in AOSP)"
	exit 1
fi


#Read in Optional Arguments
unlock="false"
while getopts ":uh" opt; do
	case $opt in
		u) 
			unlock="true" 
			;;
		h) 
			usage
			exit 1 
			;;
		\?)
			echo "***************ERROR: Invalid Argument: -$OPTARG***************" >&2
			usage
			exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))



#If the android.rules file does not exist, then create it to give USB Access on Linux
if [ ! -f /etc/udev/rules.d/51-android.rules ]; then
	sudo touch /etc/udev/rules.d/51-android.rules
	sudo chown $USER /etc/udev/rules.d/51-android.rules
	echo "# adb protocol on passion (Nexus One)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4e12\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on passion (Nexus One)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0bb4\", ATTR{idProduct}==\"0fff\", MODE=\"0600\", OWNER=\"$USER\"
# adb protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4e22\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on crespo/crespo4g (Nexus S)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4e20\", MODE=\"0600\", OWNER=\"$USER\"
# adb protocol on stingray/wingray (Xoom)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"22b8\", ATTR{idProduct}==\"70a9\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on stingray/wingray (Xoom)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"708c\", MODE=\"0600\", OWNER=\"$USER\"
# adb protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"04e8\", ATTR{idProduct}==\"6860\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on maguro/toro (Galaxy Nexus)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4e30\", MODE=\"0600\", OWNER=\"$USER\"
# adb protocol on panda (PandaBoard)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0451\", ATTR{idProduct}==\"d101\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on panda (PandaBoard)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0451\", ATTR{idProduct}==\"d022\", MODE=\"0600\", OWNER=\"$USER\"
# usbboot protocol on panda (PandaBoard)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0451\", ATTR{idProduct}==\"d00f\", MODE=\"0600\", OWNER=\"$USER\"
# usbboot protocol on panda (PandaBoard ES)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"0451\", ATTR{idProduct}==\"d010\", MODE=\"0600\", OWNER=\"$USER\"
# adb protocol on grouper/tilapia (Nexus 7)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4e42\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on grouper/tilapia (Nexus 7)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4e40\", MODE=\"0600\", OWNER=\"$USER\"
# adb protocol on manta (Nexus 10)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4ee2\", MODE=\"0600\", OWNER=\"$USER\"
# fastboot protocol on manta (Nexus 10)
SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", ATTR{idProduct}==\"4ee0\", MODE=\"0600\", OWNER=\"$USER\"" > /etc/udev/rules.d/51-android.rules
	sudo chown root /etc/udev/rules.d/51-android.rules
fi


#Unlock if necessary
if [ $unlock = "true" ]; then
	call "fastboot oem unlock"
	call "fastboot format cache"
	call "fastboot format userdata"
fi


#Flash the device
call "adb reboot bootloader"
call "fastboot -w flashall"

finish