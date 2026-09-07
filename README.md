# Server Health Check & Alert Script

A lightweight bash script that monitors disk, memory, CPU, and a critical
service on a server, sending real-time Slack alerts when thresholds are
breached.

## Features

- Disk usage monitoring (`df`)
- Memory usage monitoring (`vm_stat`, with used/free page classification)
- CPU usage monitoring (`top`)
- Service status monitoring (`pgrep`)
- Slack webhook alerts with severity, host, actual value vs threshold, and timestamp
- Secrets kept out of source control via `.env`

## Sample Alert

> 🚨 [ALERT] Disk usage high on MacBookAir: 85% (threshold: 80%) - Fri Sep 4 ...

[]()

## Setup

1. Clone this repo
2. Create a Slack incoming webhook (Slack → Apps → Incoming Webhooks)
3. Create a `.env` file in the project root:
   `SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxxx`
4. Make the script executable: `chmod +x health_check.sh`
5. Test it manually: `bash health_check.sh`

## Scheduling with cron

```bash
crontab -e
0 * * * * /absolute/path/to/health_check.sh
```

## Thresholds

| Metric  | Default Threshold   |
| ------- | ------------------- |
| Disk    | 80%                 |
| Memory  | 80%                 |
| CPU     | 80%                 |
| Service | sshd (configurable) |

## Known limitations

- CPU is checked as a single snapshot, not a sustained average. A brief
  spike can trigger a false alert. Production systems typically average
  over several checks before alerting.
- On macOS, some services (like sshd) are launched on-demand via launchd
  rather than running persistently, so `pgrep`-based checks may not detect
  them as "running" until a connection is made.

## Tech stack

bash, curl, awk, grep, sed, bc, cron, Slack webhooks
