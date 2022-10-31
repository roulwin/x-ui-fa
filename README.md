# x-ui

x-ui یک پانل xray با پشتیبانی از چند پروتکل چند کاربره (نسخه فارسی)

# امکانات
- زبان فارسی
- نظارت بر وضعیت سیستم
- تنظیم محدودیت اتصال کاربران
- پشتیبانی از پروتکل چند کاربره، عملیات تجسم صفحه وب
- پروتکل های پشتیبانی شده: vmess، vless، trojan، shadowsocks، dokodemo-door، socks، http
- پشتیبانی برای پیکربندی تنظیمات انتقال بیشتر
- آمار ترافیک، محدودیت ترافیک، محدود کردن زمان انقضا
- قالب های پیکربندی xray قابل تنظیم
- پشتیبانی از پنل دسترسی https (نام دامنه + گواهی ssl خود را بیاورید)
- پشتیبانی از برنامه گواهینامه SSL با یک کلیک و تمدید خودکار
- برای موارد پیکربندی پیشرفته تر، برای جزئیات به پانل مراجعه کنید

# نصب و ارتقا دهید

````
wget --no-check-certificate -O install https://raw.githubusercontent.com/MrCenTury/x-ui-fa/master/install
chmod +x install
./install
````


## SSL certificate application

The script has a built-in SSL certificate application function. To use this script to apply for a certificate, the following conditions must be met:

- Know the Cloudflare registered email address
- Know the Cloudflare Global API Key
- The domain name has been resolved to the current server through cloudflare

How to get the Cloudflare Global API Key:
    ![](media/bda84fbc2ede834deaba1c173a932223.png)
    ![](media/d13ffd6a73f938d1037d0708e31433bf.png)

When using, just enter `domain name`, `email`, `API KEY`, the diagram is as follows:
        ![](media/2022-04-04_141259.png)

Precautions:

- The script uses DNS API for certificate request
- Use Let'sEncrypt as the CA party by default
- The certificate installation directory is the /root/cert directory
- The certificates applied for by this script are all generic domain name certificates

##Tg robot use (under development, temporarily unavailable)

> This function and tutorial are provided by [FranzKafkaYu](https://github.com/FranzKafkaYu)

X-UI supports daily traffic notification, panel login reminder and other functions through Tg robot. To use Tg robot, you need to apply by yourself
For specific application tutorials, please refer to [blog link](https://coderfan.net/how-to-use-telegram-bot-to-alarm-you-when-someone-login-into-your-vps.html)
Instructions for use: Set robot-related parameters in the background of the panel, including

- Tg Robot Token
- Tg Robot ChatId
- Tg robot cycle runtime, in crontab syntax

Reference syntax:
- 30 * * * * * //Notify at the 30s of each point
- @hourly // hourly notifications
- @daily // Daily notification (00:00 AM)
- @every 8h // Notification every 8 hours

TG notification content:
- Node traffic usage
- Panel login reminder
- Node expiration reminder
- Traffic warning reminder

More features are planned...
## suggestion system

- CentOS 7+
- Ubuntu 16+
- Debian 8+

# common problem

## Migrating from v2-ui

First install the latest version of x-ui on the server where v2-ui is installed, and then use the following command to migrate, which will migrate `all inbound account data` of the local v2-ui to x-ui, `panel settings and username and password' will not migrate`

> After the migration is successful, please `close v2-ui` and `restart x-ui`, otherwise the inbound of v2-ui will cause a `port conflict` with the inbound of x-ui

````
x-ui v2-ui
````

## issue closed

All kinds of small white problems see high blood pressure

## Stargazers over time

[![Stargazers over time](https://starchart.cc/vaxilu/x-ui.svg)](https://starchart.cc/vaxilu/x-ui)
