#!/bin/bash
# Generic Variables
_android_version="4.4.4"
_echo_android="KitKat"
_custom_android="cm-11.0"
_echo_custom_android="CyanogenMod"
_echo_custom_android_version="11"
_github_place="TeamHackLG"
# Make loop for usage of 'break' to recursive exit
while true
do
	# Check if is using 'BASH'
	if [ ! "${BASH_VERSION}" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0) Please do not use 'sh' to run this script"
		echo "$(tput setaf 1)---$(tput sgr0) Just use 'source build.sh'"
		echo "$(tput setaf 1)---$(tput sgr0) Exiting from script!"
		_unset_and_stop
	fi

	# Check if 'repo' is installed
	if [ ! "$(which repo)" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0) You will need to install 'repo'"
		echo "$(tput setaf 1)---$(tput sgr0) Check in this link:"
		echo "$(tput setaf 1)---$(tput sgr0) <https://source.android.com/source/downloading.html>"
		echo "$(tput setaf 1)---$(tput sgr0) Exiting from script!"
		_unset_and_stop
	fi

	# Check if 'curl' is installed
	if [ ! "$(which curl)" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0) You will need 'curl'"
		echo "$(tput setaf 1)---$(tput sgr0) Use 'sudo apt-get install curl' to install 'curl'"
		echo "$(tput setaf 1)---$(tput sgr0) Exiting from script!"
		_unset_and_stop
	fi

	# Name of script
	echo "$(tput setaf 1)---$(tput sgr0) Live Android $_echo_android ($_android_version) - $_echo_custom_android $_echo_custom_android_version ($_custom_android) Sync and Build Script"

	# Check option of user and transform to script
	for _option in "$@"
	do
		if [[ "$_option" == "-h" || "$_option" == "--help" ]]
		then
			echo "$(tput setaf 1)---$(tput sgr0)"
			echo "$(tput setaf 1)---$(tput sgr0) Usage:"
			echo "$(tput setaf 1)---$(tput sgr0) -h    | --help   | To show this message"
			echo "$(tput setaf 1)---$(tput sgr0) -f    | --force  | Force redownload of Android Tree Manifest"
			echo "$(tput setaf 1)---$(tput sgr0) -b    | --bypass | To bypass message 'Press any key'"
			echo "$(tput setaf 1)---$(tput sgr0)"
			echo "$(tput setaf 1)---$(tput sgr0) -l5   | --e610   | To build only for L5/e610"
			echo "$(tput setaf 1)---$(tput sgr0) -l7   | --p700   | To build only for L7/p700"
			echo "$(tput setaf 1)---$(tput sgr0) -gen1 | --gen1   | To build for L5 and L7"
			echo "$(tput setaf 1)---$(tput sgr0)"
			echo "$(tput setaf 1)---$(tput sgr0) -l1ii | --v1     | To build only for L1II/v1"
			echo "$(tput setaf 1)---$(tput sgr0) -l3ii | --vee3   | To build only for L3II/vee3"
			echo "$(tput setaf 1)---$(tput sgr0) -gen2 | --gen2   | To build for L1II and L3II"
			echo "$(tput setaf 1)---$(tput sgr0)"
			echo "$(tput setaf 1)---$(tput sgr0) -a    | --all    | To build for all devices"
			echo "$(tput setaf 1)---$(tput sgr0)"
			echo "$(tput setaf 1)---$(tput sgr0) Tip: Use '-b' if using one of options above"
			_option_help="enable"
			_unset_and_stop
		fi
		# Force redownload of android tree
		if [[ "$_option" == "-f" || "$_option" == "--force" ]]
		then
			_option1="enable"
		fi
		# Choose device before menu
		if ! [ "$_option2" == "enable" ]
		then
			if [[ "$_option" == "-l5" || "$_option" == "--e610" ]]
			then
				_option2="enable"
				_device="gen1"
				_device_build="e610"
			fi
			if [[ "$_option" == "-l7" || "$_option" == "--p700" ]]
			then
				_option2="enable"
				_device="gen1"
				_device_build="p700"
			fi
			if [[ "$_option" == "-gen1" || "$_option" == "--gen1" ]]
			then
				_option2="enable"
				_device="gen1"
				_device_build="gen1"
			fi
		fi
		if ! [ "$_option2" == "enable" ]
		then
			if [[ "$_option" == "-l1ii" || "$_option" == "--v1" ]]
			then
				_option2="enable"
				_device="gen2"
				_device_build="v1"
			fi
			if [[ "$_option" == "-l3ii" || "$_option" == "--vee3" ]]
			then
				_option2="enable"
				_device="gen2"
				_device_build="vee3"
			fi
			if [[ "$_option" == "-gen2" || "$_option" == "--gen2" ]]
			then
				_option2="enable"
				_device="gen2"
				_device_build="gen2"
			fi
		fi
		# Force bypass of checks
		if [[ "$_option" == "-b" || "$_option" == "--bypass" ]]
		then
			_option3="enable"
		fi
		if [[ "$_option" == "-a" || "$_option" == "--all" ]]
		then
			_option1="enable"
			_option3="enable"
			_option4="enable"
		fi
	done

	_if_fail_break() {
		echo "$(tput setaf 1)---$(tput sgr0)"
		$1
		if ! [ "$?" == "0" ]
		then
			echo "$(tput setaf 1)---$(tput sgr0)"
			echo "$(tput setaf 1)---$(tput sgr0) Something failed!"
			echo "$(tput setaf 1)---$(tput sgr0) Exiting from script!"
			_unset_and_stop
		fi
	}

	_unset_and_stop() {
		unset _option _option1 _option2 _option3 _device _device_build
		unset _android_version _echo_custom_android_version _echo_android _custom_android _echo_custom_android
		break
	}

	# Exit if option is 'help'
	if [ "$_option_help" == "enable" ]
	then
		unset _option_help
		_unset_and_stop
	fi

	# For all device
	if [ "${_option4}" == "enable" ]
	then
		if [ "${_option4_count}" == "disable" ]
		then
			_option2="enable"
			_device="gen2"
			_device_build="gen2"
			_option4_count="exit"
		fi
		if [ "${_option4_count}" == "" ]
		then
			_option2="enable"
			_device="gen1"
			_device_build="gen1"
			_option4_count="disable"
		fi
	fi

	# Repo Sync
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Starting Sync of Android Tree Manifest"
	echo "$(tput setaf 1)---$(tput sgr0) $_echo_custom_android $_echo_custom_android_version ($_custom_android)"
	if ! [ "$_option3" == "enable" ]
	then
		read -p "$(tput setaf 1)---$(tput sgr0) Press any key to continue!" -n 1
	fi

	# Device Choice
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Choose Devices Manifest to download:"
	echo "$(tput setaf 1)---$(tput sgr0) 1 | L5/L7     | LG Optimus L5/L7 (NoNFC)"
	echo "$(tput setaf 1)---$(tput sgr0) 2 | L1II/L3II | LG Optimus L3II/L1II"
	echo "$(tput setaf 1)---$(tput sgr0)"
	if ! [ "$(ls -a .repo/local_manifests/ | grep msm7x27a_manifest.xml)" == "" ]
	then
		if ! [ "$(ls -a .repo/local_manifests/ | grep gen1_manifest.xml)" == "" ]
		then
			echo "$(tput setaf 1)---$(tput sgr0) Current is: 1 | L5/L7"
		elif ! [ "$(ls -a .repo/local_manifests/ | grep gen2_manifest.xml)" == "" ]
		then
			echo "$(tput setaf 1)---$(tput sgr0) Current is: 2 | L1II/L3II"
		fi
	fi
	echo "$(tput setaf 1)---$(tput sgr0)"
	if [ "$_option2" == "enable" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0) Using ${_device}_manifest.xml without ask!"
	else
		read -p "$(tput setaf 1)---$(tput sgr0) Choice (1/ 2/ or any key to exit): " -n 1 -s x
		case "$x" in
			1 ) echo "L5 | L7"; _device="gen1";;
			2 ) echo "L1II | L3II"; _device="gen2";;
			* ) echo "exit"; _unset_and_stop;;
		esac
	fi

	# Remove old Manifest of Android Tree
	if [ "$_option1" == "enable" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0)"
		echo "$(tput setaf 1)---$(tput sgr0) Option 'force' found!"
		echo "$(tput setaf 1)---$(tput sgr0) Removing old Manifest before download new one"
		rm -rf .repo/manifests .repo/manifests.git .repo/manifest.xml
	fi

	# Initialization of Android Tree
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Downloading Android Tree Manifest of branch $_custom_android"
	_if_fail_break "repo init -u git://github.com/"$_echo_custom_android"/android.git -b ${_custom_android} -g all,-notdefault,-darwin"

	# Device manifest download
	rm -rf .repo/local_manifests/
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Downloading ${_device}_manifest.xml of branch $_custom_android"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/${_device}_manifest.xml -O -L https://raw.github.com/${_github_place}/local_manifest/${_custom_android}/${_device}_manifest.xml"

	# Common device manifest download
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Downloading msm7x27a_manifest.xml of branch $_custom_android"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/${_github_place}/local_manifest/${_custom_android}/msm7x27a_manifest.xml"

	# Real 'repo sync'
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Starting Sync of:"
	echo "$(tput setaf 1)---$(tput sgr0) Android $_echo_android ($_android_version) - $_echo_custom_android $_echo_custom_android_version ($_custom_android)"
	if [ "$_option1" == "enable" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0)"
		echo "$(tput setaf 1)---$(tput sgr0) Option 'force' found!"
		echo "$(tput setaf 1)---$(tput sgr0) Using 'repo sync' with '--force-sync'!"
		_if_fail_break "repo sync -q --force-sync"
	else
		_if_fail_break "repo sync -q"
	fi

	# Builing Android
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Starting Android Building!"
	echo "$(tput setaf 1)---$(tput sgr0) $_echo_custom_android $_echo_custom_android_version ($_custom_android)"
	if ! [ "$_option3" == "enable" ]
	then
		read -p "$(tput setaf 1)---$(tput sgr0) Press any key to continue!" -n 1
	fi

	# Initialize environment
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) Initialize the environment"
	_if_fail_break "source build/envsetup.sh"

	# Another device choice
	echo "$(tput setaf 1)---$(tput sgr0)"
	echo "$(tput setaf 1)---$(tput sgr0) For what device you want to build:"
	echo "$(tput setaf 1)---$(tput sgr0)"
	if [ "${_device}" == "gen1" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0) 1 | LG Optimus L5 NoNFC | E610 E612 E617"
		echo "$(tput setaf 1)---$(tput sgr0) 2 | LG Optimus L7 NoNFC | P700 P705"
		echo "$(tput setaf 1)---$(tput sgr0) 3 | Both options above"
		echo "$(tput setaf 1)---$(tput sgr0)"
		if [ "$_option2" == "enable" ]
		then
			echo "$(tput setaf 1)---$(tput sgr0) Using $_device_build device without ask!"
		else
			read -p "$(tput setaf 1)---$(tput sgr0) Choice (1/2/3/ or * to exit): " -n 1 -s x
			case "$x" in
				1) echo "Building to L5"; _device_build="e610";;
				2) echo "Building to L7"; _device_build="p700";;
				3) echo "Building to L5/L7"; _device_build="gen1";;
				*) echo "exit"; _unset_and_stop;;
			esac
		fi
		if [[ "$_device_build" == "e610" || "$_device_build" == "gen1" ]]
		then
			_if_fail_break "brunch e610"
		fi
		if [[ "$_device_build" == "p700" || "$_device_build" == "gen1" ]]
		then
			_if_fail_break "brunch p700"
		fi
	elif [ "${_device}" == "gen2" ]
	then
		echo "$(tput setaf 1)---$(tput sgr0) 1 | LG Optimus L1II Single Dual | E410 E411 E415 E420"
		echo "$(tput setaf 1)---$(tput sgr0) 2 | LG Optimus L3II Single Dual | E425 E430 E431 E435"
		echo "$(tput setaf 1)---$(tput sgr0) 3 | Both options above"
		echo "$(tput setaf 1)---$(tput sgr0)"
		if [ "$_option2" == "enable" ]
		then
			echo "$(tput setaf 1)---$(tput sgr0) Using $_device_build device without ask!"
		else
			read -p "$(tput setaf 1)---$(tput sgr0) Choice (1/2/3/ or * to exit): " -n 1 -s x
			case "$x" in
				1) echo "Building to L1II"; _device_build="v1";;
				2) echo "Building to L3II"; _device_build="vee3";;
				3) echo "Building to L1II/L3II"; _device_build="gen2";;
				*) echo "exit"; _unset_and_stop;;
			esac
		fi
		echo "$(tput setaf 1)---$(tput sgr0)"
		sh device/lge/vee3/patches/apply.sh
		if [[ "$_device_build" == "v1" || "$_device_build" == "gen2" ]]
		then
			_if_fail_break "brunch v1"
		fi
		if [[ "$_device_build" == "vee3" || "$_device_build" == "gen2" ]]
		then
			_if_fail_break "brunch vee3"
		fi
	else
		echo "$(tput setaf 1)---$(tput sgr0) No device select found!"
		echo "$(tput setaf 1)---$(tput sgr0) Exiting from script!"
		_unset_and_stop
	fi

	# Only Exit if nothing more to do
	if [[ ! "$_option4" == "enable" || "${_option4_count}" == "exit" ]]
	then
		_unset_and_stop
	fi
done

# Goodbye!
echo "$(tput setaf 1)---$(tput sgr0)"
echo "$(tput setaf 1)---$(tput sgr0) Thanks for using this script!"
