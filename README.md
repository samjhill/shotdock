# ShotDock

1) detects when you insert an SD card
1) imports its video contents to your storage
1) does color correction

## Setup

```
brew install ffmpeg
brew install fswatch
cp com.sdcard.monitor.plist ~/Library/LaunchAgents/com.sdcard.monitor.plist
sudo cp sdcard_monitor.sh /usr/local/bin/
sudo cp sdcard_import.sh /usr/local/bin/
launchctl load ~/Library/LaunchAgents/com.sdcard.monitor.plist
ls /Volumes/Untitled/
```