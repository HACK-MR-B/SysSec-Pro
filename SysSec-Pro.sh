#!/bin/bash

update_flag_file="/tmp/sys_scan_first_run"

red='\033[1;31m'
reset='\033[0m'

function flashing_text() {
  while true; do
    echo -e "${red}HACK Mr:B${reset}"
    sleep 0.5
    clear
  done
}

echo -e "${red}HACK Mr:B${reset}"

if [ ! -f "$update_flag_file" ]; then
  flashing_text &
  flashing_pid=$!

  echo "Tools are downloading..."

  {
    echo "----- APT Update Log -----"
    sudo apt update
    echo "----- APT Install Log -----"
    sudo apt install -y xterm chkrootkit rkhunter lynis
  } &> /tmp/apt_update_install_log.txt

  touch "$update_flag_file"

  kill $flashing_pid
  wait $flashing_pid 2>/dev/null

  xterm -e "cat /tmp/apt_update_install_log.txt" &
fi

blue='\033[1;34m'
yellow='\033[1;33m'

function alert_user() {
  echo "Warning: Avoid downloading data from unofficial sources!"
  notify-send "Security Alert: Avoid downloading data from unofficial sources!"
}

function show_disk_space() {
  df -h | grep '^/dev/' | awk '{print $1 ": " $4 " free"}'
}

function repair_files() {
  echo -e "${yellow}Repairing corrupted files...${reset}"
  sudo fsck -y /
  echo -e "${yellow}Repair completed.${reset}"
}

function clean_files() {
  echo -e "${yellow}Cleaning unnecessary files...${reset}"

  echo "Disk space before cleaning:"
  show_disk_space

  sudo apt autoremove -y
  sudo apt clean

  echo "Disk space after cleaning:"
  show_disk_space
}

while true; do
  echo -e "${blue}Choose the tool you want to use for the scan:${reset}"
  PS3="Please select the tool number (or choose 4 to return): "

  echo -e "${blue}1) Chkrootkit${reset}"
  echo -e "${blue}2) RKHunter${reset}"
  echo -e "${blue}3) Lynis${reset}"
  echo -e "${yellow}4) Repair corrupted files${reset}"
  echo -e "${yellow}5) Clean unnecessary files${reset}"
  echo -e "${red}6) cancellation${reset}"

  read -p "Please select the tool number: " choice

  case $choice in
    1)
      echo -e "${blue}employment Chkrootkit...${reset}"
      xterm -e "sudo chkrootkit"
      alert_user
      ;;
    2)
      echo -e "${blue}employment RKHunter...${reset}"
      xterm -e "sudo rkhunter --check --sk --nocolors"
      alert_user
      ;;
    3)
      echo -e "${blue}employment Lynis...${reset}"
      output_file="/tmp/lynis_audit_results.txt"
      xterm -e "sudo lynis audit system | tee $output_file"
      alert_user
      echo "Results saved to $output_file"
      ;;
    4)
      repair_files
      ;;
    5)
      clean_files
      ;;
    6)
      echo -e "${red}The operation has been cancelled.${reset}"
      exit
      ;;
    *)
      echo "Invalid choice, please choose a valid number."
      ;;
  esac
done
