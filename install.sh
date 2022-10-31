#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
White='\033[0;37m'
plain='\033[0m'
MIP2=$(wget -qO- ipv4.icanhazip.com)

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}خطا: ${plain} برای نصب باید بعنوان مدیر روت وارد شوید!\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red}System version not detected, please contact the script author!${plain}\n" && exit 1
fi

arch=$(arch)

if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
else
    arch="amd64"
    echo -e "${red}Failed to detect schema, use default schema: ${arch}${plain}"
fi

echo "Architecture: ${arch}"

if [ $(getconf WORD_BIT) != '32' ] && [ $(getconf LONG_BIT) != '64' ]; then
    echo "This software does not support 32-bit system (x86), please use 64-bit system (x86_64), if the detection is wrong, please contact the author"
    exit -1
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Please use CentOS 7 or later！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}Please use Ubuntu 16 or later！${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}Please use Debian 8 or later！${plain}\n" && exit 1
    fi
fi

install_base() {
    if [[ x"${release}" == x"centos" ]]; then
    yum update
        yum install wget curl tar -y
    else
    sudo apt-get update
        apt install wget curl tar -y
    fi
}

#This function will be called when user installed x-ui out of sercurity
config_after_install() {
        /usr/local/x-ui/x-ui setting -username  -password
        /usr/local/x-ui/x-ui setting -port
        systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
clear
echo -e "
${green}__________________________________________________________________________________${plain}
${green}__________________________________________________________________________________${plain}
${White} ___  _________   _____          _____                  ___________  ___   _   _  ${plain}
${White} |  \/  || ___ \ /  __ \        |_   _|                |_   _| ___ \/ _ \ | \ | | ${plain}
${green} | .  . || |_/ / | /  \/ ___ _ __ | |_   _ _ __ _   _    | | | |_/ / /_\ \|  \| | ${plain}
${White} | |\/| ||    /  | |    / _ \  _ \| | | | |  __| | | |   | | |    /|  _  ||     | ${plain}
${red} | |  | || |\ \  | \__/\  __/ | | | | |_| | |  | |_| |  _| |_| |\ \| | | || |\  | ${plain}
${White} \_|  |_/\_| \_|  \____/\___|_| |_\_/\__,_|_|   \__, |  \___/\_| \_\_| |_/\_| \_/ ${plain}
${White}                                                 __/ |                            ${plain}
${White}                                                |___/                             ${plain}
${red}__________________________________________________________________________________${plain}
${red}__________________________________________________________________________________${plain}"
        echo -e " "
        echo -e "x-ui - نمایش منوی مدیریت"
        echo -e "-------------------------------------------------------- "
        echo -e "https://t.me/x_ui_fa <=== گروه تلگرام ما"    
        echo -e "----------------------------------------------"
        echo -e "admin :نام کاربری پنل"
        echo -e "admin :رمز عبور پنل"
        echo -e "${green}$MIP2:54321 ${plain}"
#         fi
}

install_x-ui() {
    systemctl stop x-ui
    cd /usr/local/

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/MrCenTury/x-ui-fa/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red} نتوانست نسخه x-ui را شناسایی کند، ممکن است از محدودیت Github API فراتر رفته باشد، لطفاً بعداً دوباره امتحان کنید یا به صورت دستی نسخه x-ui را برای نصب مشخص کنید. ${plain}"
            exit 1
        fi
        echo -e "جدیدترین نسخه را شناسایی کرد x-ui: ${last_version}, نصب را شروع کنید"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-${arch}.tar.gz https://github.com/MrCenTury/x-ui-fa/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red} دانلود ناموفق بود x-ui, لطفا مطمئن شوید که سرور شما می تواند فایل Github را دانلود کند ${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/MrCenTury/x-ui-fa/releases/download/${last_version}/x-ui-linux-${arch}.tar.gz"
        echo -e "شروع به نصب کنید x-ui v$1"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-${arch}.tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red} دانلود ناموفق بود x-ui v$1, لطفا مطمئن شوید که این نسخه وجود دارد ${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/x-ui/ ]]; then
        rm /usr/local/x-ui/ -rf
    fi

    tar zxvf x-ui-linux-${arch}.tar.gz
    rm x-ui-linux-${arch}.tar.gz -f
    cd x-ui
    chmod +x x-ui bin/xray-linux-${arch}
    cp -f x-ui.service /etc/systemd/system/
    wget --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontent.com/MrCenTury/x-ui-fa/master/x-ui.sh
    chmod +x /usr/local/x-ui/x-ui.sh
    chmod +x /usr/bin/x-ui
    config_after_install
}

echo -e "${green}Start installation${plain}"
install_base
install_x-ui $1
