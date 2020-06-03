#!/bin/bash
##
## sysInfo.sh
## Provides a small summary of information on macOS system.
## naveenkrdy (28/09/18)

echo "Generating ..."

italic='\x1b[3m'
normal='\033[0;0;39m'
username="naveenkrdy"
macos_model="$(sysctl -n hw.model)"
macos_name="$(sw_vers -productName)"
macos_version="$(sw_vers -productVersion)"
macosBuild="$(sw_vers -buildVersion)"
if [[ "${macos_version}" =~ 10.15.[0-6] ]]; then
	macos_name="Catalina"
elif [[ "${macos_version}" =~ 10.14.[0-6] ]]; then
	macos_name="Mojave"
elif [[ "${macos_version}" =~ 10.13.[0-6] ]]; then
	macos_name="HighSierra"
elif [[ "${macos_version}" =~ 10.12.[0-6] ]]; then
	macos_name="Sierra"
fi
file_location="$(mktemp /tmp/xlnc.diskinfo.plist)"
diskutil info -plist / >"${file_location}"
boot_disk_id="$(defaults read "${file_location}" ParentWholeDisk)"
boot_disk_efi_id="$(defaults read "${file_location}" ParentWholeDisk)s1" #hardcoded /needs to be corrected
boot_disk_size="$(diskutil info "${boot_disk_id}" | grep Disk\ Size | awk {'print $3 $4'})"
type_ssd="$(test "$(defaults read "${file_location}" SolidState)" -eq 0 && echo "No" || echo "Yes")"
boot_vol_name="$(defaults read "${file_location}" VolumeName)"
boot_vol_id="$(defaults read "${file_location}" DeviceIdentifier)"
boot_vol_total_size="$(diskutil info / | grep Total | awk {'print $4 $5'})"
boot_vol_used_size="$(diskutil info / | grep Used | awk {'print $4 $5'})"
boot_vol_free_size="$(diskutil info / | grep 'Avail\|Free' | awk {'print $4 $5'})"
rm -rf "${file_location}"
boot_args="$(sysctl -n kern.bootargs)"
kernel_version="$(uname -v | cut -d ":" -f1 | sed 's/ Kernel\ Version//g')"
kernel_compile_date="$(uname -v | cut -d ';' -f1 | cut -d ':' -f2-)"
kernel_hclass="$(uname -m)"
cpu_name="$(sysctl -n machdep.cpu.brand_string)"
cpu_sig="$(sysctl -n machdep.cpu.signature)"
cpu_sig_hex="$(echo "obase=16; ${cpu_sig}" | bc)"
cpu_cores="$(sysctl -n hw.physicalcpu)"
cpu_threads="$(sysctl -n hw.logicalcpu)"
cpu_cache_l1i="$(($(sysctl -n hw.l1icachesize) / 1024))"
cpu_cache_l1d="$(($(sysctl -n hw.l1dcachesize) / 1024))"
cpu_cache_l2="$(($(sysctl -n hw.l2cachesize) / 1024))"
cpu_cache_l3="$(($(sysctl -n hw.l3cachesize) / 1024))"
cpu_speed="$(($(sysctl -n hw.cpufrequency) / 1000000))"
cpu_stats="$(top -l 1 | grep -E "^CPU" | cut -d ":" -f2)"
cpu_bus_speed="$(($(sysctl -n hw.busfrequency_max) / 1000000))"
cpu_speed_ghz="$(system_profiler SPHardwareDataType | grep Speed | cut -d ":" -f2)"
cpu_features="$(sysctl -n machdep.cpu.features) $(sysctl -n machdep.cpu.extfeatures) $(sysctl -n machdep.cpu.leaf7_features)"
ram_amount="$(($(sysctl -n hw.memsize) / 1024 / 1024))"
ram_amount_gb="$(system_profiler SPHardwareDataType | grep Memory | cut -d ":" -f2)"
ram_stats=$(top -l 1 | grep -E "^Phys" | cut -d ":" -f2)
process_stats=$(top -l 1 | grep -E "^Proc" | cut -d ":" -f2)
gpu_model="$(system_profiler SPDisplaysDataType | grep Chipset | cut -d ':' -f2)"
gpu_devid="$(system_profiler SPDisplaysDataType | grep Dev | cut -d ':' -f2)"
gpu_venid="$(system_profiler SPDisplaysDataType | grep Vendor | cut -d '(' -f2 | cut -d ')' -f1)"
gpu_vram_size="$(system_profiler SPDisplaysDataType | grep VRAM | cut -d ':' -f2)"
gatekeeper_status="$(spctl --status | grep enabled &>/dev/null && echo "Enabled" || echo "Disabled")"
spi_status="$(csrutil status | grep enabled && echo "Enabled" || echo "Disabled")"

printf '\033[8;50;150t' && clear
echo
echo -e "${italic}  System Information ~XLNC~ ${normal}"
echo -e "${italic}  $(date -R) ${normal}"
echo -e "${italic}  ${username} ${normal}"
echo

cat <<EOF
mac Model      : ${macos_model}
macOS Release  : ${macos_name}
macOS Version  : ${macos_version}
macOS Build    : ${macosBuild}

Boot Volume    : Name: ${boot_vol_name}     ID: ${boot_vol_id}      Size: ${boot_vol_total_size} (${boot_vol_used_size} used, ${boot_vol_free_size} free)
Boot Disk      : ID: ${boot_disk_id}        EFI-ID: ${boot_disk_efi_id}      Size: ${boot_disk_size}    SSD: ${type_ssd}

Boot Arguments : ${boot_args}
Kernel Version : ${kernel_version}
Kernel Mode    : ${kernel_hclass}
Kernel Date    :${kernel_compile_date}

CPU Name       : ${cpu_name}
CPU ID         : Ox${cpu_sig_hex}
CPU Cores      : ${cpu_cores}
CPU Threads    : ${cpu_threads}
CPU Speed      :${cpu_speed_ghz} (${cpu_speed}Mhz)
Bus Speed      : ${cpu_bus_speed} Mhz
CPU Usage      :${cpu_stats}
CPU Caches     : L1i: ${cpu_cache_l1i}Kb , L1d: ${cpu_cache_l1d}Kb , L2/c: ${cpu_cache_l2}Kb , L3: ${cpu_cache_l3}Kb
CPU Features   : ${cpu_features}

RAM Size       :${ram_amount_gb} (${ram_amount}MB)
RAM Usage      :${ram_stats}
Processes      :${process_stats}

GPU Model      :${gpu_model}
GPU Device ID  :${gpu_devid}
GPU Vendor ID  : ${gpu_venid}
GPU VRAM Size  :${gpu_vram_size}

Gatekeeper     : ${gatekeeper_status}
SIP Status     : ${spi_status}
EOF

exit
