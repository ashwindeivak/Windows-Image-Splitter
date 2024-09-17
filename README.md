# Windows-Image-Splitter
Give it a Windows ISO and make it compatible for FAT32 by splitting the install.wim

### Launch Command
Run as administrator

```ps1
irm "https://raw.githubusercontent.com/ashwindeivak/Windows-Image-Splitter/refs/heads/main/win-iso-splitter.ps1" | iex
```

Auto-install [latest Windows ADK and the PE add-on](https://learn.microsoft.com/en-us/windows-hardware/get-started/adk-install) in one-click


### Why❓
I recently tried to install a Windows on a Snapdragon X Elite computer, turn out the usb HAD to be formatted in FAT32
With this tool, you just have to give your iso, it will do all the steps automatically without any installation. Everything is open source.

### Upcoming Changes :
- Make it a bit prettier and still good for small screens
- Unmount the original iso automatically
- Instead of creating the files on the desktop, create them in a temporary folder
- Try avoiding the need to run it as administrator
- What else? Don't hesitate to tell me !
