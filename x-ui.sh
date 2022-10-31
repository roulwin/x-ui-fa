#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
White='\033[0;37m'
plain='\033[0m'
MIP2=$(wget -qO- ipv4.icanhazip.com)

#Add some basic function here
function LOGD() {
    echo -e "${yellow}[DEG] $* ${plain}"
}

function LOGE() {
    echo -e "${red}[ERR] $* ${plain}"
}

function LOGI() {
    echo -e "${green}[INF] $* ${plain}"
}
# check root
[[ $EUID -ne 0 ]] && LOGE "خطا: باید بعنوان مدیر روت وارد شوید!\n" && exit 1

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
    LOGE "هیچ نسخه سیستمی شناسایی نشد، لطفاً با برنامه نویس اسکریپت تماس بگیرید!\n" && exit 1
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
        LOGE "Please use CentOS 7 or higher!\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        LOGE "Please use Ubuntu 16 or later!\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        LOGE "Please use Debian 8 or higher!\n" && exit 1
    fi
fi

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [default $2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "آیا میخواهید پنل دوباره راه اندازی شود؟" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
  sleep 3
  LOGI "خودکار هدایت میشوید..."
  show_menu
}

install() {
    bash <(curl -Ls https://raw.githubusercontent.com/MrCenTury/x-ui-fa/master/install.sh)
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
        else
            start 0
        fi
    fi
}

update() {
    confirm "این عملکرد باعث می شود که آخرین نسخه بدون از دست دادن داده ها دوباره نصب شود. می خواهید ادامه دهید؟" "(n)"
    if [[ $? != 0 ]]; then
        LOGE "Cancelled"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    bash <(curl -Ls https://raw.githubusercontent.com/MrCenTury/x-ui-fa/master/install.sh)
    if [[ $? == 0 ]]; then
        LOGI "به روز رسانی کامل شد، پنل به طور خودکار راه اندازی مجدد شد"
        exit 0
    fi
}

uninstall() {
    confirm "آیا میخواهید پنل را بطور کل حذف کنید؟?" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop x-ui
    systemctl disable x-ui
    rm /etc/systemd/system/x-ui.service -f
    systemctl daemon-reload
    systemctl reset-failed
    rm /etc/x-ui/ -rf
    rm /usr/local/x-ui/ -rf
    rm /usr/bin/x-ui -f
    
    echo ""
    echo -e "${green} اسکریپت با موفقیت حذف شد${plain}"
    echo ""

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

reset_user() {
    confirm "آیا مطمئن هستید که می خواهید نام کاربری و رمز عبور را به پیشفرض بازنشانی کنید؟" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/x-ui/x-ui setting -username admin -password admin
    echo -e "درحال راه اندازی مجدد ${plain}"
            systemctl restart x-ui
    echo -e "نام کاربری و رمز عبور بازنشانی شد ${plain}"
    echo -e "نام کاربری و رمز عبور شما : ${green}admin${plain}"
#     confirm_restart
}

reset_config() {
    confirm "آیا مطمئن هستید که می خواهید تمام تنظیمات پنل را بازنشانی کنید، داده های حساب از بین نمی روند، نام کاربری و رمز عبور تغییر نمی کنند؟" "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/x-ui/x-ui setting -reset
    echo -e "درحال راه اندازی مجدد ${plain}"
            systemctl restart x-ui
        clear
    echo -e "تمام تنظیمات پنل به حالت پیش فرض بازنشانی شده است ${plain}"
    echo -e "نام کاربری و رمز عبور شما : ${green}admin${plain}"
    echo -e "پورت پنل شما : ${green}54321${plain}"
# confirm_restart
}

check_config() {
    info=$(/usr/local/x-ui/x-ui setting -show true)
    if [[ $? != 0 ]]; then
        LOGE "خطا: تنظیمات فعلی را دریافت کنید، لطفا خطاهای مربوطه را بررسی کنید"
        show_menu
    fi
    LOGI "${info}"
}

set_port() {
    echo && echo -n -e "شماره پورت ورودی از 1 تا 65535 باید باشد [1-65535]: " && read port
    if [[ -z "${port}" ]]; then
        LOGD "لغو شد"
        before_show_menu
    else
        /usr/local/x-ui/x-ui setting -port ${port}
        echo -e "درحال راه اندازی مجدد ${plain}"
                systemctl restart x-ui
            clear
        echo -e "پورت تنظیم شد، از پورت تازه تنظیم شده استفاده کنید ${green}${plain}"
        echo -e "پورت پنل شما : ${green}${port}${plain}"
#         confirm_restart
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        LOGI "پنل از قبل در حال اجرا است، اگر می خواهید دوباره راه اندازی کنید، نیازی به راه اندازی مجدد نیست لطفا پنل را ریستارت کنید"
    else
        systemctl start x-ui
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            LOGI "پنل با موفقیت اجرا شد"
        else
        LOGE "پنل شروع به کار نکرد، احتمالاً به این دلیل که زمان راه اندازی بیش از دو ثانیه است، لطفاً اطلاعات گزارش را بعداً بررسی کنید"        
        fi
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    check_status
    if [[ $? == 1 ]]; then
        echo ""
        LOGI "پنل متوقف شده است، نیازی به توقف مجدد نیست"
    else
        systemctl stop x-ui
        sleep 2
        check_status
        if [[ $? == 1 ]]; then
            LOGI "x-ui و xray با موفقیت متوقف شدند"
        else
            LOGE "پنل متوقف نشد، احتمالاً به این دلیل که توقف بیش از دو ثانیه طول کشید، لطفاً اطلاعات گزارش را بعداً بررسی کنید"        
        fi
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    systemctl restart x-ui
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        LOGI "پنل  با موفقیت راه اندازی مجدد شد"
    else
        LOGE "راه اندازی مجدد پنل انجام نشد، احتمالاً به این دلیل که زمان راه اندازی بیش از دو ثانیه است، لطفاً اطلاعات گزارش را بعداً بررسی کنید"    
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    systemctl status x-ui -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    systemctl enable x-ui
    if [[ $? == 0 ]]; then
        LOGI  "پنل با موفقیت تنظیم بوت خودکار شد"
    else
        LOGE "بوت خودکار انجام نشد"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    systemctl disable x-ui
    if [[ $? == 0 ]]; then
        LOGI "راه اندازی خودکار لغو شده با موفقیت انجام شد"
    else
        LOGE "شروع خودکار بوت لغو نشد"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    journalctl -u x-ui.service -e --no-pager -f
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

backup() {
    systemctl stop x-ui
    DIR="/root/backup-x/"
    if [ -d "$DIR" ]; then
        cp /etc/x-ui/x-ui.db /root/backup-x/backup.db
            systemctl start x-ui
    else
        mkdir /root/backup-x
        cp /etc/x-ui/x-ui.db /root/backup-x/backup.db
            systemctl start x-ui
    fi
    LOGI "بکاپ با موفقیت ایجاد شد." && before_show_menu
        before_show_menu
}

recovery() {
    systemctl stop x-ui
    FILE="/root/backup-x/backup.db"
    if test -f "$FILE"; then
        cp /root/backup-x/backup.db /etc/x-ui/x-ui.db
          systemctl start x-ui        
            LOGI "اطلاعات بازیابی مجدد شد." && before_show_menu
    else
        LOGE "فایل بکاپ یافت نشد!"
            systemctl start x-ui
            before_show_menu
    fi
}

domain() {
   clear
     read -p "لینک دامین را وارد کنید": method
     clear
    if [ "${method}" == " " ]; then
        LOGE "ورودی نامعتبر است، لطفا ورودی خود را بررسی کنید..."
        before_show_menu
    else
        ~/.acme.sh/acme.sh --renew -d ${method} --force
        before_show_menu
    fi
}

install_bbr() {
    # temporary workaround for installing bbr
    bash <(curl -L -s https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)
    echo ""
    before_show_menu
}

update_shell() {
    wget -O /usr/bin/x-ui -N --no-check-certificate https://github.com/MrCenTury/x-ui-fa/raw/master/x-ui.sh
    if [[ $? != 0 ]]; then
        echo ""
        LOGE "اسکریپت دانلود نشد، لطفاً بررسی کنید که آیا سرور شما می‌تواند به گیت هاب متصل شود"
        before_show_menu
    else
        chmod +x /usr/bin/x-ui
        LOGI "ارتقاء اسکریپت با موفقیت انجام شد، لطفاً اسکریپت را دوباره اجرا کنید" && exit 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /etc/systemd/system/x-ui.service ]]; then
        return 2
    fi
    temp=$(systemctl status x-ui | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

check_enabled() {
    temp=$(systemctl is-enabled x-ui)
    if [[ x"${temp}" == x"enabled" ]]; then
        return 0
    else
        return 1
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        LOGE "پنل قبلا نصب شده است، لطفا دیگر نصب نکنید"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        LOGE "لطفا ابتدا پنل را نصب کنید"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
    0)
        echo -e "وضعیت پنل:${green}در حال اجرا${plain}"
        show_enable_status
        ;;
    1)
        echo -e "وضعیت پنل:${yellow}در حال اجرا نیست${plain}"
        show_enable_status
        ;;
    2)
        echo -e "وضعیت پنل:${red}نصب نشده${plain}"
        ;;
    esac
    show_xray_status
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "شروع خودکار در هنگام بوت:${green}بله${plain}"
    else
        echo -e "شروع خودکار در هنگام بوت:${red}خیر${plain}"
    fi
}

check_xray_status() {
    count=$(ps -ef | grep "xray-linux" | grep -v "grep" | wc -l)
    if [[ count -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

show_xray_status() {
    check_xray_status
    if [[ $? == 0 ]]; then
        echo -e "وضعیت پروکسی:${green}در حال اجرا${plain}"
    else
        echo -e "وضعیت پروکسی:${red}در حال اجرا نیست${plain}"
    fi
}

ssl_cert_issue() {
    local method=""
    echo -E ""
   clear
   LOGD "*******دستورالعمل ها*******"
     LOGI "1: حالت ربات"
     LOGI "2: حالت کلودفلر"
     LOGI "-----------------------------------------------"     
     LOGI "اگر نام دامنه یک نام دامنه رایگان است، توصیه می شود از روش 1 برای اعمال استفاده کنید"
     LOGI "در غیر این صورت پیشنهاد میشود از روش دوم استفاده کنید"
     LOGI "-----------------------------------------------"     
     
     read -p "عدد انتخابی را وارد کنید (1 یا 2)": method
     clear
    if [ "${method}" == "1" ]; then
        ssl_cert_issue_standalone
    elif [ "${method}" == "2" ]; then
        ssl_cert_issue_by_cloudflare
    else
        LOGE "ورودی نامعتبر است، لطفا ورودی خود را بررسی کنید..."
        exit 1
        clear
    fi
}

install_acme() {
    clear
    cd ~
    LOGI "شروع به نصب اسکریپت ربات ..."
    curl https://get.acme.sh | sh
    if [ $? -ne 0 ]; then
        LOGE "نصب ناموفق بود"
        return 1
    else
        LOGI "نصب با موفقیت انجام شد"
    fi
    return 0
}

#method for standalone mode
ssl_cert_issue_standalone() {
    #install acme first
    install_acme
    if [ $? -ne 0 ]; then
        LOGE "نصب ممکن نیست، لطفاً گزارش خطا را بررسی کنید"
        exit 1
    fi
    #install socat second
    if [[ x"${release}" == x"centos" ]]; then
        yum install socat -y
    else
        apt install socat -y
    fi
    if [ $? -ne 0 ]; then
        LOGE "نصب سوکت ممکن نیست، لطفا گزارش خطا را بررسی کنید"
        exit 1
    else
        LOGI "سوکت با موفقیت نصب شد"
    fi
    #create a directory for install cert
    certPath=/root/cert
    if [ ! -d "$certPath" ]; then
        mkdir $certPath
    else
        rm -rf $certPath
        mkdir $certPath
    fi
    #get the domain here, and we need verify it
    local domain=""
    read -p "نام دامین یا ساب دامین خود را وارد کنید:" domain
    LOGD "اعتبار نامه دامنه  ${domain} در حال بررسی است..."
    #here we need to judge whether there exists cert already
    local currentCert=$(~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}')
    if [ ${currentCert} == ${domain} ]; then
        local certInfo=$(~/.acme.sh/acme.sh --list)
        LOGE "تأیید اعتبار نام دامنه انجام نشد. محیط فعلی از قبل دارای گواهی نام دامنه مربوطه است و برنامه قابل تکرار نیست. جزئیات گواهی فعلی:"
        LOGI "$certInfo"
        exit 1
    else
        LOGI "بررسی اعتبار دامنه تایید شد."
    fi
    #get needed port here
    local WebPort=80
    read -p "لطفا پورتی را که می خواهید استفاده کنید وارد کنید، اگر اینتر را فشار دهید، پورت پیش فرض 80 استفاده می شود:" WebPort
    if [[ ${WebPort} -gt 65535 || ${WebPort} -lt 1 ]]; then
        LOGE "پورت ${WebPort} انتخابی شما نامعتبر است، پورت پیش فرض 80 برای برنامه استفاده خواهد شد"
    fi
    LOGI "باز است ${WebPort} برای درخواست گواهی، لطفا مطمئن شوید که پورت باز است..."
    #NOTE:This should be handled by user
    #open the port and kill the occupied progress
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    ~/.acme.sh/acme.sh --issue -d ${domain} --standalone --httpport ${WebPort}
    if [ $? -ne 0 ]; then
        LOGE "درخواست گواهی ناموفق بود، لطفاً به پیام خطا مراجعه کنید"
        rm -rf ~/.acme.sh/${domain}
        exit 1
    else
        LOGI "برنامه گواهی موفقیت آمیز بود، نصب گواهی را شروع کنید..."
    fi
    #install cert
    ~/.acme.sh/acme.sh --installcert -d ${domain} --ca-file /root/cert/ca.cer \
    --cert-file /root/cert/${domain}.cer --key-file /root/cert/${domain}.key \
    --fullchain-file /root/cert/fullchain.cer

    if [ $? -ne 0 ]; then
        LOGE "نصب گواهی انجام نشد"
        rm -rf ~/.acme.sh/${domain}
        exit 1
    else
        LOGI "گواهی با موفقیت نصب شد، به‌روزرسانی خودکار را فعال میشود..."
    fi
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade
    if [ $? -ne 0 ]; then
        LOGE "تنظیمات به‌روزرسانی خودکار انجام نشد"
        ls -lah cert
        chmod 755 $certPath
        exit 1
    else
        LOGI "گواهی نصب شده و به روز رسانی خودکار روشن است، جزئیات به شرح زیر است"
        ls -lah cert
        chmod 755 $certPath
    fi

}

#method for DNS API mode
ssl_cert_issue_by_cloudflare() {
clear
    echo -E ""
    LOGD "*******دستورالعمل ها*******"
     LOGI "1. آدرس ایمیل ثبت شده کلودفلر را بشناسید"
     LOGI "2. کلید وب سرویس جهانی کلودفلر را بشناسید"
     LOGI "3. نام دامنه به سرور فعلی از طریق کلودفلر حل شده است"
     LOGI "4. مسیر نصب پیش فرض این اسکریپت برای درخواست گواهی"
     confirm "موارد بالا را تایید میکنم [y/n]" "y"
    if [ $? -eq 0 ]; then
        install_acme
        if [ $? -ne 0 ]; then
            LOGE "نصب ممکن نیست، لطفاً گزارش خطا را بررسی کنید"
            exit 1
        fi
        CF_Domain=""
        CF_GlobalKey=""
        CF_AccountEmail=""
        certPath=/root/cert
        if [ ! -d "$certPath" ]; then
            mkdir $certPath
        else
            rm -rf $certPath
            mkdir $certPath
        fi
        LOGD "لطفا نام دامنه را تنظیم کنید :"
        read -p "دامنه خود را در اینجا وارد کنید :" CF_Domain
        LOGD "...در حال انجام است ${CF_Domain} تأیید اعتبار دامنه"
        #here we need to judge whether there exists cert already
        local currentCert=$(~/.acme.sh/acme.sh --list | tail -1 | awk '{print $1}')
        if [ ${currentCert} == ${CF_Domain} ]; then
            local certInfo=$(~/.acme.sh/acme.sh --list)
            LOGE "تأیید اعتبار نام دامنه ناموفق بود. محیط فعلی از قبل دارای گواهی نام دامنه مربوطه است و برنامه قابل تکرار نیست. جزئیات گواهی فعلی:"
            LOGI "$certInfo"
            exit 1
        else
            LOGI "بررسی اعتبار دامنه تایید شد..."
        fi
#         LOGD "لطفا کلید را تنظیم کنید:"
        read -p "کلید خود را اینجا وارد کنید:" CF_GlobalKey
#         LOGD "Your API key is: ${CF_GlobalKey}"
#         LOGD "Please set the registered email address:"
        read -p "لطفا آدرس ایمیل ثبت شده را تنظیم کنید:" CF_AccountEmail
#         LOGD "Your registered email address is: ${CF_AccountEmail}"
        ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
        if [ $? -ne 0 ]; then
            LOGE "تغییر کلید پیش‌فرض به صورت رمزنگاری انجام نشد"
            exit 1
        fi
        export CF_Key="${CF_GlobalKey}"
        export CF_Email=${CF_AccountEmail}
        ~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CF_Domain} -d *.${CF_Domain} --log
        if [ $? -ne 0 ]; then
            LOGE "صدور گواهی انجام نشد"
            rm -rf ~/.acme.sh/${CF_Domain}
            exit 1
        else
            LOGI "گواهی با موفقیت صادر شد، در حال نصب..."
        fi
        ~/.acme.sh/acme.sh --installcert -d ${CF_Domain} -d *.${CF_Domain} --ca-file /root/cert/ca.cer \
        --cert-file /root/cert/${CF_Domain}.cer --key-file /root/cert/${CF_Domain}.key \
        --fullchain-file /root/cert/fullchain.cer
        if [ $? -ne 0 ]; then
            LOGE "نصب گواهی انجام نشد"
            rm -rf ~/.acme.sh/${CF_Domain}
            exit 1
        else
            LOGI "گواهی با موفقیت نصب شد"
        fi
        ~/.acme.sh/acme.sh --upgrade --auto-upgrade
        if [ $? -ne 0 ]; then
            LOGE "تنظیمات به‌روزرسانی خودکار انجام نشد"
            ls -lah cert
            chmod 755 $certPath
            exit 1
        else
            LOGI "گواهی نصب شده و به روز رسانی خودکار روشن است، جزئیات به شرح زیر است"
            ls -lah cert
            chmod 755 $certPath
        fi
    else
        show_menu
    fi
}

show_usage() {
clear
    echo -e "${green}\\  //  ||   || ||${plain}"
    echo -e "${White} \\//   ||   || ||${plain}"
    echo -e "${White} //\\   ||___|| ||${plain}"
    echo -e "${red}//  \\  |_____| ||${plain}"
    echo -e "${yellow} IP Server: $MIP2 ${plain}"
    echo "____________________________________"
    echo "x-ui -  نمایش منوی مدیریت "
    echo "x-ui start - شروع پنل"
    echo "x-ui stop - توقف پنل"
    echo "x-ui restart - ریستارت پنل"
    echo "x-ui status- مشاهده وضعیت"
    echo "x-ui enable - تنظیم اجرای خودکار"
    echo "x-ui disable - خاموش کردن اجرای خودکار"
    echo "x-ui log - مشاهده گزارش ها"
    echo "x-ui backup - بکاپ کامل دیتابیس"
    echo "x-ui recovery - بازیابی بکاپ"
    echo "x-ui update - بروز رسانی پنل"
    echo "x-ui install - نصب پنل"
    echo "x-ui uninstall - حذف پنل"
    echo "____________________________________"
}

show_menu() {
clear
    echo -e "${green}\\  //  ||   || ||${plain}"
    echo -e "${White} \\//   ||   || ||${plain}"
    echo -e "${White} //\\   ||___|| ||${plain}"
    echo -e "${red}//  \\  |_____| ||${plain}"
 show_status
 echo -e "
  ${yellow}مدیریت پنل${plain}
  ${green}0.${plain} خروج
  ${green}1.${plain} نصب پنل
  ${green}2.${plain} آپدیت پنل
  ${green}3.${plain} حذف پنل
  ${green}4.${plain} ریست نام و رمز پنل
  ${green}5.${plain} ریست تنظیمات پنل
  ${green}6.${plain} تنظیم پورت پنل
  ${green}7.${plain} مشاهده اطلاعات فعلی پنل
  ${green}8.${plain} اجرای پنل
  ${green}9.${plain} توقف پنل
  ${green}10.${plain} راه اندازی مجدد پنل
  ${green}11.${plain} مشاهده وضعیت پنل
  ${green}12.${plain} مشاهده گزارش های پنل
  ${green}13.${plain} تنظیم اجرای خودکار
  ${green}14.${plain} بستن اجرای خودکار
  ${green}15.${plain} نصب bbr
  ${green}16.${plain} نصب گواهی SSL
  ${green}17.${plain} (بکاپ کامل دیتابیس (شامل تنظیمات پنل و کاربران
  ${green}18.${plain} بازیابی بکاپ
  ${green}19.${plain} تمدید اس اس ال دامنه"
    
    echo && read -p "دستور را وارد کنید [0-18]: " num

    case "${num}" in
    0)
        exit 0
        ;;
    1)
        check_uninstall && install
        ;;
    2)
        check_install && update
        ;;
    3)
        check_install && uninstall
        ;;
    4)
        check_install && reset_user
        ;;
    5)
        check_install && reset_config
        ;;
    6)
        check_install && set_port
        ;;
    7)
        check_install && check_config
        ;;
    8)
        check_install && start
        ;;
    9)
        check_install && stop
        ;;
    10)
        check_install && restart
        ;;
    11)
        check_install && status
        ;;
    12)
        check_install && show_log
        ;;
    13)
        check_install && enable
        ;;
    14)
        check_install && disable
        ;;
    15)
        install_bbr
        ;;
    16)
        ssl_cert_issue
        ;;
    17)
        check_install && backup
        ;;
    18)
        check_install && recovery
        ;;
    19)
        check_install && domain
        ;;
    *)
    clear
        echo -e "${red} از پنل خارج شدید ${plain}"
        ;;
    esac
}

if [[ $# > 0 ]]; then
    case $1 in
    "start")
        check_install 0 && start 0
        ;;
    "stop")
        check_install 0 && stop 0
        ;;
    "restart")
        check_install 0 && restart 0
        ;;
    "status")
        check_install 0 && status 0
        ;;
    "enable")
        check_install 0 && enable 0
        ;;
    "disable")
        check_install 0 && disable 0
        ;;
    "log")
        check_install 0 && show_log 0
        ;;
    "update")
        check_install 0 && update 0
        ;;
    "install")
        check_uninstall 0 && install 0
        ;;
    "uninstall")
        check_install 0 && uninstall 0
        ;;
    "backup")
        check_uninstall 0 && backup 0
        ;;
    "recovery")
        check_install 0 && recovery 0
        ;;
    *) show_usage ;;
    esac
else
    show_menu
fi