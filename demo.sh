#!/bin/bash

TITLE="System Information Report And Test For $HOSTNAME"
TIMESTAMP="Generated $(date), by $USER"

report_disk_info() {
  disk_root=$(df -h | grep "/dev/root")

  disk_root_arr=($disk_root)
  disk_root_size=${disk_root_arr[1]}
  disk_root_used=${disk_root_arr[2]}
  disk_root_used_per=${disk_root_arr[4]}

  echo "Disk(/): $disk_root_used / $disk_root_size ($disk_root_used_per)"

  return
}

report_memory_info() {
  meminfo=(MemTotal MemFree Buffers Cached SReclaimable Shmem)

  for i in {0..5}; do
    item_data=$(grep ${meminfo[$i]} /proc/meminfo)
    item_data_arr=($item_data)
    memdata[$i]=${item_data_arr[1]}
  done

  mem_available=$(( ${memdata[0]} - ${memdata[1]} - ${memdata[2]} - ${memdata[3]} - ${memdata[4]} + ${memdata[5]} ))
  # echo "Memory: $(mem_available)G / ${memdata[0]}G\n"
  printf "Memory: %.2fG / %.2fG\n" $(( mem_available/(1024*1024) )) $(( ${memdata[0]}/(1024*1024) ))

  return
}

report_network_info() {
  echo "Network:"
  nmcli dev

  return
}

test_usb() {
  usb_test=$(lsusb -s 001: | grep -v "Device 001")
  
  if [ -n "$usb_test" ]; then
    echo "usb good"
  else
    echo "usb bad"
  fi

  return
}

test_sd() {
  sd_test=$(lsblk | grep "mmcblk1")

  if [ -n "$sd_test" ]; then
    echo "sd good"
  else
    echo "sd bad"
  fi

  return
}

test_wifi() {
  nmcli dev wifi | head

  return
}

test_hotspot() {
  hotspot_create=$(nmcli dev wifi hotspot con-name RK3588-hotspot ifname wlan0 ssid RK3588-hotspot password 12345678 | grep "successfully")

  if [ -n "$hotspot_create" ]; then
    echo "hotspot create good"
  else
    echo "hotspot create bad"
  fi

  hotspot_activate=$(nmcli c up RK3588-hotspot | grep "successfully")

  if [ -n "$hotspot_activate" ]; then
    echo "hotspot activate good"
  else
    echo "hotspot activate bad"
  fi

  hotspot_deactivate=$(nmcli c down RK3588-hotspot | grep "successfully")

  if [ -n "$hotspot_deactivate" ]; then
    echo "hotspot deactivate good"
  else
    echo "hotspot deactivate bad"
  fi

  return
}

test_4g() {
  nd5g

  return 
}

test_internet() {
  ping_test=$(ping -c 4 www.baidu.com | grep "0% packet loss")
  
  if [ -n "$ping_test" ]; then
    echo "Internet is good"
  else
    echo "Internet is bad"
  fi

  return
}

# main

echo $TITLE
echo $TIMESTAMP

report_disk_info
report_memory_info
report_network_info

test_usb
test_sd
test_wifi
test_hotspot
# test_4g
test_internet