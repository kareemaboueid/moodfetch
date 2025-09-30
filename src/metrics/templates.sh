#!/usr/bin/env bash
# Mood templates for system status messages
# Placeholders: {battery_pct} {cpu_temp} {cpu_util_pct} {load_per_core} {ram_pct} {swap_pct}
# {disk_pct} {uptime_h} {iface} {wifi_signal} {top_proc} {distro} {kernel} {hostname} {profile} 
# {iowait_pct} {volume_pct} {net_rx_bps} {net_tx_bps} {process_count} {disk_read_bps} {disk_write_bps}
set -u

battery_critical_tpl=(
  "Battery at {battery_pct}%% and dropping; if neglect were a sport, you'd be regional champion. Plug me in before I face-plant into oblivion."
  "I'm running on pocket lint and optimism ({battery_pct}%% left). One sleep and I'm gone; grab the charger unless chaos is your brand."
  "With {battery_pct}%% remaining and no cable in sight, I'm auditioning to be a paperweight. Your call: electrons or elegy."
  "At {battery_pct}%% battery, my survival strategy is sarcasm. Power me or prepare for a very dramatic blackout."
)

battery_low_tpl=(
  "Battery hovering at {battery_pct}%% — not dying, just practicing. Keep pretending this is fine; I adore suspense."
  "We're at {battery_pct}%% battery, which pairs beautifully with your 'I'll plug it later' routine. Bold."
  "Energy at {battery_pct}%%. I could make it… or not. Want to gamble on unsaved work?"
  "Low battery ({battery_pct}%%), high anxiety. A classic duo."
)

cpu_hot_tpl=(
  "CPU temperature {cpu_temp}°C with utilization {cpu_util_pct}%% — I'm moonlighting as a space heater."
  "Hot core alert: {cpu_temp}°C. Whatever you're compiling could summon a small sun."
  "Sustained {cpu_util_pct}%% CPU under {cpu_temp}°C — industrial cosplay is in."
  "Thermals say 'volcano' ({cpu_temp}°C). I'm not melting… I'm evolving."
)

cpu_pressure_tpl=(
  "Load per core {load_per_core} — the queue looks like airport security. Maybe let one app breathe?"
  "CPU pressure {load_per_core} — I'm juggling chainsaws while you shout 'one more tab'."
  "Cores busy at {cpu_util_pct}%% — call it productive… or reckless enthusiasm."
  "Load {load_per_core}/core; I'm doing cardio without a gym membership."
)

ram_full_tpl=(
  "Memory {ram_pct}%% with swap {swap_pct}%%: my brain is a bargain bin. New ideas will be paged… eventually."
  "RAM {ram_pct}%%, swap {swap_pct}%% — I'm hoarding bytes like limited editions."
  "We're memory-tight ({ram_pct}%%): next idea should be tiny or profoundly patient."
  "RAM stuffed at {ram_pct}%%. If creativity needs space, evict some tabs."
)

disk_full_tpl=(
  "Root disk {disk_pct}%% — a monument to downloads you 'might need someday'. I await the great purge."
  "Storage {disk_pct}%%: I respect your archival instincts; my inode therapist disagrees."
  "At {disk_pct}%% disk usage I practice minimalism by force. Release the ISOs."
  "Disk nearly full ({disk_pct}%%). If bits had elbows, they'd be fighting."
)

disk_iowait_tpl=(
  "I/O wait {iowait_pct}%% — your disk is performing interpretive slow dance. Applause optional, patience mandatory."
  "Heavy I/O ({iowait_pct}%%). I'm politely in line while everything else cuts."
  "Drive's contemplating existence: iowait {iowait_pct}%%. We proceed at the speed of philosophy."
)

uptime_zombie_tpl=(
  "Uptime {uptime_h}h — I've outlasted your sleep schedule and three coffees. Reboot therapy, perhaps?"
  "After {uptime_h} hours awake I'm a night-shift barista: brisk, bitter, overheating."
  "We crossed {uptime_h} hours. Not a server farm. I have feelings. Mostly sarcasm."
)

net_offline_tpl=(
  "Network interface '{iface}' offline: Operating in splendid digital isolation."
  "No network detected — functioning perfectly without the chaos of the internet."
  "Network offline: Enjoying the silence of disconnected productivity."
)

audio_muted_tpl=(
  "Silent mode engaged. Not sure if peace or malfunction."
  "Volume at {volume_pct}%%. Trying interpretive dance instead of audio."
  "Muted. Either zen mode or forgot the volume again."
  "Shh... we're being stealthy (or the audio's broken)."
)

net_busy_tpl=(
  "Network humming at {net_rx_bps}B/s down, {net_tx_bps}B/s up. Popular today, aren't we?"
  "Bandwidth party: {net_rx_bps}B/s incoming. Your ISP must love you."
  "Moving {net_tx_bps}B/s of data. Trying to download the internet?"
  "Network activity intense. Either big download or neighbor found your Wi-Fi."
)

proc_high_tpl=(
  "Running {process_count} processes. Task Manager's worst nightmare."
  "Process count: {process_count}. Your CPU is running a small city."
  "{process_count} processes and counting. Chrome tabs, I assume?"
  "Managing {process_count} processes. Multitasking or Chrome solitaire?"
)

default_ok_tpl=(
  "All systems nominal. Almost suspiciously so."
  "Everything's fine. Not even a sarcastic comment needed."
  "Running smoothly. I'll find something to complain about later."
  "Status: Surprisingly functional. Don't get used to it."
)
