# ShotDock

1) detects when you insert an SD card
1) imports its video contents to your storage
1) removes dust / speckles from footage
1) does color correction
1) does image stabilization

## Setup

```
git clone git@github.com:samjhill/shotdock.git
cd shotdock
brew install ffmpeg
brew install fswatch
brew install parallel
```

## Running it manually

```
./sdcard_import.sh
```

## Running it automatically (detect when an SD card is inserted)

```sh
cp com.sdcard.monitor.plist ~/Library/LaunchAgents/com.sdcard.monitor.plist
sudo cp sdcard_monitor.sh /usr/local/bin/
sudo cp sdcard_import.sh /usr/local/bin/
launchctl unload ~/Library/LaunchAgents/com.sdcard.monitor.plist
launchctl load ~/Library/LaunchAgents/com.sdcard.monitor.plist
ls /Volumes/Untitled/
```

## Swiftbar Plugin
(currently not working; SwiftBar is not starting)

```sh
brew install swiftbar
```

Open Swiftbar and set up a plugin folder, then copy it there:

```sh
cp sdcard_spinner.1s.sh /Users/samhilll/Documents/Swiftbar/plugins
```