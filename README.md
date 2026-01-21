# OpenWRT — ImmortalWRT сборки (vector-co-uz)

Этот репозиторий содержит собранные образы ImmortalWRT для конкретных устройств. В корне находятся папки с готовыми образами и вспомогательными файлами. Ниже — краткое объяснение структуры и ссылки на вложенные папки и их README.

Папки:

- Linksys-WRT1900ACS
  - Описание: образы для Linksys WRT1900ACS (MVEbu / Cortex-A9).
  - Содержимое: factory.img и sysupgrade.bin (варианты с AdGuard и без).
  - Ссылка на папку: https://github.com/vector-co-uz/OpenWRT-ImmortalWRT/tree/main/Linksys-WRT1900ACS
  - Примеры файлов:
    - immortalwrt-24.10.4-mesh-adguard-mvebu-cortexa9-linksys_wrt1900acs-squashfs-factory.img
    - immortalwrt-24.10.4-mesh-adguard-mvebu-cortexa9-linksys_wrt1900acs-squashfs-sysupgrade.bin
    - immortalwrt-24.10.4-mesh-mvebu-cortexa9-linksys_wrt1900acs-squashfs-factory.img
    - immortalwrt-24.10.4-mesh-mvebu-cortexa9-linksys_wrt1900acs-squashfs-sysupgrade.bin
  - Примечание: Используйте factory.img для первоначальной прошивки через веб-интерфейс производителя, sysupgrade.bin — для обновлений из-под OpenWRT/ImmortalWRT.

- Mi-Router-4A-GBit-32MB
  - Описание: сборки и файлы конфигурации для Xiaomi Mi Router 4A (32MB flash).
  - Содержимое: README с инструкциями, папки config и immortalwrt с образами/конфигурациями.
  - Ссылка на папку: https://github.com/vector-co-uz/OpenWRT-ImmortalWRT/tree/main/Mi-Router-4A-GBit-32MB
  - Ссылка на README этой папки: https://github.com/vector-co-uz/OpenWRT-ImmortalWRT/blob/main/Mi-Router-4A-GBit-32MB/README.md

Как пользоваться:

1. Откройте папку устройства и прочитайте локальный README (если есть) — там могут быть важные инструкции по подготовке и прошивке.
2. Скачайте нужный образ (.img или .bin).
3. Следуйте стандартным инструкциям по прошивке для вашего устройства (factory для первой установки, sysupgrade для обновлений).

Внимание и ответственность:

- Прошивка устройства выполняется на ваш страх и риск. Рекомендую сделать резервные копии конфигурации и внимательно читать инструкции.
- Я не даю гарантий корректной работы: используйте сборки на свой риск.

Контакты:

- Владелец репозитория: https://github.com/vector-co-uz

Если нужно — могу обновить README (перевести, добавить инструкции по проверке контрольных сумм, ссылку на релизы или дополнительные папки).