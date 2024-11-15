#!/bin/bash

# проверка на указание входного файла
if [ -z "$1" ]
then
    echo "Ошибка: Укажите входной файл в качестве аргумента."
    echo "Пример: ./network_config_parser.sh input.txt"
    exit 1
fi

# установка переменных
input_file="$1"

if [ -z "$2" ]
then
    output_file="network_config.conf"
else
    output_file="$2"
fi

# проверка существования входного файла
if [ ! -f "$input_file" ]
then
    echo "Ошибка: Файл $input_file не найден!"
    exit 1
fi

# инициализация выходного файла
{
    echo "source /etc/network/interfaces.d/*"
    echo "auto lo eth0"
    echo ""
    echo "iface lo inet loopback"
} > "$output_file"

# чтение входного файла построчно
while read -r interface ip mask vlan
do
    # проверка, задан ли интерфейс
    if [ "$interface" = "-" ]
    then
        iface_name="eth0"
    else
        iface_name=$(echo "$interface" | cut -d'@' -f1)
    fi

    # обработка VLAN
    if [ "$vlan" = "-" ]
    then
        vlan_part=""
    else
        vlan_part="vlan-raw-device ${iface_name%@*}"
    fi

    # добавление конфигурации интерфейса
    {
        echo ""
        echo "iface ${iface_name} inet static"
        echo "    address $ip/$mask"
        if [ -n "$vlan_part" ]
        then
            echo "    $vlan_part"
        fi
    } >> "$output_file"
done < "$input_file"

# вывод завершения работы
echo "Конфигурация успешно сохранена в файл $output_file"
