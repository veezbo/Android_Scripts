#!/bin/bash


#Usage Statement
usage()
{
	echo ""
	echo "Used to Flash a Tablet with the Latest Build"
	echo ""
	echo "Optional Arguments: "
	echo "	-u: use if you want to unlock the device"
	echo "	-b: use if you want to supress the build (if you've already built everything)"
	echo "	-f: use if you want to suppress the flash to the device"
	echo ""
}


#Check that we are in the correct directory
current_dir=${PWD##*/}

if [[ ! $current_dir =~ ^AOSP ]]; then
	echo ""
	echo "***************ERROR: Please Enter the appropriate directory: (must be in AOSP)***************"
	usage
	exit 1
fi


#Read in Optional Arguments
unlock="false"
build="true"
flash="true"
while getopts ":ubhf" opt; do
	case $opt in
		u) 
			unlock="true" 
			;;
		b)
			build="false"
			;;
		h) 
			usage
			exit 1 
			;;
		f)
			flash="false"
			;;
		\?)
			echo "***************ERROR: Invalid Argument: -$OPTARG***************" >&2
			usage
			exit 1
			;;
	esac
done
shift $(( OPTIND - 1 ))


#Build
source ./build/envsetup.sh
lunch full_manta-eng
if [ $build = "true" ]; then
	echo ""
	echo "BUILDING"
	echo ""
	make update-api
	make -j16
fi



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
	fastboot oem unlock
	fastboot format cache
	fastboot format userdata
fi


#Flash the device
if [ $flash = "true" ]; then
	adb reboot bootloader
	fastboot -w flashall
fi

echo "FINISHED"
echo ""
exit 0
