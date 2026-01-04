#!/bin/bash


set -e  # Установка при ошибке

# ================= НАСТРОЙКИ =================
PROFILE="linksys_wrt1900acs"

# Пакеты, которые точно добавляем
PACKAGES="\
base-files \
kernel \
libc \
libgcc \
procd-ujail \
netifd \
opkg \
uci \
uboot-envtools \
urandom-seed \
urngd \
mtd \
fstools \
partx-utils \
ca-bundle \
dnsmasq \
firewall4 \
iptables-nft \
ip6tables-nft \
nftables \
qos-scripts \
etherwake \
batctl-default \
iw \
iwinfo \
iw-full \
hostapd-common \
wpad-mesh-openssl \
wireless-regdb \
wifi-scripts \
luci \
luci-base \
luci-compat \
luci-light \
luci-lib-base \
luci-lib-ipkg \
luci-app-adguardhome \
luci-app-advanced-reboot \
luci-app-autoreboot \
luci-app-dawn \
luci-app-diskman \
luci-app-filemanager \
luci-app-firewall \
luci-app-internet-detector \
luci-app-ksmbd \
luci-app-package-manager \
luci-app-qos \
luci-app-tailscale-community \
luci-app-ttyd \
luci-app-wol \
luci-theme-bootstrap \
adguardhome \
block-mount \
blkid \
dosfstools \
exfat-fsck \
exfat-mkfs \
ntfs-3g \
ntfs-3g-utils \
mkf2fs \
kmod-fs-ntfs \
kmod-usb2 \
kmod-usb3 \
kmod-usb-ehci \
kmod-usb-ohci \
kmod-usb-uhci \
kmod-usb-printer \
kmod-usb-net \
kmod-usb-net-cdc-ether \
kmod-usb-net-cdc-mbim \
kmod-usb-net-qmi-wwan \
kmod-usb-net-rndis \
kmod-usb-net-rtl8152 \
usbutils \
luci-proto-3g \
luci-proto-hnet \
luci-proto-ncm \
luci-proto-qmi \
luci-proto-relay \
nano \
iperf3 \
irqbalance \
smartmontools \
socat \
ttyd \
wget-ssl \
curl \
avahi-dbus-daemon \
rt2800-usb-firmware \
rt73-usb-firmware \
rtl8188eu-firmware \
rtl8192cu-firmware \
kmod-nft-offload \
mwlwifi-firmware-88w8864 \
kmod-mwlwifi \
kmod-nf-nathelper \
dropbear \
kmod-gpio-button-hotplug \
"


# Пакеты, которые точно удаляем
PACKAGES="$PACKAGES \
-ppp \
-ppp-mod-pppoe \
-default-settings-chn \
-wpad-openssl \
-luci-proto-ppp \
-hostapd \
-ntpd \
-dnsmasq-full \
-luci-app-cpufreq \
"

# Отключаем проверку подписи пакетов (не рекомендуется для продакшена, но удобно при сборке)
export DISABLE_SIGNATURE_CHECK=1

# Имена для отличия файлов
SYSUPGRADE_NAME="mesh"

# Папка с overlay-файлами (uci-defaults и т.д.)
FILES_DIR="files"

# =============================================

echo "=== Создаём структуру overlay ==="
mkdir -p $FILES_DIR/etc/uci-defaults
mkdir -p $FILES_DIR/etc/sysctl.d


# Скрипт для установки IP 10.10.10.1
cat << 'EOF' > $FILES_DIR/etc/uci-defaults/99-custom-config
#!/bin/sh

# Устанавливаем LAN IP 10.10.10.1/24
uci set network.lan.ipaddr='10.10.10.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network

# Отключаем телеметрию и прочий мусор (опционально)
uci set gluon-nodeinfo.@owner[0].contact='t.me/vector_co_uz'
uci set system.@system[0].hostname='linksys'
uci commit system

# Перезагружаем сеть (необязательно, sysupgrade сам применит)
/etc/init.d/network restart

exit 0
EOF

chmod +x $FILES_DIR/etc/uci-defaults/99-custom-config

echo "=== Сборка 1: sysupgrade.bin ==="
make image PROFILE="$PROFILE" \
    PACKAGES="$PACKAGES tailscale " \
    FILES="$FILES_DIR/" \
    IPKG_DIR=ipks \
    EXTRA_IMAGE_NAME="$SYSUPGRADE_NAME" \
#    ROOTFS_PARTSIZE=$ROOTFS_SIZE

echo "=== Всё готово! ==="
echo "Файлы находятся в: bin/targets/mvebu/cortexa9"
echo ""
echo "После загрузки любой из прошивок:"
echo "   • IP: 10.10.11.1"
echo "   • LuCI на русском"
echo "   • Полный набор mesh-пакетов (DAWN, relay и т.д.)"

exit 0