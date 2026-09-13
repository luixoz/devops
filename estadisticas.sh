#!/bin/bash

echo "============================================"
echo " ESTADÍSTICAS DEL SISTEMA"
echo " Host: $(hostname)  Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================"

echo ""
echo "--- CPU TOTAL ---"

CPU=$(top -l 1 | grep "CPU usage" | head -1)
echo "$CPU"

echo ""
echo "--- MEMORIA ---"

vm_stat_output=$(vm_stat)
page_size=$(sysctl -n hw.pagesize)

free_pages=$(echo "$vm_stat_output" | awk '/Pages free/ {print $3}' | tr -d '.')
active_pages=$(echo "$vm_stat_output" | awk '/Pages active/ {print $3}' | tr -d '.')
inactive_pages=$(echo "$vm_stat_output" | awk '/Pages inactive/ {print $3}' | tr -d '.')
wired_pages=$(echo "$vm_stat_output" | awk '/Pages wired down/ {print $4}' | tr -d '.')
compressed_pages=$(echo "$vm_stat_output" | awk '/Pages occupied by compressor/ {print $5}' | tr -d '.')

free_mb=$((free_pages * page_size / 1024 / 1024))
used_mb=$(((active_pages + inactive_pages + wired_pages + compressed_pages) * page_size / 1024 / 1024))

total_mb=$(($(sysctl -n hw.memsize) / 1024 / 1024))

echo "Total: ${total_mb} MB"
echo "Usada: ${used_mb} MB"
echo "Libre: ${free_mb} MB"

echo ""
echo "--- DISCO (libre vs usado) ---"

df -h / | awk 'NR==2 {
    printf "Total: %s\n", $2
    printf "Usado: %s (%s)\n", $3, $5
    printf "Libre: %s\n", $4
}'

echo ""
echo "--- TOP 5 PROCESOS POR CPU ---"

ps -Ao pid,comm,%cpu | sort -k3 -nr | head -n 6

echo ""
echo "--- TOP 5 PROCESOS POR MEMORIA ---"

ps -Ao pid,comm,%mem | sort -k3 -nr | head -n 6
