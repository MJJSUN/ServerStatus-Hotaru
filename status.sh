#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#  System Required: CentOS/Debian/Ubuntu/ArchLinux
#  Description: ServerStatus client + server
#  Version: Test v0.4.1
#  Author: Toyo, Modified by APTX
#=================================================

sh_ver="0.4.1"
filepath=$(
  cd "$(dirname "$0")" || exit
  pwd
)
file_1=$(echo -e "${filepath}" | awk -F "$0" '{print $1}')
file="/usr/local/ServerStatus"
web_file="/usr/local/ServerStatus/web"
server_file="/usr/local/ServerStatus/server"
server_conf="/usr/local/ServerStatus/server/config.json"
server_conf_1="/usr/local/ServerStatus/server/config.conf"
client_file="/usr/local/ServerStatus/client"

client_log_file="/tmp/serverstatus_client.log"
server_log_file="/tmp/serverstatus_server.log"
jq_file="${file}/jq"
[[ ! -e ${jq_file} ]] && jq_file="/usr/bin/jq"
region_json="${file}/region.json"

github_prefix="https://raw.githubusercontent.com/MJJSUN/ServerStatus-Hotaru/master"
link_prefix=${github_prefix}

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[淇℃伅]${Font_color_suffix}"
Error="${Red_font_prefix}[閿欒]${Font_color_suffix}"
Tip="${Green_font_prefix}[娉ㄦ剰]${Font_color_suffix}"

