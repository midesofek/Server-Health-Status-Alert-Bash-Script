#!/bin/bash
source /Users/mac/MyProjects/Devops_Mastery/linux_lessons/ServerHealthStatusAlert/.env

send_alert(){
 msg=$1;
 curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$msg\"}" $SLACK_WEBHOOK_URL 
}

disk_usage=$(df -h | grep '/$' | awk '{ print $5 }' | sed "s/%//")
disk_threshold=80
mem_threshold=80
cpu_threshold=80
service_name="sshd"

if [ "$disk_usage" -gt $disk_threshold ]; then 
	send_alert "🚨 [ALERT] Disk usage high on $(hostname): $disk_usage% (threshold: $disk_threshold%) - $(date)" 
fi

pages_free=$(vm_stat | grep "Pages free" | awk '{ print $3 }' | sed "s/.$//")
pages_active=$(vm_stat | grep "Pages active" | awk '{ print $3 }' | sed "s/.$//")
pages_inactive=$(vm_stat | grep "Pages inactive" | awk '{ print $3 }' | sed "s/.$//")
pages_speculative=$(vm_stat | grep "Pages speculative" | awk '{ print $3 }' | sed "s/.$//")
pages_wired=$(vm_stat | grep "Pages wired down" | awk '{ print $4 }' | sed "s/.$//")
pages_compressed=$(vm_stat | grep "Pages occupied by compressor:" | awk '{ print $5 }' | sed "s/.$//") 

free_group=$(echo "$pages_free + $pages_speculative" | bc) 
used=$(echo "$pages_active + $pages_inactive + $pages_wired + $pages_compressed" | bc)
total=$(echo "$free_group + $used" | bc)
used_percent=$(echo "scale=2; $used / $total * 100" | bc)

mem_alert=$(echo "$used_percent > $mem_threshold" | bc)

if [ "$mem_alert" -eq 1 ]; then
	send_alert "🚨 [ALERT] Memory usage high on $(hostname): $used_percent% (threshold: $mem_threshold%) - $(date)"
fi

cpu_idle=$(top -l 1 | grep "CPU usage:" | awk '{ print $7 }' | sed 's/%//')
cpu_usage=$(echo "100 - $cpu_idle" | bc)
cpu_alert=$(echo "$cpu_usage > $cpu_threshold"| bc)

if [ $cpu_alert -eq 1 ]; then
	send_alert "🚨 [ALERT] CPU usage high on $(hostname): $cpu_usage% (threshold: $cpu_threshold%) - $(date)"
fi

if pgrep $service_name > /dev/null; then
	echo "running"
else 
	echo "not running"
	send_alert "🚨 [ALERT] Service $service_name is not running on $(hostname) - $(date)"
fi

