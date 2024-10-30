#!/bin/bash

# проверка на указание входного файла
if [[ -z "$1" ]]; then
  echo "Ошибка: Укажите входной файл в качестве аргумента."
  echo "Пример: ./network_config_parser.sh input.txt"
  exit 1
fi

# входной файл — первый аргумент, переданный скрипту
input_file="$1"
output_file="network_config.conf" # переменная хранит имя выходного файла

# проверка существования входного файла
if [[ ! -f "$input_file" ]]; then
  echo "Ошибка: Файл $input_file не найден!"
  exit 1 
fi

# инициализация выходного файла
echo "source /etc/network/interfaces.d/*" > "$output_file" # создаем новый файл или перезаписываем существующий
echo "auto lo eth0" >> "$output_file" # автоматически включаем локальный интерфейс
echo "" >> "$output_file"
echo "iface lo inet loopback" >> "$output_file" # определяет, что локальный интерфейс будет настроен для работы с IPv4 

# чтение входного файла построчно
while read -r interface ip mask vlan; do

  # проверка, задан ли интерфейс
  if [[ "$interface" == "-" ]]; then
    iface_name="eth0" # используем интерфейс по умолчанию, если он не указан
  else
    iface_name=$(echo "$interface" | cut -d'@' -f1) # разделяем строку по символу @ и записываем первюу часть
  fi

  # обработка VLAN
  if [[ "$vlan" == "-" ]]; then
    vlan_part="" # оставляем пустым, так как VLAN отсутствует
  else
    vlan_part="vlan-raw-device ${iface_name%@*}"  # добавляем строку vlan-raw-device с основным интерфейсом (до символа @). 
  fi
  
  # добавление конфигурации интерфейса
  echo "" >> "$output_file"
  echo "iface ${iface_name} inet static" >> "$output_file"
  echo "  address $ip/$mask" >> "$output_file"
  if [[ ! -z "$vlan_part" ]]; then # проверяем есть ли VLAN, если есть, записываем
    echo "  $vlan_part" >> "$output_file"
  fi
done < "$input_file" # перенаправляет содержимое файла в ввод цикла, читаем построчно
