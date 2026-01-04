#!/bin/bash
# Скрипт сборки кастомной прошивки OpenWrt для Xiaomi Mi Router 4A Gigabit (32 МБ flash)
# Требования: находишься в распакованной папке ImageBuilder

set -e  # Остановка при ошибке

# ================= НАСТРОЙКИ =================
PROFILE="xiaomi_mi-router-4a-gigabit"

# Пакеты, которые точно добавляем
PACKAGES="\
luci-base \
luci-mod-admin-full \
luci-theme-bootstrap \
luci-app-dawn \
luci-app-autoreboot \
luci-app-internet-detector \
luci-app-autoreboot \
luci-i18n-base-ru \
luci-proto-relay \
relayd \
default-settings \
wpad-mesh-mbedtls \
nano \
zram-swap \
dnsmasq \
"

# Пакеты, которые точно удаляем
PACKAGES="$PACKAGES \
-ppp \
-ppp-mod-pppoe \
-default-settings-chn \
-block-mount \
-wpad-openssl \
-luci-proto-ppp \
-odhcpd-ipv6only \
-ip6tables  \
-odhcp6c \
-hostapd \
-ntpd \
-dnsmasq-full \
"

# Отключаем проверку подписи пакетов (не рекомендуется для продакшена, но удобно при сборке)
export DISABLE_SIGNATURE_CHECK=1

# Размер rootfs — максимально используем 32 МБ flash
# 28 МБ — безопасное значение (оставляет запас под kernel и партиции)
# ROOTFS_SIZE=28

# Имена для отличия файлов
SYSUPGRADE_NAME="mesh-without-ipv6-32mb-ru"

# Папка с overlay-файлами (uci-defaults и т.д.)
FILES_DIR="files"

# =============================================

echo "=== Создаём структуру overlay ==="
mkdir -p $FILES_DIR/etc/uci-defaults
mkdir -p $FILES_DIR/etc/sysctl.d

# Полное отключение IPv6
cat << 'EOF' > "$FILES_DIR/etc/sysctl.d/99-disable-ipv6.conf"
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1

EOF

# Скрипт для установки IP 10.10.11.1 и русского языка LuCI
cat << 'EOF' > $FILES_DIR/etc/uci-defaults/99-custom-config
#!/bin/sh

# Устанавливаем LAN IP 10.10.11.1/24
uci set network.lan.ipaddr='10.10.11.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network

# Русский язык в LuCI по умолчанию
uci set luci.main.lang='ru'
uci commit luci

# Отключаем телеметрию и прочий мусор (опционально)
uci set gluon-nodeinfo.@owner[0].contact=''
uci set system.@system[0].hostname='OpenWrt-Mesh'
uci commit system

# IPv6 сервисы OFF (на всякий случай)
if [ -x /etc/init.d/odhcpd ]; then
    /etc/init.d/odhcpd stop
    /etc/init.d/odhcpd disable
fi

# Перезагружаем сеть (необязательно, sysupgrade сам применит)
/etc/init.d/network restart

exit 0
EOF

chmod +x $FILES_DIR/etc/uci-defaults/99-custom-config

echo "=== Сборка 1: sysupgrade.bin (с большим overlay для 32 МБ) ==="
make image PROFILE="$PROFILE" \
    PACKAGES="$PACKAGES" \
    FILES="$FILES_DIR/" \
    EXTRA_IMAGE_NAME="$SYSUPGRADE_NAME" \
#    ROOTFS_PARTSIZE=$ROOTFS_SIZE

echo "=== Всё готово! ==="
echo "Файлы находятся в: bin/targets/ramips/mt7621/"
echo ""
echo "Обычная прошивка (заливать через LuCI/sysupgrade):"
echo ""
echo "После загрузки любой из прошивок:"
echo "   • IP: 10.10.11.1"
echo "   • LuCI на русском"
echo "   • Полный набор mesh-пакетов (DAWN, relay и т.д.)"

exit 0