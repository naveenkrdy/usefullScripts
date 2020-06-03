#!/bin/bash
## 
## cpuNameFix.sh
## Script to fix CPU name shown as 'Unknown' in 'About This Mac' on macOS.
## naveenkrdy (29/09/18)

user_name="naveenkrdy"
dir_location="/System/Library/PrivateFrameworks/AppleSystemInfo.framework/Versions/A/Resources/"
list=($(cd ${dir_location} && ls -1d */ | cut -d\/ -f1))
real_cpu_name="$(sysctl -n machdep.cpu.brand_string)"
current_cpu_name="$(sudo /usr/libexec/PlistBuddy -c "Print :UnknownCPUKind" ${dir_location}/en.lproj/AppleSystemInfo.strings)"

function wait_enter() {
	echo
	read -p "Press enter to continue..."
	echo
}
function bintoxml() {
	sudo /usr/bin/plutil -convert xml1 "$1"
}
function xmltobin() {
	sudo /usr/bin/plutil -convert binary1 "$1"
}

printf '\033[8;30;100t' && clear
echo
echo -e "${italic}  CPU name fix ${normal}"
echo -e "${italic}  $(date -R) ${normal}"
echo -e "${italic}  ${user_name} ${normal}"
echo
wait_enter

echo "Current CPU name : $current_cpu_name"
echo "Actual CPU name  : $real_cpu_name"

while [[ ! $input =~ ^[Yy|Nn]$ ]]; do
	echo
	echo "Do you want to use a custom CPU name or the actual CPU name ?"
	read -p "[Custom=Y / Actual=N]: " input
	if [[ $input =~ ^[Yy]$ ]]; then
		echo
		echo "What do you want your custom CPU name to be ?"
		read -p "[Custom CPU name]: " cpu_name
		echo
		echo "Applying custom CPU name : $cpu_name"
	elif [[ ${input} =~ ^[Nn]$ ]]; then
		echo
		echo "Applying actual CPU name : $real_cpu_name"
		cpu_name="$real_cpu_name"
	else
		echo "INVALID INPUT : Enter Y or N"
		sleep 2
	fi
done

if [[ $(sw_vers -productVersion | cut -d '.' -f2) == 15 ]]; then
	echo "Mounting filesystem as R/W"
	sudo mount -uw /
fi

for item in "${list[@]}"; do
	if [[ -e "${dir_location}${item}/AppleSystemInfo.strings.backup" ]]; then
		if [[ $item == "${list[0]}" ]]; then
			echo "Restoring original files"
			sleep 1
		fi
		sudo rm -rf ${dir_location}${item}/AppleSystemInfo.strings
		sudo cp -Rf ${dir_location}${item}/AppleSystemInfo.strings.backup ${dir_location}${item}/AppleSystemInfo.strings
	fi

	if [[ ! -e "${dir_location}${item}/AppleSystemInfo.strings.backup" ]]; then
		if [[ $item == "${list[0]}" ]]; then
			echo "Backing up original files"
			sleep 1.2
		fi
		sudo cp -Rf ${dir_location}${item}/AppleSystemInfo.strings ${dir_location}${item}/AppleSystemInfo.strings.backup
	fi

	file_location="${dir_location}${item}/AppleSystemInfo.strings"

	if [[ $item == "${list[0]}" ]]; then
		echo "Patching files"
	fi

	bintoxml ${file_location}
	sudo /usr/libexec/PlistBuddy -c "Set :UnknownCPUKind $cpu_name" ${file_location}
	sudo /usr/libexec/PlistBuddy -c "Set :UnknownComputerModel $cpu_name" ${file_location}
	xmltobin ${file_location}
done

echo "Done" && sleep 1
open /System/Library/CoreServices/Applications/About\ This\ Mac.app
