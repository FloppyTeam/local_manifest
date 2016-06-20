#!/bin/bash
# Generic Variables
_android="5.1.1"
_android_version="LolliPop"
_custom_android="cm-12.1"
_custom_android_version="CyanogenMod12.1"
_github_custom_android_place="CyanogenMod"
_github_device_place="TeamHackLG"
# Make loop for usage of 'break' to recursive exit
while true
do
	_unset_only() {
		unset _option _option_force _option_exit _device _device_build
	}

	_unset_and_stop() {
		_unset_only
		break
	}

	_if_fail_break() {
		${1}
		if ! [ "${?}" == "0" ]
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
	echo "  | Live Android ${_android_version} (${_android}) - ${_custom_android_version} (${_custom_android}) Sync and Build Script"

	# Check option of user and transform to script
	for _u2t in "${@}"
	do
		if [[ "${_u2t}" == "-h" || "${_u2t}" == "--help" ]]
		then
			echo "  |"
			echo "  | Usage:"
			echo "  | -h    | --help  | To show this message"
			echo "  | -f    | --force | Force redownload of Android Tree Manifest"
			echo "  |"
			echo "  | -l5   | --e610  | To build only for L5/e610"
			echo "  | -l7   | --p700  | To build only for L7/p700"
			echo "  | -gen1 | --gen1  | To build for L5 and L7"
			echo "  |"
			echo "  | -l1ii | --v1    | To build only for L1II/v1"
			echo "  | -l3ii | --vee3  | To build only for L3II/vee3"
			echo "  | -gen2 | --gen2  | To build for L1II and L3II"
			_option_exit="enable"
			_unset_and_stop
		fi
		# Force redownload of android tree
		if [[ "${_u2t}" == "-f" || "${_u2t}" == "--force" ]]
		then
			_option_force="enable"
		fi
		# Choose device before menu
		if [ "${_device}" == "gen2" ]
		then
			echo "  |"
			echo "  | You select 2 devices at same time"
			echo "  | Sorry, we will exit from script"
			_option_exit="enable"
			_unset_and_stop
		else
			if [[ "${_u2t}" == "-l5" || "${_u2t}" == "--e610" ]]
			then
				_device="gen1"
				_device_build="e610"
			fi
			if [[ "${_u2t}" == "-l7" || "${_u2t}" == "--p700" ]]
			then
				_device="gen1"
				_device_build="p700"
			fi
			if [[ "${_u2t}" == "-gen1" || "${_u2t}" == "--gen1" ]]
			then
				_device="gen1"
				_device_build="gen1"
			fi
		fi
		if [ "${_device}" == "gen1" ]
		then
			echo "  |"
			echo "  | You select 2 devices at same time"
			echo "  | Sorry, we will exit from script"
			_option_exit="enable"
			_unset_and_stop
		else
			if [[ "${_u2t}" == "-l1ii" || "${_u2t}" == "--v1" ]]
			then
				_device="gen2"
				_device_build="v1"
			fi
			if [[ "${_u2t}" == "-l3ii" || "${_u2t}" == "--vee3" ]]
			then
				_device="gen2"
				_device_build="vee3"
			fi
			if [[ "${_u2t}" == "-gen2" || "${_u2t}" == "--gen2" ]]
			then
				_device="gen2"
				_device_build="gen2"
			fi
		fi
	done

	# Exit if option is 'help'
	if [ "${_option_exit}" == "enable" ]
	then
		_unset_and_stop
	fi

	# Repo Sync
	echo "  |"
	echo "  | Starting Sync of Android Tree Manifest"

	# Device Choice
	echo "  |"
	echo "  | Choose Devices Manifest to download:"
	echo "  | 1 | L5/L7     | LG Optimus L5/L7 (NoNFC)"
	echo "  | 2 | L1II/L3II | LG Optimus L3II/L1II"
	echo "  |"
	if [ "${_device}" == "" ]
	then
		read -p "  | Choice (1/ 2/ or any key to exit): " -n 1 -s x
		case "${x}" in
			1 ) echo "L5 | L7"; _device="gen1";;
			2 ) echo "L1II | L3II"; _device="gen2";;
			* ) echo "exit"; _unset_and_stop;;
		esac
	else
		echo "  | Using ${_device}_manifest.xml without ask!"
	fi

	# Remove old Manifest of Android Tree
	if [ "${_option_force}" == "enable" ]
	then
		echo "  |"
		echo "  | Option 'force' found!"
		echo "  | Removing old Manifest before download new one"
		rm -rf .repo/manifests .repo/manifests.git .repo/manifest.xml .repo/local_manifests/
	fi

	# Initialization of Android Tree
	echo "  |"
	echo "  | Downloading Android Tree Manifest from ${_github_custom_android_place} branch ${_custom_android}"
	_if_fail_break "repo init -u git://github.com/${_github_custom_android_place}/android.git -b ${_custom_android} -g all,-notdefault,-darwin"

	# Device manifest download
	echo "  |"
	echo "  | Downloading ${_device}_manifest.xml from ${_github_device_place} branch ${_custom_android}"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/${_device}_manifest.xml -O -L https://raw.github.com/${_github_device_place}/local_manifest/${_custom_android}/${_device}_manifest.xml"

	# Common device manifest download
	echo "  |"
	echo "  | Downloading msm7x27a_manifest.xml from ${_github_device_place} branch ${_custom_android}"
	_if_fail_break "curl -# --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/${_github_device_place}/local_manifest/${_custom_android}/msm7x27a_manifest.xml"

	# Real 'repo sync'
	echo "  |"
	echo "  | Starting Sync:"
	if [ "${_option_force}" == "enable" ]
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
		if [ "${_device_build}" == "" ]
		then
			read -p "  | Choice (1/2/3/ or * to exit): " -n 1 -s x
			case "${x}" in
				1) echo "Building to L5"; _device_build="e610";;
				2) echo "Building to L7"; _device_build="p700";;
				3) echo "Building to L5/L7"; _device_build="gen1";;
				*) echo "exit"; _unset_and_stop;;
			esac
		else
			echo "  | Using ${_device_build} device without ask!"
		fi
		if [[ "${_device_build}" == "e610" || "${_device_build}" == "gen1" ]]
		then
			_if_fail_break "brunch e610"
		fi
		if [[ "${_device_build}" == "p700" || "${_device_build}" == "gen1" ]]
		then
			_if_fail_break "brunch p700"
		fi
	elif [ "${_device}" == "gen2" ]
	then
		echo "  | 1 | LG Optimus L1II Single Dual | E410 E411 E415 E420"
		echo "  | 2 | LG Optimus L3II Single Dual | E425 E430 E431 E435"
		echo "  | 3 | Both options above"
		echo "  |"
		if [ "${_device_build}" == "" ]
		then
			read -p "  | Choice (1/2/3/ or * to exit): " -n 1 -s x
			case "${x}" in
				1) echo "Building to L1II"; _device_build="v1";;
				2) echo "Building to L3II"; _device_build="vee3";;
				3) echo "Building to L1II/L3II"; _device_build="gen2";;
				*) echo "exit"; _unset_and_stop;;
			esac
		else
			echo "  | Using ${_device_build} device without ask!"
		fi
		echo "  |"
		sh device/lge/vee3/patches/apply.sh
		if [[ "${_device_build}" == "v1" || "${_device_build}" == "gen2" ]]
		then
			_if_fail_break "brunch v1"
		fi
		if [[ "${_device_build}" == "vee3" || "${_device_build}" == "gen2" ]]
		then
			_if_fail_break "brunch vee3"
		fi
	else
		echo "  | No device select found!"
		echo "  | Exiting from script!"
	fi

	# Exit
	_unset_and_stop
done

# Goodbye!
echo "  |"
echo "  | Thanks for using this script!"
