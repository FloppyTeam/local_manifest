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
	_unset_only() {
		unset _option _option1 _option2 _option3 _option4 _option4_count _option_help _device _device_build
	}

	_unset_and_stop() {
		_unset_only
		break
	}

	_if_fail_break() {
		echo "  |"
		$1
		if ! [ "$?" == "0" ]
		then
			echo "  |"
			echo "  | Something failed!"
			echo "  | Exiting from script!"
			_unset_and_stop
		fi
	}

	# Unset all for not have any problem
	_unset_only

	# Check if is using 'BASH'
	if [ ! "${BASH_VERSION}" ]
	then
		echo "  | Please do not use 'sh' to run this script"
		echo "  | Just use 'source build.sh'"
		echo "  | Exiting from script!"
		_unset_and_stop
	fi

	# Check if 'repo' is installed
	if [ ! "$(which repo)" ]
	then
		echo "  | You will need to install 'repo'"
		echo "  | Check in this link:"
		echo "  | <https://source.android.com/source/downloading.html>"
		echo "  | Exiting from script!"
		_unset_and_stop
	fi

	# Check if 'curl' is installed
	if [ ! "$(which curl)" ]
	then
		echo "  | You will need 'curl'"
		echo "  | Use 'sudo apt-get install curl' to install 'curl'"
		echo "  | Exiting from script!"
		_unset_and_stop
	fi

	# Name of script
	echo "  | Live Android $_echo_android ($_android_version) - $_echo_custom_android $_echo_custom_android_version ($_custom_android) Sync and Build Script"

	# Check option of user and transform to script
	for _option in "$@"
	do
		if [[ "$_option" == "-h" || "$_option" == "--help" ]]
		then
			echo "  |"
			echo "  | Usage:"
			echo "  | -h    | --help   | To show this message"
			echo "  | -f    | --force  | Force redownload of Android Tree Manifest"
			echo "  | -b    | --bypass | To bypass message 'Press any key'"
			echo "  |"
			echo "  | -l5   | --e610   | To build only for L5/e610"
			echo "  | -l7   | --p700   | To build only for L7/p700"
			echo "  | -gen1 | --gen1   | To build for L5 and L7"
			echo "  |"
			echo "  | -l1ii | --v1     | To build only for L1II/v1"
			echo "  | -l3ii | --vee3   | To build only for L3II/vee3"
			echo "  | -gen2 | --gen2   | To build for L1II and L3II"
			echo "  |"
			echo "  | -a    | --all    | To build for all devices"
			echo "  |"
			echo "  | Tip: Use '-b' if using one of options above"
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

	# Exit if option is 'help'
	if [ "$_option_help" == "enable" ]
	then
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
	echo "  |"
	echo "  | Starting Sync of Android Tree Manifest"
	echo "  | $_echo_custom_android $_echo_custom_android_version ($_custom_android)"
	if ! [ "$_option3" == "enable" ]
	then
		read -p "  | Press any key to continue!" -n 1
	fi

	# Device Choice
	echo "  |"
	echo "  | Choose Devices Manifest to download:"
	echo "  | 1 | L5/L7     | LG Optimus L5/L7 (NoNFC)"
	echo "  | 2 | L1II/L3II | LG Optimus L3II/L1II"
	echo "  |"
	if [ "$_option2" == "enable" ]
	then
		echo "  | Using ${_device}_manifest.xml without ask!"
	else
		read -p "  | Choice (1/ 2/ or any key to exit): " -n 1 -s x
		case "$x" in
			1 ) echo "L5 | L7"; _device="gen1";;
			2 ) echo "L1II | L3II"; _device="gen2";;
			* ) echo "exit"; _unset_and_stop;;
		esac
	fi

	# Remove old Manifest of Android Tree
	if [ "$_option1" == "enable" ]
	then
		echo "  |"
		echo "  | Option 'force' found!"
		echo "  | Removing old Manifest before download new one"
		rm -rf .repo/manifests .repo/manifests.git .repo/manifest.xml .repo/local_manifests/
	fi

	# Initialization of Android Tree
	echo "  |"
	echo "  | Downloading Android Tree Manifest of branch $_custom_android"
	_if_fail_break "repo init -u git://github.com/"$_echo_custom_android"/android.git -b ${_custom_android} -g all,-notdefault,-darwin"

	# Device manifest download
	echo "  |"
	echo "  | Downloading ${_device}_manifest.xml of branch $_custom_android"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/${_device}_manifest.xml -O -L https://raw.github.com/${_github_place}/local_manifest/${_custom_android}/${_device}_manifest.xml"

	# Common device manifest download
	echo "  |"
	echo "  | Downloading msm7x27a_manifest.xml of branch $_custom_android"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/${_github_place}/local_manifest/${_custom_android}/msm7x27a_manifest.xml"

	# Real 'repo sync'
	echo "  |"
	echo "  | Starting Sync of:"
	echo "  | Android $_echo_android ($_android_version) - $_echo_custom_android $_echo_custom_android_version ($_custom_android)"
	if [ "$_option1" == "enable" ]
	then
		echo "  |"
		echo "  | Option 'force' found!"
		echo "  | Using 'repo sync' with '--force-sync'!"
		_if_fail_break "repo sync -q --force-sync"
	else
		_if_fail_break "repo sync -q"
	fi

	# Builing Android
	echo "  |"
	echo "  | Starting Android Building!"
	echo "  | $_echo_custom_android $_echo_custom_android_version ($_custom_android)"
	if ! [ "$_option3" == "enable" ]
	then
		read -p "  | Press any key to continue!" -n 1
	fi

	# Initialize environment
	echo "  |"
	echo "  | Initialize the environment"
	_if_fail_break "source build/envsetup.sh"

	# Another device choice
	echo "  |"
	echo "  | For what device you want to build:"
	echo "  |"
	if [ "${_device}" == "gen1" ]
	then
		echo "  | 1 | LG Optimus L5 NoNFC | E610 E612 E617"
		echo "  | 2 | LG Optimus L7 NoNFC | P700 P705"
		echo "  | 3 | Both options above"
		echo "  |"
		if [ "$_option2" == "enable" ]
		then
			echo "  | Using $_device_build device without ask!"
		else
			read -p "  | Choice (1/2/3/ or * to exit): " -n 1 -s x
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
		echo "  | 1 | LG Optimus L1II Single Dual | E410 E411 E415 E420"
		echo "  | 2 | LG Optimus L3II Single Dual | E425 E430 E431 E435"
		echo "  | 3 | Both options above"
		echo "  |"
		if [ "$_option2" == "enable" ]
		then
			echo "  | Using $_device_build device without ask!"
		else
			read -p "  | Choice (1/2/3/ or * to exit): " -n 1 -s x
			case "$x" in
				1) echo "Building to L1II"; _device_build="v1";;
				2) echo "Building to L3II"; _device_build="vee3";;
				3) echo "Building to L1II/L3II"; _device_build="gen2";;
				*) echo "exit"; _unset_and_stop;;
			esac
		fi
		echo "  |"
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
		echo "  | No device select found!"
		echo "  | Exiting from script!"
		_unset_and_stop
	fi

	# Only Exit if nothing more to do
	if [[ ! "$_option4" == "enable" || "${_option4_count}" == "exit" ]]
	then
		_unset_and_stop
	fi
done

# Goodbye!
echo "  |"
echo "  | Thanks for using this script!"
