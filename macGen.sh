#!/bin/bash
##
## macGen.sh
## Script to generate SMBIOS data.
## naveenkrdy (18/09/2019)

rm -rf /tmp/macinfo*

italic='\x1b[3m'
normal='\033[0;0;39m'
user_name="naveenkrdy"
version="$(curl -s https://api.github.com/repos/acidanthera/MacInfoPkg/releases/latest | grep "tag_name" | cut -d "\"" -f 4)"
download_link="https://github.com/acidanthera/MacInfoPkg/releases/download/${version}/macinfo-${version}-mac.zip"
macgen_zip="/tmp/macinfo-${version}-mac.zip"
macgen_folder="/tmp/macinfo-${version}-mac"
uuid="$(uuidgen)"

curl -sL $download_link --output $macgen_zip
unzip -o -a $macgen_zip -d $macgen_folder &>/dev/null

printf '\033[8;25;90t' && clear
echo
echo -e "${italic}  SMBIOS Data Generator ${normal}"
echo -e "${italic}  $(date -R) ${normal}"
echo -e "${italic}  ${user_name} ${normal}"
echo

function generate_smbios() {
	echo
	read -p "Enter SMBIOS: " SMBIOS
	echo
	echo "     SMBIOS    |    SERIAL    |     MLB   "
	$macgen_folder/macserial -a | grep -i "$SMBIOS" | head -1
	echo
	echo "                       UUID"
	echo "         $uuid"
}

while ! [[ $REPLY =~ [Ee] ]]; do
	generate_smbios
	echo
	read -p "Press [Enter] to generate again or [E] to exit. " -n 1 -r
done

rm -rf $macgen_zip $macgen_folder