#妫€鏌ョ郴缁?check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif grep -q -E -i "debian|ubuntu" /etc/issue; then
    release="debian"
  elif grep -q -E -i "centos|red hat|redhat" /etc/issue; then
    release="centos"
  elif grep -q -E -i "Arch|Manjaro" /etc/issue; then
    release="archlinux"
  elif grep -q -E -i "debian|ubuntu" /proc/version; then
    release="debian"
  elif grep -q -E -i "centos|red hat|redhat" /proc/version; then
    release="centos"
  else
    echo -e "ServerStatus 鏆備笉鏀寔璇inux鍙戣鐗?
  fi
  bit=$(uname -m)
}
check_installed_server_status() {
  [[ ! -e "${server_file}/sergate" ]] && echo -e "${Error} ServerStatus 鏈嶅姟绔病鏈夊畨瑁咃紝璇锋鏌?!" && exit 1
}
check_installed_client_status() {
  [[ ! -e "${client_file}/status-client.py" ]] && echo -e "${Error} ServerStatus 瀹㈡埛绔病鏈夊畨瑁咃紝璇锋鏌?!" && exit 1
}
check_pid_server() {
  #PID=$(ps -ef | grep "sergate" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
  PID=$(pgrep -f "sergate")
}
check_pid_client() {
  #PID=$(ps -ef | grep "status-client.py" | grep -v grep | grep -v ".sh" | grep -v "init.d" | grep -v "service" | awk '{print $2}')
  PID=$(pgrep -f "status-client.py")
}
check_region() {
  # 濡傛灉鎵句笉鍒?region 鏂囦欢, 榛樿涓嶆娴?  [[ ! -e "${region_json}" ]] && return 0
  if ${jq_file} "[.countries | has(\"${region_s}}\")]" "${region_json}" | grep -q 'true' >/dev/null 2>&1; then
    return 0
  elif grep -qw "${region_s}" "${region_json}"; then
    region_s=$(grep -w "${region_s}" "${region_json}" | sed "s/[[:space:]]//g")
    region_s=${region_s:1:2}
    return 0
  fi
  return 1
}
Download_Server_Status_server() {
  cd "/tmp" || exit 1
  [[ ${mirror_num} == 2 ]] && bundle_link="https://cokemine.coding.net/p/hotarunet/d/ServerStatus-Hotaru/git/archive/master/?download=true" || bundle_link="https://github.com/CokeMine/ServerStatus-Hotaru/archive/master.zip"
  [[ ${mirror_num} == 2 ]] && github_link="https://hub.fastgit.org" || github_link="https://github.com"
  wget -N --no-check-certificate "${bundle_link}" -O "master.zip"
  [[ ! -e "master.zip" ]] && echo -e "${Error} ServerStatus 鏈嶅姟绔笅杞藉け璐?!" && exit 1
  unzip master.zip
  rm -rf master.zip
  [[ -d "/tmp/cokemine-hotarunet-ServerStatus-Hotaru-master" ]] && mv "/tmp/cokemine-hotarunet-ServerStatus-Hotaru-master" "/tmp/ServerStatus-Hotaru-master"
  [[ ! -d "/tmp/ServerStatus-Hotaru-master" ]] && echo -e "${Error} ServerStatus 鏈嶅姟绔В鍘嬪け璐?!" && exit 1
  cd "/tmp/ServerStatus-Hotaru-master/server" || exit 1
  make
  [[ ! -e "sergate" ]] && echo -e "${Error} ServerStatus 鏈嶅姟绔紪璇戝け璐?!" && cd "${file_1}" && rm -rf "/tmp/ServerStatus-Hotaru-master" && exit 1
  cd "${file_1}" || exit 1
  mkdir -p "${server_file}"
  if [[ -e "${server_file}/sergate" ]]; then
    mv "${server_file}/sergate" "${server_file}/sergate1"
    mv "/tmp/ServerStatus-Hotaru-master/server/sergate" "${server_file}/sergate"
  else
    mv "/tmp/ServerStatus-Hotaru-master/server/sergate" "${server_file}/sergate"
    wget -N --no-check-certificate "${github_link}/cokemine/hotaru_theme/releases/latest/download/hotaru-theme.zip"
    unzip hotaru-theme.zip && mv "./hotaru-theme" "${web_file}"
    rm -rf hotaru-theme.zip
  fi
  rm -rf "/tmp/ServerStatus-Hotaru-master"
  if [[ ! -e "${server_file}/sergate" ]]; then
    echo -e "${Error} ServerStatus 鏈嶅姟绔Щ鍔ㄩ噸鍛藉悕澶辫触 !"
    [[ -e "${server_file}/sergate1" ]] && mv "${server_file}/sergate1" "${server_file}/sergate"
    exit 1
  else
    [[ -e "${server_file}/sergate1" ]] && rm -rf "${server_file}/sergate1"
  fi
}
Download_Server_Status_client() {
  cd "/tmp" || exit 1
  wget -N --no-check-certificate "${link_prefix}/clients/status-client.py"
  [[ ! -e "status-client.py" ]] && echo -e "${Error} ServerStatus 瀹㈡埛绔笅杞藉け璐?!" && exit 1
  cd "${file_1}" || exit 1
  mkdir -p "${client_file}"
  [[ -e "${client_file}/status-client.py" ]] && mv "${client_file}/status-client.py" "${client_file}/status-client1.py"
  mv "/tmp/status-client.py" "${client_file}/status-client.py"
  if [[ ! -e "${client_file}/status-client.py" ]]; then
    echo -e "${Error} ServerStatus 瀹㈡埛绔Щ鍔ㄥけ璐?!"
    [[ -e "${client_file}/status-client1.py" ]] && mv "${client_file}/status-client1.py" "${client_file}/status-client.py"
    rm -rf "/tmp/status-client.py"
    exit 1
  else
    [[ -e "${client_file}/status-client1.py" ]] && rm -rf "${client_file}/status-client1.py"
    rm -rf "/tmp/status-client.py"
  fi
}
Download_Server_Status_Service() {
  mode=$1
  [[ -z ${mode} ]] && mode="server"
  local service_note="服务端"
  [[ ${mode} == "client" ]] && service_note="客户端"
  wget --no-check-certificate "${link_prefix}/service/status-${mode}.service" -O "/usr/lib/systemd/system/status-${mode}.service" ||
    {
      echo -e "${Error} ServerStatus ${service_note}服务管理脚本下载失败 !"
      exit 1
    }
  systemctl enable "status-${mode}.service"
  echo -e "${Info} ServerStatus ${service_note}服务管理脚本下载完成 !"
}
Service_Server_Status_server() {
  Download_Server_Status_Service "server"
}
Service_Server_Status_client() {
  Download_Server_Status_Service "client"
}
Installation_dependency() {
  mode=$1
  if [[ ${release} == "centos" ]]; then
    yum makecache
    yum -y install unzip
    yum -y install python3 >/dev/null 2>&1 || yum -y install python
    [[ ${mode} == "server" ]] && yum -y groupinstall "Development Tools"
  elif [[ ${release} == "debian" ]]; then
    apt -y update
    apt -y install unzip
    apt -y install python3 >/dev/null 2>&1 || apt -y install python
    [[ ${mode} == "server" ]] && apt -y install build-essential
  elif [[ ${release} == "archlinux" ]]; then
    pacman -Sy python python-pip unzip --noconfirm
    [[ ${mode} == "server" ]] && pacman -Sy base-devel --noconfirm
  fi
  [[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python3 /usr/bin/python
}
Write_server_config() {
  cat >${server_conf} <<-EOF
{"servers":
 [
  {
   "username": "username01",
   "password": "password",
   "name": "Server 01",
   "type": "KVM",
   "host": "",
   "location": "Hong Kong",
   "disabled": false,
   "region": "HK"
  }
 ]
}
EOF
}
Write_server_config_conf() {
  cat >${server_conf_1} <<-EOF
PORT = ${server_port_s}
EOF
}
Read_config_client() {
  client_text="$(sed 's/\"//g;s/,//g;s/ //g' "${client_file}/status-client.py") "
  client_server="$(echo -e "${client_text}" | grep "SERVER=" | awk -F "=" '{print $2}')"
  client_port="$(echo -e "${client_text}" | grep "PORT=" | awk -F "=" '{print $2}')"
  client_user="$(echo -e "${client_text}" | grep "USER=" | awk -F "=" '{print $2}')"
  client_password="$(echo -e "${client_text}" | grep "PASSWORD=" | awk -F "=" '{print $2}')"
  grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" "${client_file}/status-client.py" && client_vnstat="true" || client_vnstat="false"
}
Read_config_server() {
  if [[ ! -e "${server_conf_1}" ]]; then
    server_port_s="35601"
    Write_server_config_conf
    server_port="35601"
  else
    server_port="$(grep "PORT = " ${server_conf_1} | awk '{print $3}')"
  fi
}
Set_server() {
  mode=$1
  [[ -z ${mode} ]] && mode="server"
  if [[ ${mode} == "server" ]]; then
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔腑缃戠珯瑕佽缃殑 鍩熷悕[server]
榛樿涓烘湰鏈篒P涓哄煙鍚嶏紝渚嬪杈撳叆: toyoo.pw 锛屽鏋滆浣跨敤鏈満IP锛岃鐣欑┖鐩存帴鍥炶溅"
    read -erp "(榛樿: 鏈満IP):" server_s
    [[ -z "$server_s" ]] && server_s=""
  else
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔殑 IP/鍩熷悕[server]锛岃娉ㄦ剰锛屽鏋滀綘鐨勫煙鍚嶄娇鐢ㄤ簡CDN锛岃鐩存帴濉啓IP"
    read -erp "(榛樿: 127.0.0.1):" server_s
    [[ -z "$server_s" ]] && server_s="127.0.0.1"
  fi

  echo && echo "	================================================"
  echo -e "	IP/鍩熷悕[server]: ${Red_background_prefix} ${server_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_server_http_port() {
  while true; do
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔腑缃戠珯瑕佽缃殑 鍩熷悕/IP鐨勭鍙1-65535]锛堝鏋滄槸鍩熷悕鐨勮瘽锛屼竴鑸敤 80 绔彛锛?
    read -erp "(榛樿: 8888):" server_http_port_s
    [[ -z "$server_http_port_s" ]] && server_http_port_s="8888"
    if [[ "$server_http_port_s" =~ ^[0-9]*$ ]]; then
      if [[ ${server_http_port_s} -ge 1 ]] && [[ ${server_http_port_s} -le 65535 ]]; then
        echo && echo "	================================================"
        echo -e "	绔彛: ${Red_background_prefix} ${server_http_port_s} ${Font_color_suffix}"
        echo "	================================================" && echo
        break
      else
        echo "杈撳叆閿欒, 璇疯緭鍏ユ纭殑绔彛銆?
      fi
    else
      echo "杈撳叆閿欒, 璇疯緭鍏ユ纭殑绔彛銆?
    fi
  done
}
Set_server_port() {
  while true; do
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔洃鍚殑绔彛[1-65535]锛堢敤浜庢湇鍔＄鎺ユ敹瀹㈡埛绔秷鎭殑绔彛锛屽鎴风瑕佸～鍐欒繖涓鍙ｏ級"
    read -erp "(榛樿: 35601):" server_port_s
    [[ -z "$server_port_s" ]] && server_port_s="35601"
    if [[ "$server_port_s" =~ ^[0-9]*$ ]]; then
      if [[ ${server_port_s} -ge 1 ]] && [[ ${server_port_s} -le 65535 ]]; then
        echo && echo "	================================================"
        echo -e "	绔彛: ${Red_background_prefix} ${server_port_s} ${Font_color_suffix}"
        echo "	================================================" && echo
        break
      else
        echo "杈撳叆閿欒, 璇疯緭鍏ユ纭殑绔彛銆?
      fi
    else
      echo "杈撳叆閿欒, 璇疯緭鍏ユ纭殑绔彛銆?
    fi
  done
}
Set_username() {
  mode=$1
  [[ -z ${mode} ]] && mode="server"
  if [[ ${mode} == "server" ]]; then
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔璁剧疆鐨勭敤鎴峰悕[username]锛堝瓧姣?鏁板瓧锛屼笉鍙笌鍏朵粬璐﹀彿閲嶅锛?
  else
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔腑瀵瑰簲閰嶇疆鐨勭敤鎴峰悕[username]锛堝瓧姣?鏁板瓧锛屼笉鍙笌鍏朵粬璐﹀彿閲嶅锛?
  fi
  read -erp "(榛樿: 鍙栨秷):" username_s
  [[ -z "$username_s" ]] && echo "宸插彇娑?.." && exit 0
  echo && echo "	================================================"
  echo -e "	璐﹀彿[username]: ${Red_background_prefix} ${username_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_password() {
  mode=$1
  [[ -z ${mode} ]] && mode="server"
  if [[ ${mode} == "server" ]]; then
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔璁剧疆鐨勫瘑鐮乕password]锛堝瓧姣?鏁板瓧锛屽彲閲嶅锛?
  else
    echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔腑瀵瑰簲閰嶇疆鐨勫瘑鐮乕password]锛堝瓧姣?鏁板瓧锛?
  fi
  read -erp "(榛樿: doub.io):" password_s
  [[ -z "$password_s" ]] && password_s="doub.io"
  echo && echo "	================================================"
  echo -e "	瀵嗙爜[password]: ${Red_background_prefix} ${password_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_vnstat() {
  echo -e "瀵逛簬娴侀噺璁＄畻鏄惁浣跨敤Vnstat姣忔湀鑷姩娓呴浂锛?[y/N]"
  read -erp "(榛樿: N):" isVnstat
  [[ -z "$isVnstat" ]] && isVnstat="n"
}
Set_name() {
  echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔璁剧疆鐨勮妭鐐瑰悕绉癧name]锛堟敮鎸佷腑鏂囷紝鍓嶆彁鏄綘鐨勭郴缁熷拰SSH宸ュ叿鏀寔涓枃杈撳叆锛屼粎浠呮槸涓悕瀛楋級"
  read -erp "(榛樿: Server 01):" name_s
  [[ -z "$name_s" ]] && name_s="Server 01"
  echo && echo "	================================================"
  echo -e "	鑺傜偣鍚嶇О[name]: ${Red_background_prefix} ${name_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_type() {
  echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔璁剧疆鐨勮妭鐐硅櫄鎷熷寲绫诲瀷[type]锛堜緥濡?OpenVZ / KVM锛?
  read -erp "(榛樿: KVM):" type_s
  [[ -z "$type_s" ]] && type_s="KVM"
  echo && echo "	================================================"
  echo -e "	铏氭嫙鍖栫被鍨媅type]: ${Red_background_prefix} ${type_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_location() {
  echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔璁剧疆鐨勮妭鐐逛綅缃甗location]锛堟敮鎸佷腑鏂囷紝鍓嶆彁鏄綘鐨勭郴缁熷拰SSH宸ュ叿鏀寔涓枃杈撳叆锛?
  read -erp "(榛樿: Hong Kong):" location_s
  [[ -z "$location_s" ]] && location_s="Hong Kong"
  echo && echo "	================================================"
  echo -e "	鑺傜偣浣嶇疆[location]: ${Red_background_prefix} ${location_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_region() {
  echo -e "璇疯緭鍏?ServerStatus 鏈嶅姟绔璁剧疆鐨勮妭鐐瑰湴鍖篬region]锛堢敤浜庡浗瀹?鍦板尯鐨勬棗甯滃浘鏍囨樉绀猴級"
  read -erp "(榛樿: HK):" region_s
  [[ -z "$region_s" ]] && region_s="HK"
  while ! check_region; do
    read -erp "浣犺緭鍏ョ殑鑺傜偣鍦板尯涓嶅悎娉曪紝璇烽噸鏂拌緭鍏ワ細" region_s
  done
  echo && echo "	================================================"
  echo -e "	鑺傜偣鍦板尯[region]: ${Red_background_prefix} ${region_s} ${Font_color_suffix}"
  echo "	================================================" && echo
}
Set_config_server() {
  Set_username "server"
  Set_password "server"
  Set_name
  Set_type
  Set_location
  Set_region
}
Set_config_client() {
  Set_server "client"
  Set_server_port
  Set_username "client"
  Set_password "client"
  Set_vnstat
}
Set_ServerStatus_server() {
  check_installed_server_status
  echo && echo -e " 浣犺鍋氫粈涔堬紵

 ${Green_font_prefix} 1.${Font_color_suffix} 娣诲姞 鑺傜偣閰嶇疆
 ${Green_font_prefix} 2.${Font_color_suffix} 鍒犻櫎 鑺傜偣閰嶇疆
鈥斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 3.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鑺傜偣鐢ㄦ埛鍚? ${Green_font_prefix} 4.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鑺傜偣瀵嗙爜
 ${Green_font_prefix} 5.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鑺傜偣鍚嶇О
 ${Green_font_prefix} 6.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鑺傜偣铏氭嫙鍖? ${Green_font_prefix} 7.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鑺傜偣浣嶇疆
 ${Green_font_prefix} 8.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鑺傜偣鍖哄煙
 ${Green_font_prefix} 9.${Font_color_suffix} 淇敼 鑺傜偣閰嶇疆 - 鍏ㄩ儴鍙傛暟
鈥斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 10.${Font_color_suffix} 鍚敤/绂佺敤 鑺傜偣閰嶇疆
鈥斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix}11.${Font_color_suffix} 淇敼 鏈嶅姟绔洃鍚鍙? && echo
  read -erp "(榛樿: 鍙栨秷):" server_num
  [[ -z "${server_num}" ]] && echo "宸插彇娑?.." && exit 1
  if [[ ${server_num} == "1" ]]; then
    Add_ServerStatus_server
  elif [[ ${server_num} == "2" ]]; then
    Del_ServerStatus_server
  elif [[ ${server_num} == "3" ]]; then
    Modify_ServerStatus_server_username
  elif [[ ${server_num} == "4" ]]; then
    Modify_ServerStatus_server_password
  elif [[ ${server_num} == "5" ]]; then
    Modify_ServerStatus_server_name
  elif [[ ${server_num} == "6" ]]; then
    Modify_ServerStatus_server_type
  elif [[ ${server_num} == "7" ]]; then
    Modify_ServerStatus_server_location
  elif [[ ${server_num} == "8" ]]; then
    Modify_ServerStatus_server_region
  elif [[ ${server_num} == "9" ]]; then
    Modify_ServerStatus_server_all
  elif [[ ${server_num} == "10" ]]; then
    Modify_ServerStatus_server_disabled
  elif [[ ${server_num} == "11" ]]; then
    Read_config_server
    Set_server_port
    Write_server_config_conf
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鏁板瓧[1-11]" && exit 1
  fi
  Restart_ServerStatus_server
}
List_ServerStatus_server() {
  conf_text=$(${jq_file} '.servers' ${server_conf} | ${jq_file} ".[]|.username" | sed 's/\"//g')
  conf_text_total=$(echo -e "${conf_text}" | wc -l)
  [[ ${conf_text_total} == "0" ]] && echo -e "${Error} 娌℃湁鍙戠幇 涓€涓妭鐐归厤缃紝璇锋鏌?!" && exit 1
  conf_text_total_a=$((conf_text_total - 1))
  conf_list_all=""
  for ((integer = 0; integer <= conf_text_total_a; integer++)); do
    now_text=$(${jq_file} '.servers' ${server_conf} | ${jq_file} ".[${integer}]" | sed 's/\"//g;s/,$//g' | sed '$d;1d')
    now_text_username=$(echo -e "${now_text}" | grep "username" | awk -F ": " '{print $2}')
    now_text_password=$(echo -e "${now_text}" | grep "password" | awk -F ": " '{print $2}')
    now_text_name=$(echo -e "${now_text}" | grep "name" | grep -v "username" | awk -F ": " '{print $2}')
    now_text_type=$(echo -e "${now_text}" | grep "type" | awk -F ": " '{print $2}')
    now_text_location=$(echo -e "${now_text}" | grep "location" | awk -F ": " '{print $2}')
    now_text_region=$(echo -e "${now_text}" | grep "region" | awk -F ": " '{print $2}')
    now_text_disabled=$(echo -e "${now_text}" | grep "disabled" | awk -F ": " '{print $2}')
    if [[ ${now_text_disabled} == "false" ]]; then
      now_text_disabled_status="${Green_font_prefix}鍚敤${Font_color_suffix}"
    else
      now_text_disabled_status="${Red_font_prefix}绂佺敤${Font_color_suffix}"
    fi
    conf_list_all=${conf_list_all}"鐢ㄦ埛鍚? ${Green_font_prefix}${now_text_username}${Font_color_suffix} 瀵嗙爜: ${Green_font_prefix}${now_text_password}${Font_color_suffix} 鑺傜偣鍚? ${Green_font_prefix}${now_text_name}${Font_color_suffix} 绫诲瀷: ${Green_font_prefix}${now_text_type}${Font_color_suffix} 浣嶇疆: ${Green_font_prefix}${now_text_location}${Font_color_suffix} 鍖哄煙: ${Green_font_prefix}${now_text_region}${Font_color_suffix} 鐘舵€? ${Green_font_prefix}${now_text_disabled_status}${Font_color_suffix}\n"
  done
  echo && echo -e "鑺傜偣鎬绘暟 ${Green_font_prefix}${conf_text_total}${Font_color_suffix}"
  echo -e "${conf_list_all}"
}
Add_ServerStatus_server() {
  Set_config_server
  Set_username_ch=$(grep '"username": "'"${username_s}"'"' ${server_conf})
  [[ -n "${Set_username_ch}" ]] && echo -e "${Error} 鐢ㄦ埛鍚嶅凡琚娇鐢?!" && exit 1
  sed -i '3i\  },' ${server_conf}
  sed -i '3i\   "region": "'"${region_s}"'"' ${server_conf}
  sed -i '3i\   "disabled": false ,' ${server_conf}
  sed -i '3i\   "location": "'"${location_s}"'",' ${server_conf}
  sed -i '3i\   "host": "'"None"'",' ${server_conf}
  sed -i '3i\   "type": "'"${type_s}"'",' ${server_conf}
  sed -i '3i\   "name": "'"${name_s}"'",' ${server_conf}
  sed -i '3i\   "password": "'"${password_s}"'",' ${server_conf}
  sed -i '3i\   "username": "'"${username_s}"'",' ${server_conf}
  sed -i '3i\  {' ${server_conf}
  echo -e "${Info} 娣诲姞鑺傜偣鎴愬姛 ${Green_font_prefix}[ 鑺傜偣鍚嶇О: ${name_s}, 鑺傜偣鐢ㄦ埛鍚? ${username_s}, 鑺傜偣瀵嗙爜: ${password_s} ]${Font_color_suffix} !"
}
Del_ServerStatus_server() {
  List_ServerStatus_server
  [[ "${conf_text_total}" == "1" ]] && echo -e "${Error} 鑺傜偣閰嶇疆浠呭墿 1涓紝涓嶈兘鍒犻櫎 !" && exit 1
  echo -e "璇疯緭鍏ヨ鍒犻櫎鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" del_server_username
  [[ -z "${del_server_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  del_username=$(cat -n ${server_conf} | grep '"username": "'"${del_server_username}"'"' | awk '{print $1}')
  if [[ -n ${del_username} ]]; then
    del_username_min=$((del_username - 1))
    del_username_max=$((del_username + 8))
    del_username_max_text=$(sed -n "${del_username_max}p" ${server_conf})
    del_username_max_text_last=${del_username_max_text:((${#del_username_max_text} - 1))}
    if [[ ${del_username_max_text_last} != "," ]]; then
      del_list_num=$((del_username_min - 1))
      sed -i "${del_list_num}s/,$//g" ${server_conf}
    fi
    sed -i "${del_username_min},${del_username_max}d" ${server_conf}
    echo -e "${Info} 鑺傜偣鍒犻櫎鎴愬姛 ${Green_font_prefix}[ 鑺傜偣鐢ㄦ埛鍚? ${del_server_username} ]${Font_color_suffix} "
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_username() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_username
    Set_username_ch=$(grep '"username": "'"${username_s}"'"' ${server_conf})
    [[ -n "${Set_username_ch}" ]] && echo -e "${Error} 鐢ㄦ埛鍚嶅凡琚娇鐢?!" && exit 1
    sed -i "${Set_username_num}"'s/"username": "'"${manually_username}"'"/"username": "'"${username_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熻妭鐐圭敤鎴峰悕: ${manually_username}, 鏂拌妭鐐圭敤鎴峰悕: ${username_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_password() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_password
    Set_password_num_a=$((Set_username_num + 1))
    Set_password_num_text=$(sed -n "${Set_password_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_password_num_a}"'s/"password": "'"${Set_password_num_text}"'"/"password": "'"${password_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熻妭鐐瑰瘑鐮? ${Set_password_num_text}, 鏂拌妭鐐瑰瘑鐮? ${password_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_name() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_name
    Set_name_num_a=$((Set_username_num + 2))
    Set_name_num_a_text=$(sed -n "${Set_name_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_name_num_a}"'s/"name": "'"${Set_name_num_a_text}"'"/"name": "'"${name_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熻妭鐐瑰悕绉? ${Set_name_num_a_text}, 鏂拌妭鐐瑰悕绉? ${name_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_type() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_type
    Set_type_num_a=$((Set_username_num + 3))
    Set_type_num_a_text=$(sed -n "${Set_type_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_type_num_a}"'s/"type": "'"${Set_type_num_a_text}"'"/"type": "'"${type_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熻妭鐐硅櫄鎷熷寲: ${Set_type_num_a_text}, 鏂拌妭鐐硅櫄鎷熷寲: ${type_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_location() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_location
    Set_location_num_a=$((Set_username_num + 5))
    Set_location_num_a_text=$(sed -n "${Set_location_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_location_num_a}"'s/"location": "'"${Set_location_num_a_text}"'"/"location": "'"${location_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熻妭鐐逛綅缃? ${Set_location_num_a_text}, 鏂拌妭鐐逛綅缃? ${location_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_region() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_region
    Set_region_num_a=$((Set_username_num + 7))
    Set_region_num_a_text=$(sed -n "${Set_region_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_region_num_a}"'s/"region": "'"${Set_region_num_a_text}"'"/"region": "'"${region_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熻妭鐐瑰湴鍖? ${Set_region_num_a_text}, 鏂拌妭鐐瑰湴鍖? ${region_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_all() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_username
    Set_password
    Set_name
    Set_type
    Set_location
    Set_region
    sed -i "${Set_username_num}"'s/"username": "'"${manually_username}"'"/"username": "'"${username_s}"'"/g' ${server_conf}
    Set_password_num_a=$((Set_username_num + 1))
    Set_password_num_text=$(sed -n "${Set_password_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_password_num_a}"'s/"password": "'"${Set_password_num_text}"'"/"password": "'"${password_s}"'"/g' ${server_conf}
    Set_name_num_a=$((Set_username_num + 2))
    Set_name_num_a_text=$(sed -n "${Set_name_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_name_num_a}"'s/"name": "'"${Set_name_num_a_text}"'"/"name": "'"${name_s}"'"/g' ${server_conf}
    Set_type_num_a=$((Set_username_num + 3))
    Set_type_num_a_text=$(sed -n "${Set_type_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_type_num_a}"'s/"type": "'"${Set_type_num_a_text}"'"/"type": "'"${type_s}"'"/g' ${server_conf}
    Set_location_num_a=$((Set_username_num + 5))
    Set_location_num_a_text=$(sed -n "${Set_location_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_location_num_a}"'s/"location": "'"${Set_location_num_a_text}"'"/"location": "'"${location_s}"'"/g' ${server_conf}
    Set_region_num_a=$((Set_username_num + 7))
    Set_region_num_a_text=$(sed -n "${Set_region_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    sed -i "${Set_region_num_a}"'s/"region": "'"${Set_region_num_a_text}"'"/"region": "'"${region_s}"'"/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛銆?
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Modify_ServerStatus_server_disabled() {
  List_ServerStatus_server
  echo -e "璇疯緭鍏ヨ淇敼鐨勮妭鐐圭敤鎴峰悕"
  read -erp "(榛樿: 鍙栨秷):" manually_username
  [[ -z "${manually_username}" ]] && echo -e "宸插彇娑?.." && exit 1
  Set_username_num=$(cat -n ${server_conf} | grep '"username": "'"${manually_username}"'"' | awk '{print $1}')
  if [[ -n ${Set_username_num} ]]; then
    Set_disabled_num_a=$((Set_username_num + 6))
    Set_disabled_num_a_text=$(sed -n "${Set_disabled_num_a}p" ${server_conf} | sed 's/\"//g;s/,$//g' | awk -F ": " '{print $2}')
    if [[ ${Set_disabled_num_a_text} == "false" ]]; then
      disabled_s="true"
    else
      disabled_s="false"
    fi
    sed -i "${Set_disabled_num_a}"'s/"disabled": '"${Set_disabled_num_a_text}"'/"disabled": '"${disabled_s}"'/g' ${server_conf}
    echo -e "${Info} 淇敼鎴愬姛 [ 鍘熺鐢ㄧ姸鎬? ${Set_disabled_num_a_text}, 鏂扮鐢ㄧ姸鎬? ${disabled_s} ]"
  else
    echo -e "${Error} 璇疯緭鍏ユ纭殑鑺傜偣鐢ㄦ埛鍚?!" && exit 1
  fi
}
Set_ServerStatus_client() {
  check_installed_client_status
  Set_config_client
  Read_config_client
  Modify_config_client
  Restart_ServerStatus_client
}
Install_vnStat() {
  if [[ ${release} == "archlinux" ]]; then
    pacman -Sy vnstat --noconfirm
    systemctl enable vnstat
    systemctl start vnstat
    return 0
  elif [[ ${release} == "centos" ]]; then
    yum makecache
    yum -y install sqlite sqlite-devel
    yum -y groupinstall "Development Tools"
  elif [[ ${release} == "debian" ]]; then
    apt -y update
    apt -y install sqlite3 libsqlite3-dev build-essential
  fi
  cd "/tmp" || return 1
  wget --no-check-certificate https://humdi.net/vnstat/vnstat-latest.tar.gz
  tar zxvf vnstat-latest.tar.gz
  cd vnstat-*/ || return 1
  ./configure --prefix=/usr --sysconfdir=/etc && make && make install
  if ! vnstat -v >/dev/null 2>&1; then
    echo "缂栬瘧瀹夎vnStat澶辫触锛岃鎵嬪姩瀹夎vnStat"
    exit 1
  fi
  vnstatd -d
  if [[ ${release} == "centos" ]]; then
    if grep "6\..*" /etc/redhat-release | grep -i "centos" | grep -v "{^6}\.6" >/dev/null; then
      [[ ! -e /etc/init.d/vnstat ]] && cp examples/init.d/redhat/vnstat /etc/init.d/
      chkconfig vnstat on
      service vnstat restart
    fi
  else
    if grep -i "debian" /etc/issue | grep -q "7" || grep -i "ubuntu" /etc/issue | grep -q "14"; then
      [[ ! -e /etc/init.d/vnstat ]] && cp examples/init.d/debian/vnstat /etc/init.d/
      update-rc.d vnstat defaults
      service vnstat restart
    fi
  fi
  if [[ ! -e /etc/init.d/vnstat ]]; then
    cp -v examples/systemd/simple/vnstat.service /etc/systemd/system/
    systemctl enable vnstat
    systemctl start vnstat
  fi
  rm -rf vnstat*
  cd ~ || exit
}
Modify_config_client_traffic() {
  [ -z ${isVnstat} ] && [[ ${client_vnstat_s} == "false" ]] && return
  if [[ ${isVnstat="y"} == [Yy] ]]; then
    vnstat -v >/dev/null 2>&1 || Install_vnStat
    netName=$(awk '{i++; if( i>2 && ($2 != 0 && $10 != 0) ){print $1}}' /proc/net/dev | sed 's/^lo:$//g' | sed 's/^tun:$//g' | sed '/^$/d' | sed 's/^[\t]*//g' | sed 's/[:]*$//g')
    if [ -z "$netName" ]; then
      echo -e "鑾峰彇缃戝崱鍚嶇О澶辫触锛岃鍦℅ithub鍙嶉"
      exit 1
    fi
    if [[ $netName =~ [[:space:]] ]]; then
      read -erp "妫€娴嬪埌澶氫釜缃戝崱: ${netName}锛岃鎵嬪姩杈撳叆缃戝崱鍚嶇О" netName
    fi
    read -erp "璇疯緭鍏ユ瘡鏈堟祦閲忓綊闆剁殑鏃ユ湡(1~28)锛岄粯璁や负1(鍗虫瘡鏈?鏃?: " time_N
    [[ -z "$time_N" ]] && time_N="1"
    while ! [[ $time_N =~ ^[0-9]*$ ]] || ((time_N < 1 || time_N > 28)); do
      read -erp "浣犺緭鍏ョ殑鏃ユ湡涓嶅悎娉曪紝璇烽噸鏂拌緭鍏? " time_N
    done
    sed -i "s/$(grep -w "MonthRotate" /etc/vnstat.conf)/MonthRotate $time_N/" /etc/vnstat.conf
    sed -i "s/$(grep -w "Interface" /etc/vnstat.conf)/Interface \"$netName\"/" /etc/vnstat.conf
    chmod -R 777 /var/lib/vnstat/
    systemctl restart vnstat
    if ! grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" ${client_file}/status-client.py; then
      sed -i 's/\t/    /g' ${client_file}/status-client.py
      sed -i 's/NET_IN, NET_OUT = traffic.get_traffic()/NET_IN, NET_OUT = get_traffic_vnstat()/' ${client_file}/status-client.py
    fi
  elif grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" ${client_file}/status-client.py; then
    sed -i 's/\t/    /g' ${client_file}/status-client.py
    sed -i 's/NET_IN, NET_OUT = get_traffic_vnstat()/NET_IN, NET_OUT = traffic.get_traffic()/' ${client_file}/status-client.py
  fi
}
Modify_config_client() {
  sed -i 's/SERVER = "'"${client_server}"'"/SERVER = "'"${server_s}"'"/g' "${client_file}/status-client.py"
  sed -i "s/PORT = ${client_port}/PORT = ${server_port_s}/g" "${client_file}/status-client.py"
  sed -i 's/USER = "'"${client_user}"'"/USER = "'"${username_s}"'"/g' "${client_file}/status-client.py"
  sed -i 's/PASSWORD = "'"${client_password}"'"/PASSWORD = "'"${password_s}"'"/g' "${client_file}/status-client.py"
  Modify_config_client_traffic
}
Install_jq() {
  [[ ${mirror_num} == 2 ]] && {
    github_link="https://hub.fastgit.org"
    raw_link="https://raw.fastgit.org"
  } || {
    github_link="https://github.com"
    raw_link="https://raw.githubusercontent.com"
  }
  if [[ ! -e ${jq_file} ]]; then
    if [[ ${bit} == "x86_64" ]]; then
      jq_file="${file}/jq"
      wget --no-check-certificate "${github_link}/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
    elif [[ ${bit} == "i386" ]]; then
      jq_file="${file}/jq"
      wget --no-check-certificate "${github_link}/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
    else
      # ARM fallback to package manager
      [[ ${release} == "archlinux" ]] && pacman -Sy jq --noconfirm
      [[ ${release} == "centos" ]] && yum -y install jq
      [[ ${release} == "debian" ]] && apt -y install jq
      jq_file="/usr/bin/jq"
    fi
    [[ ! -e ${jq_file} ]] && echo -e "${Error} JQ瑙ｆ瀽鍣?涓嬭浇澶辫触锛岃妫€鏌?!" && exit 1
    chmod +x ${jq_file}
    echo -e "${Info} JQ瑙ｆ瀽鍣?瀹夎瀹屾垚锛岀户缁?.."
  else
    echo -e "${Info} JQ瑙ｆ瀽鍣?宸插畨瑁咃紝缁х画..."
  fi
  if [[ ! -e ${region_json} ]]; then
    wget --no-check-certificate "${raw_link}/michaelwittig/node-i18n-iso-countries/master/langs/zh.json" -O ${region_json}
    [[ ! -e ${region_json} ]] && echo -e "${Error} ISO 3166-1 json鏂囦欢涓嬭浇澶辫触锛岃妫€鏌ワ紒" && exit 1
  fi
}
Install_caddy() {
  echo
  echo -e "${Info} 鏄惁鐢辫剼鏈嚜鍔ㄩ厤缃瓾TTP鏈嶅姟(鏈嶅姟绔殑鍦ㄧ嚎鐩戞帶缃戠珯)锛屽鏋滈€夋嫨 N锛屽垯璇峰湪鍏朵粬HTTP鏈嶅姟涓厤缃綉绔欐牴鐩綍涓猴細${Green_font_prefix}${web_file}${Font_color_suffix} [Y/n]"
  read -erp "(榛樿: Y 鑷姩閮ㄧ讲):" caddy_yn
  [[ -z "$caddy_yn" ]] && caddy_yn="y"
  if [[ "${caddy_yn}" == [Yy] ]]; then
    caddy_file="/etc/caddy/Caddyfile" # Where is the default Caddyfile specified in Archlinux?
    [[ ! -e /usr/bin/caddy ]] && {
      # https://caddyserver.com/docs/install
      if [[ ${release} == "debian" ]]; then
        apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
        curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
        apt update && apt install caddy
      elif [[ ${release} == "centos" ]]; then
        yum install yum-plugin-copr -y
        yum copr enable @caddy/caddy -y
        yum install caddy -y
      elif [[ ${release} == "archlinux" ]]; then
        pacman -Sy caddy --noconfirm
      fi
      [[ ! -e "/usr/bin/caddy" ]] && echo -e "${Error} Caddy瀹夎澶辫触锛岃鎵嬪姩閮ㄧ讲锛學eb缃戦〉鏂囦欢浣嶇疆锛?{web_file}" && exit 1
      systemctl enable caddy
      echo "" >${caddy_file}
    }
    Set_server "server"
    Set_server_http_port
    cat >>${caddy_file} <<-EOF
http://${server_s}:${server_http_port_s} {
  root * ${web_file}
  encode gzip
  file_server
}
EOF
    systemctl restart caddy
  else
    echo -e "${Info} 璺宠繃 HTTP鏈嶅姟閮ㄧ讲锛岃鎵嬪姩閮ㄧ讲锛學eb缃戦〉鏂囦欢浣嶇疆锛?{web_file} 锛屽鏋滀綅缃敼鍙橈紝璇锋敞鎰忎慨鏀规湇鍔¤剼鏈枃浠?/etc/init.d/status-server 涓殑 WEB_BIN 鍙橀噺 !"
  fi
}
Install_ServerStatus_server() {
  Set_Mirror
  [[ -e "${server_file}/sergate" ]] && echo -e "${Error} 妫€娴嬪埌 ServerStatus 鏈嶅姟绔凡瀹夎 !" && exit 1
  Set_server_port
  echo -e "${Info} 寮€濮嬪畨瑁?閰嶇疆 渚濊禆..."
  Installation_dependency "server"
  Install_caddy
  echo -e "${Info} 寮€濮嬩笅杞?瀹夎..."
  Download_Server_Status_server
  Install_jq
  echo -e "${Info} 寮€濮嬩笅杞?瀹夎 鏈嶅姟鑴氭湰(init)..."
  Service_Server_Status_server
  echo -e "${Info} 寮€濮嬪啓鍏?閰嶇疆鏂囦欢..."
  Write_server_config
  Write_server_config_conf
  echo -e "${Info} 鎵€鏈夋楠?瀹夎瀹屾瘯锛屽紑濮嬪惎鍔?.."
  Start_ServerStatus_server
}
Install_ServerStatus_client() {
  Set_Mirror
  [[ -e "${client_file}/status-client.py" ]] && echo -e "${Error} 妫€娴嬪埌 ServerStatus 瀹㈡埛绔凡瀹夎 !" && exit 1
  check_sys
  echo -e "${Info} 寮€濮嬭缃?鐢ㄦ埛閰嶇疆..."
  Set_config_client
  echo -e "${Info} 寮€濮嬪畨瑁?閰嶇疆 渚濊禆..."
  Installation_dependency "client"
  echo -e "${Info} 寮€濮嬩笅杞?瀹夎..."
  Download_Server_Status_client
  echo -e "${Info} 寮€濮嬩笅杞?瀹夎 鏈嶅姟鑴氭湰(init)..."
  Service_Server_Status_client
  echo -e "${Info} 寮€濮嬪啓鍏?閰嶇疆..."
  Read_config_client
  Modify_config_client
  echo -e "${Info} 鎵€鏈夋楠?瀹夎瀹屾瘯锛屽紑濮嬪惎鍔?.."
  Start_ServerStatus_client
}
Update_ServerStatus_server() {
  Set_Mirror
  check_installed_server_status
  check_pid_server
  [[ -n ${PID} ]] && systemctl stop status-server.service
  Download_Server_Status_server
  rm -rf /etc/init.d/status-server
  Service_Server_Status_server
  Start_ServerStatus_server
}
Update_ServerStatus_client() {
  Set_Mirror
  check_installed_client_status
  check_pid_client
  if [[ -n ${PID} ]]; then
    if [[ ${release} == "archlinux" ]]; then
      systemctl stop status-client
    else
      /etc/init.d/status-client stop
    fi
  fi
  if [[ ! -e "${client_file}/status-client.py" ]]; then
    if [[ ! -e "${file}/status-client.py" ]]; then
      echo -e "${Error} ServerStatus 瀹㈡埛绔枃浠朵笉瀛樺湪 !" && exit 1
    else
      client_text="$(sed 's/\"//g;s/,//g;s/ //g' "${file}/status-client.py")"
      rm -rf "${file}/status-client.py"
    fi
  else
    client_text="$(sed 's/\"//g;s/,//g;s/ //g' "${client_file}/status-client.py")"
  fi
  server_s="$(echo -e "${client_text}" | grep "SERVER=" | awk -F "=" '{print $2}')"
  server_port_s="$(echo -e "${client_text}" | grep "PORT=" | awk -F "=" '{print $2}')"
  username_s="$(echo -e "${client_text}" | grep "USER=" | awk -F "=" '{print $2}')"
  password_s="$(echo -e "${client_text}" | grep "PASSWORD=" | awk -F "=" '{print $2}')"
  grep -q "NET_IN, NET_OUT = get_traffic_vnstat()" "${client_file}/status-client.py" && client_vnstat_s="true" || client_vnstat_s="false"
  Download_Server_Status_client
  Read_config_client
  Modify_config_client
  rm -rf /etc/init.d/status-client
  Service_Server_Status_client
  Start_ServerStatus_client
}
Start_ServerStatus_server() {
  check_installed_server_status
  check_pid_server
  [[ -n ${PID} ]] && echo -e "${Error} ServerStatus 正在运行，请检查 !" && exit 1
  systemctl start status-server.service
}
Stop_ServerStatus_server() {
  check_installed_server_status
  check_pid_server
  [[ -z ${PID} ]] && echo -e "${Error} ServerStatus 没有运行，请检查 !" && exit 1
  systemctl stop status-server.service
}
Restart_ServerStatus_server() {
  check_installed_server_status
  check_pid_server
  [[ -n ${PID} ]] && systemctl stop status-server.service
  systemctl start status-server.service
}
Uninstall_ServerStatus_server() {
  check_installed_server_status
  echo "纭畾瑕佸嵏杞?ServerStatus 鏈嶅姟绔?濡傛灉鍚屾椂瀹夎浜嗗鎴风锛屽垯鍙細鍒犻櫎鏈嶅姟绔? ? [y/N]"
  echo
  read -erp "(榛樿: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  if [[ ${unyn} == [Yy] ]]; then
    check_pid_server
    [[ -n $PID ]] && kill -9 "${PID}"
    Read_config_server
    if [[ -e "${client_file}/status-client.py" ]]; then
      rm -rf "${server_file}"
      rm -rf "${web_file}"
    else
      rm -rf "${file}"
    fi
    rm -rf "/etc/init.d/status-server"
    if [[ -e "/usr/bin/caddy" ]]; then
      systemctl stop caddy
      systemctl disable caddy
      [[ ${release} == "debian" ]] && apt purge -y caddy
      [[ ${release} == "centos" ]] && yum -y remove caddy
      [[ ${release} == "archlinux" ]] && pacman -R caddy --noconfirm
    fi
    if [[ ${release} == "centos" ]]; then
      chkconfig --del status-server
    elif [[ ${release} == "debian" ]]; then
      update-rc.d -f status-server remove
    elif [[ ${release} == "archlinux" ]]; then
      systemctl stop status-server
      systemctl disable status-server
      rm /usr/lib/systemd/system/status-server.service
    fi
    echo && echo "ServerStatus 鍗歌浇瀹屾垚 !" && echo
  else
    echo && echo "鍗歌浇宸插彇娑?.." && echo
  fi
}
Start_ServerStatus_client() {
  check_installed_client_status
  check_pid_client
  [[ -n ${PID} ]] && echo -e "${Error} ServerStatus 姝ｅ湪杩愯锛岃妫€鏌?!" && exit 1
  if [[ ${release} == "archlinux" ]]; then
    systemctl start status-client.service
  else
    /etc/init.d/status-client start
  fi
}
Stop_ServerStatus_client() {
  check_installed_client_status
  check_pid_client
  [[ -z ${PID} ]] && echo -e "${Error} ServerStatus 娌℃湁杩愯锛岃妫€鏌?!" && exit 1
  if [[ ${release} == "archlinux" ]]; then
    systemctl stop status-client.service
  else
    /etc/init.d/status-client stop
  fi
}
Restart_ServerStatus_client() {
  check_installed_client_status
  check_pid_client
  if [[ -n ${PID} ]]; then
    if [[ ${release} == "archlinux" ]]; then
      systemctl restart status-client.service
    else
      /etc/init.d/status-client restart
    fi
  fi
}
Uninstall_ServerStatus_client() {
  check_installed_client_status
  echo "纭畾瑕佸嵏杞?ServerStatus 瀹㈡埛绔?濡傛灉鍚屾椂瀹夎浜嗘湇鍔＄锛屽垯鍙細鍒犻櫎瀹㈡埛绔? ? [y/N]"
  echo
  read -erp "(榛樿: n):" unyn
  [[ -z ${unyn} ]] && unyn="n"
  if [[ ${unyn} == [Yy] ]]; then
    check_pid_client
    [[ -n $PID ]] && kill -9 "${PID}"
    Read_config_client
    if [[ -e "${server_file}/sergate" ]]; then
      rm -rf "${client_file}"
    else
      rm -rf "${file}"
    fi
    rm -rf /etc/init.d/status-client
    if [[ ${release} == "centos" ]]; then
      chkconfig --del status-client
    elif [[ ${release} == "debian" ]]; then
      update-rc.d -f status-client remove
    elif [[ ${release} == "archlinux" ]]; then
      systemctl stop status-client
      systemctl disable status-client
      rm /usr/lib/systemd/system/status-client.service
    fi
    echo && echo "ServerStatus 鍗歌浇瀹屾垚 !" && echo
  else
    echo && echo "鍗歌浇宸插彇娑?.." && echo
  fi
}
View_ServerStatus_client() {
  check_installed_client_status
  Read_config_client
  clear && echo "鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? && echo
  echo -e "  ServerStatus 瀹㈡埛绔厤缃俊鎭細

  IP \t: ${Green_font_prefix}${client_server}${Font_color_suffix}
  绔彛 \t: ${Green_font_prefix}${client_port}${Font_color_suffix}
  璐﹀彿 \t: ${Green_font_prefix}${client_user}${Font_color_suffix}
  瀵嗙爜 \t: ${Green_font_prefix}${client_password}${Font_color_suffix}
  vnStat : ${Green_font_prefix}${client_vnstat}${Font_color_suffix}

鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€?
}
View_client_Log() {
  [[ ! -e ${client_log_file} ]] && echo -e "${Error} 娌℃湁鎵惧埌鏃ュ織鏂囦欢 !" && exit 1
  echo && echo -e "${Tip} 鎸?${Red_font_prefix}Ctrl+C${Font_color_suffix} 缁堟鏌ョ湅鏃ュ織" && echo -e "濡傛灉闇€瑕佹煡鐪嬪畬鏁存棩蹇楀唴瀹癸紝璇风敤 ${Red_font_prefix}cat ${client_log_file}${Font_color_suffix} 鍛戒护銆? && echo
  tail -f ${client_log_file}
}
View_server_Log() {
  [[ ! -e ${server_log_file} ]] && echo -e "${Error} 娌℃湁鎵惧埌鏃ュ織鏂囦欢 !" && exit 1
  echo && echo -e "${Tip} 鎸?${Red_font_prefix}Ctrl+C${Font_color_suffix} 缁堟鏌ョ湅鏃ュ織" && echo -e "濡傛灉闇€瑕佹煡鐪嬪畬鏁存棩蹇楀唴瀹癸紝璇风敤 ${Red_font_prefix}cat ${server_log_file}${Font_color_suffix} 鍛戒护銆? && echo
  tail -f ${server_log_file}
}
Update_Shell() {
  Set_Mirror
  sh_new_ver=$(wget --no-check-certificate -qO- -t1 -T3 "${link_prefix}/status.sh" | grep 'sh_ver="' | awk -F "=" '{print $NF}' | sed 's/\"//g' | head -1)
  [[ -z ${sh_new_ver} ]] && echo -e "${Error} 鏃犳硶閾炬帴鍒?Github !" && exit 0
  if [[ -e "/etc/init.d/status-client" ]] || [[ -e "/usr/lib/systemd/system/status-client.service" ]]; then
    rm -rf /etc/init.d/status-client
    rm -rf /usr/lib/systemd/system/status-client.service
    Service_Server_Status_client
  fi
  if [[ -e "/etc/init.d/status-server" ]] || [[ -e "/usr/lib/systemd/system/status-server.service" ]]; then
    rm -rf /etc/init.d/status-server
    rm -rf /usr/lib/systemd/system/status-server.service
    Service_Server_Status_server
  fi
  wget -N --no-check-certificate "${link_prefix}/status.sh" && chmod +x status.sh
  echo -e "鑴氭湰宸叉洿鏂颁负鏈€鏂扮増鏈琜 ${sh_new_ver} ] !(娉ㄦ剰锛氬洜涓烘洿鏂版柟寮忎负鐩存帴瑕嗙洊褰撳墠杩愯鐨勮剼鏈紝鎵€浠ュ彲鑳戒笅闈細鎻愮ず涓€浜涙姤閿欙紝鏃犺鍗冲彲)" && exit 0
}
menu_client() {
  echo && echo -e "  ServerStatus 涓€閿畨瑁呯鐞嗚剼鏈?${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Toyo | doub.io/shell-jc3 --
  --    Modified by APTX    --
 ${Green_font_prefix} 0.${Font_color_suffix} 鍗囩骇鑴氭湰
 鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 1.${Font_color_suffix} 瀹夎 瀹㈡埛绔? ${Green_font_prefix} 2.${Font_color_suffix} 鏇存柊 瀹㈡埛绔? ${Green_font_prefix} 3.${Font_color_suffix} 鍗歌浇 瀹㈡埛绔?鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 4.${Font_color_suffix} 鍚姩 瀹㈡埛绔? ${Green_font_prefix} 5.${Font_color_suffix} 鍋滄 瀹㈡埛绔? ${Green_font_prefix} 6.${Font_color_suffix} 閲嶅惎 瀹㈡埛绔?鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 7.${Font_color_suffix} 璁剧疆 瀹㈡埛绔厤缃? ${Green_font_prefix} 8.${Font_color_suffix} 鏌ョ湅 瀹㈡埛绔俊鎭? ${Green_font_prefix} 9.${Font_color_suffix} 鏌ョ湅 瀹㈡埛绔棩蹇?鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix}10.${Font_color_suffix} 鍒囨崲涓?鏈嶅姟绔彍鍗? && echo
  if [[ -e "${client_file}/status-client.py" ]]; then
    check_pid_client
    if [[ -n "${PID}" ]]; then
      echo -e " 褰撳墠鐘舵€? 瀹㈡埛绔?${Green_font_prefix}宸插畨瑁?{Font_color_suffix} 骞?${Green_font_prefix}宸插惎鍔?{Font_color_suffix}"
    else
      echo -e " 褰撳墠鐘舵€? 瀹㈡埛绔?${Green_font_prefix}宸插畨瑁?{Font_color_suffix} 浣?${Red_font_prefix}鏈惎鍔?{Font_color_suffix}"
    fi
  else
    if [[ -e "${file}/status-client.py" ]]; then
      check_pid_client
      if [[ -n "${PID}" ]]; then
        echo -e " 褰撳墠鐘舵€? 瀹㈡埛绔?${Green_font_prefix}宸插畨瑁?{Font_color_suffix} 骞?${Green_font_prefix}宸插惎鍔?{Font_color_suffix}"
      else
        echo -e " 褰撳墠鐘舵€? 瀹㈡埛绔?${Green_font_prefix}宸插畨瑁?{Font_color_suffix} 浣?${Red_font_prefix}鏈惎鍔?{Font_color_suffix}"
      fi
    else
      echo -e " 褰撳墠鐘舵€? 瀹㈡埛绔?${Red_font_prefix}鏈畨瑁?{Font_color_suffix}"
    fi
  fi
  echo
  read -erp " 璇疯緭鍏ユ暟瀛?[0-10]:" num
  case "$num" in
  0)
    Update_Shell
    ;;
  1)
    Install_ServerStatus_client
    ;;
  2)
    Update_ServerStatus_client
    ;;
  3)
    Uninstall_ServerStatus_client
    ;;
  4)
    Start_ServerStatus_client
    ;;
  5)
    Stop_ServerStatus_client
    ;;
  6)
    Restart_ServerStatus_client
    ;;
  7)
    Set_ServerStatus_client
    ;;
  8)
    View_ServerStatus_client
    ;;
  9)
    View_client_Log
    ;;
  10)
    menu_server
    ;;
  *)
    echo "璇疯緭鍏ユ纭暟瀛?[0-10]"
    ;;
  esac
}
menu_server() {
  echo && echo -e "  ServerStatus 涓€閿畨瑁呯鐞嗚剼鏈?${Red_font_prefix}[v${sh_ver}]${Font_color_suffix}
  -- Toyo | doub.io/shell-jc3 --
  --    Modified by APTX    --
 ${Green_font_prefix} 0.${Font_color_suffix} 鍗囩骇鑴氭湰
 鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 1.${Font_color_suffix} 瀹夎 鏈嶅姟绔? ${Green_font_prefix} 2.${Font_color_suffix} 鏇存柊 鏈嶅姟绔? ${Green_font_prefix} 3.${Font_color_suffix} 鍗歌浇 鏈嶅姟绔?鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 4.${Font_color_suffix} 鍚姩 鏈嶅姟绔? ${Green_font_prefix} 5.${Font_color_suffix} 鍋滄 鏈嶅姟绔? ${Green_font_prefix} 6.${Font_color_suffix} 閲嶅惎 鏈嶅姟绔?鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix} 7.${Font_color_suffix} 璁剧疆 鏈嶅姟绔厤缃? ${Green_font_prefix} 8.${Font_color_suffix} 鏌ョ湅 鏈嶅姟绔俊鎭? ${Green_font_prefix} 9.${Font_color_suffix} 鏌ョ湅 鏈嶅姟绔棩蹇?鈥斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€斺€? ${Green_font_prefix}10.${Font_color_suffix} 鍒囨崲涓?瀹㈡埛绔彍鍗? && echo
  if [[ -e "${server_file}/sergate" ]]; then
    check_pid_server
    if [[ -n "${PID}" ]]; then
      echo -e " 褰撳墠鐘舵€? 鏈嶅姟绔?${Green_font_prefix}宸插畨瑁?{Font_color_suffix} 骞?${Green_font_prefix}宸插惎鍔?{Font_color_suffix}"
    else
      echo -e " 褰撳墠鐘舵€? 鏈嶅姟绔?${Green_font_prefix}宸插畨瑁?{Font_color_suffix} 浣?${Red_font_prefix}鏈惎鍔?{Font_color_suffix}"
    fi
  else
    echo -e " 褰撳墠鐘舵€? 鏈嶅姟绔?${Red_font_prefix}鏈畨瑁?{Font_color_suffix}"
  fi
  echo
  read -erp " 璇疯緭鍏ユ暟瀛?[0-10]:" num
  case "$num" in
  0)
    Update_Shell
    ;;
  1)
    Install_ServerStatus_server
    ;;
  2)
    Update_ServerStatus_server
    ;;
  3)
    Uninstall_ServerStatus_server
    ;;
  4)
    Start_ServerStatus_server
    ;;
  5)
    Stop_ServerStatus_server
    ;;
  6)
    Restart_ServerStatus_server
    ;;
  7)
    Set_ServerStatus_server
    ;;
  8)
    List_ServerStatus_server
    ;;
  9)
    View_server_Log
    ;;
  10)
    menu_client
    ;;
  *)
    echo "璇疯緭鍏ユ纭暟瀛?[0-10]"
    ;;
  esac
}
Set_Mirror() {
  echo -e "${Info} 使用 GitHub 下载源：MJJSUN/ServerStatus-Hotaru"
  link_prefix=${github_prefix}
}
check_sys
action=$1
if [[ -n $action ]]; then
  if [[ $action == "s" ]]; then
    menu_server
  elif [[ $action == "c" ]]; then
    menu_client
  fi
else
  menu_client
fi





