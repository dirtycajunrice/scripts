#!/bin/bash
export LANG=C
drivelist="$(df -H | grep sd | awk '$1 ~ /\/dev/ { print $6 }')"
multidrive="$(df | awk '$1 ~ /\/dev/ { print $6 }' | sed -e 's/\///' -e 's/[0-9]//' -e '/^$/d' | sort | uniq -d)"

awk -v date="$(date +"%a %b %d %r %Z")" \
    -v dateu="$(date +"%a %b %d %r %Z %Y" -u)" \
    -v hostname="$(hostname)" \
    -v extip="$(curl -s checkip.amazonaws.com)" \
    -v intip="$(ip r | awk 'NR==2{print $9}')" \
    -v release="$(lsb_release -d |  awk '{ print $2, $3 }')" \
    -v codename="$(lsb_release -c |  awk '{ print $2 }')" \
    -v loadavg="$(uptime | awk '{print $10, $11, $12}')" \
    -v sysup="$(uptime -p | sed 's/up //')" \
    -v kernel="$(uname -rp)" \
    -v cpuuse="$(top -bn 1 | awk 'NR==3{print 100-$8}')" \
    -v memfreal="$(free -h | awk 'NR==2{print $4}')" \
    -v memfcache="$(free -h | awk 'NR==3{print $4}')" \
    -v swap="$(free -h | awk 'NR==3{print $3}')" \
    -v format="%s %-25s %s %s\n" \
    -v format2="%s %-25s %s %s %s\n" \
    'BEGIN { 
            print "Server Status:"
            print date, "/", dateu
            printf format, "-", "Server Name", "=", hostname
            printf format, "-", "External IP", "=", extip
            printf format, "-", "Internal IP(s)", "=", intip
            printf format2, "-", "OS Version", "=", release, codename
            printf format, "-", "Kernel", "=", kernel
            printf format, "-", "System Uptime", "=", sysup
            printf format, "-", "Load Averages", "=", loadavg
            printf "%s %-25s %s %s%s\n", "-", "CPU Usage (average)", "=", cpuuse, "%"
            printf format, "-", "Memory Free (Real)", "=", memfreal
            printf format, "-", "Memory Free (Cache)", "=", memfcache
            printf format, "-", "Swap In Use", "=", swap
            printf "%s %s\n", "-", "Disk Space Used"
           }'

for drives in $drivelist; do
    if df "$drives" | grep -q "$drives"; then
        df -H | awk -v drives="$drives" '$6 == drives { printf "%10s %18s %4s %s %4s %s\n", 
                                                                $6, "=", $3, "/", $2, $5 }'
    fi
done | sort -b

printf "  " && printf "%0.s-" {1..43} && printf "\n"

for drives in $multidrive; do
    if [[ $(df | grep -c /$drives) -gt 1 ]]; then
        df -H $(df -H | awk -v drives=$drives '$6 ~ drives { print $6 }' | sort) --total | awk -v drives=$drives \
                'END { printf "%16s %s %6s %s %s %4s %s\n", drives, "total", "=", $3, "/", $2, $5 }'
    fi
done

df -H --total | awk 'END { printf "%22s %6s %4s %s %4s %s\n", "grand total", "=", $3, "/", $2, $5 }'
echo
