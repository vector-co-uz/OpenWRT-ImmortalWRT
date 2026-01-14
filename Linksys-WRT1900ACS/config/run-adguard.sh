#!/bin/bash


set -e  # Óñòàíîâêà ïðè îøèáêå

# ================= ÍÀÑÒÐÎÉÊÈ =================
PROFILE="linksys_wrt1900acs"

# Ïàêåòû, êîòîðûå òî÷íî äîáàâëÿåì
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
dnsmasq-full \
firewall4 \
nftables \
etherwake \
batctl-default \
iwinfo \
iw-full \
hostapd-common \
wpad-mesh-mbedtls \
wireless-regdb \
wifi-scripts \
ip-tiny \
luci-compat \
luci-light \
luci-lib-base \
luci-lib-ipkg \
luci-app-adguardhome \
luci-app-advanced-reboot \
luci-app-autoreboot \
luci-app-filemanager \
luci-app-firewall \
luci-app-internet-detector \
luci-app-ksmbd \
luci-app-package-manager \
luci-app-usteer \
luci-app-wol \
luci-app-tailscale-community \
luci-theme-bootstrap \
block-mount \
blkid \
dosfstools \
ntfs-3g \
ntfs-3g-utils \
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
luci-proto-ncm \
luci-proto-qmi \
luci-proto-relay \
luci-proto-ipv6 \
nano \
iperf3 \
irqbalance \
smartmontools \
socat \
wget-ssl \
avahi-dbus-daemon \
kmod-nft-offload \
mwlwifi-firmware-88w8864 \
kmod-mwlwifi \
kmod-nf-nathelper \
dropbear \
kmod-gpio-button-hotplug \
autocore \
libustream-mbedtls \
logd \
odhcp6c \
odhcpd-ipv6only \
kmod-nf-conntrack6 \
kmod-nf-reject6 \
ip6tables-nft \
uclient-fetch \
curl \
internet-detector-mod-modem-restart \
tailscale \
"


# Ïàêåòû, êîòîðûå òî÷íî óäàëÿåì
PACKAGES="$PACKAGES \
-ppp \
-ppp-mod-pppoe \
-default-settings-chn \
-wpad-openssl \
-luci-proto-ppp \
-luci-app-cpufreq \
-iw \
-libustream-openssl \
-btrfs-progs \
-kmod-fs-btrfs \
"

# Îòêëþ÷àåì ïðîâåðêó ïîäïèñè ïàêåòîâ (íå ðåêîìåíäóåòñÿ äëÿ ïðîäàêøåíà, íî óäîáíî ïðè ñáîðêå)
export DISABLE_SIGNATURE_CHECK=1

# Èìåíà äëÿ îòëè÷èÿ ôàéëîâ
SYSUPGRADE_NAME="mesh"

# Ïàïêà ñ overlay-ôàéëàìè (uci-defaults è ò.ä.)
FILES_DIR="files"

# =============================================

echo "=== Ñîçäàžì ñòðóêòóðó overlay ==="
mkdir -p $FILES_DIR/etc/uci-defaults
mkdir -p $FILES_DIR/etc/sysctl.d


# Ñêðèïò äëÿ óñòàíîâêè IP 10.10.10.1
cat << 'EOF' > $FILES_DIR/etc/uci-defaults/99-custom-config
#!/bin/sh

sed -i '/^[[:space:]]*\(option[[:space:]]\+\)\?check_signature\b/d' /etc/opkg.conf

echo '#option check_signature' >> /etc/opkg.conf

uci set dropbear.@dropbear[0].Interface=''
uci set firewall.@defaults[0].flow_offloading='0'
uci set firewall.@defaults[0].flow_offloading_hw='0'
uci commit firewall

# Óñòàíàâëèâàåì LAN IP 10.10.10.1/24
uci set network.lan.ipaddr='10.10.10.1'
uci set network.lan.netmask='255.255.255.0'
uci commit network

# Îòêëþ÷àåì òåëåìåòðèþ è ïðî÷èé ìóñîð (îïöèîíàëüíî)
uci set gluon-nodeinfo.@owner[0].contact='t.me/vector_co_uz'
uci set system.@system[0].hostname='linksys'
uci commit system

# Ïåðåçàãðóæàåì ñåòü (íåîáÿçàòåëüíî, sysupgrade ñàì ïðèìåíèò)
/etc/init.d/network restart

/etc/init.d/firewall restart

exit 0
EOF

chmod +x $FILES_DIR/etc/uci-defaults/99-custom-config


echo "=== Ñáîðêà 1: sysupgrade.bin ==="
make image PROFILE="$PROFILE" \
    PACKAGES="$PACKAGES" \
    FILES="$FILES_DIR/" \
    IPKG_DIR=ipks \
    EXTRA_IMAGE_NAME="$SYSUPGRADE_NAME" \
#    ROOTFS_PARTSIZE=$ROOTFS_SIZE

