# ShotDock

## Setup

```
brew install fswatch
cp com.sdcard.monitor.plist ~/Library/LaunchAgents/com.sdcard.monitor.plist
sudo cp sdcard_monitor.sh /usr/local/bin/
sudo cp sdcard_import.sh /usr/local/bin/
launchctl load ~/Library/LaunchAgents/com.sdcard.monitor.plist
ls /Volumes/Untitled/
```