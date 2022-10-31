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
bash <(curl -Ls https://raw.githubusercontent.com/MrCenTury/x-ui-fa/master/install.sh)
````

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

## نلگرام

[![گروه تلکرام ما](https://t.me/x_ui_fa)](https://t.me/x_ui_fa)
