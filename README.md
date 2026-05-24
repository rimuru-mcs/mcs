# Multiclass-Server

A custom EverQuest server project attempting to recreate and expand the multiclass features originally found on THJ.

These files include everything needed for both the client and server:

* Multiclass-Server-Client-Files.rar
* Server-Packet.rar  

For detailed installation instructions, see:

* [Modernization CONTRIBUTIONS.md](CONTRIBUTIONS.md)
* [New Release README_RELEASE.md](README_RELEASE.md)
* [Detailed Project Diff](COMPREHENSIVE_DIFF.md)
* Readme!!.txt in the Assets folder  
* The installation guide below  

---

## Multiclass Server Installation Guide

---

### 1. PEQ Database Setup

**PEQ Backup Location**

The PEQ backup file is located in the Assets folder of your server files:

* thj_peq_backup.sql

**Importing the Database**

1. Open a Command Prompt.
2. Navigate to the folder containing thj_peq_backup.sql.
3. Run the following commands:

```bash
mysql -u root -p -e "CREATE DATABASE thj_peq;"
mysql -u root -p thj_peq < thj_peq_backup.sql
```

**Login Credentials**

For out-of-the-box compatibility, use:

* user: root  
* password: root  

If you choose a different password, update it in the following files:

* eqemu_config.json  
* login.json  
* quests\migrate_bags.pl  
* quests\migrate_items.pl  

---

### 2. Client Setup

**Download the Client Files**

Download the Multiclass-Server Client Files from the GitHub release page:

https://github.com/Kraqurjak/Multiclass-Server-Release/releases/tag/V1.0

**Install the RoF2 Client**

* Download the RoF2 client from Steam or another source.  
* Exact links cannot be provided for copyright reasons.

**Apply the Multiclass Client Files**

1. Extract Multiclass-Server.Client.Files.rar.
2. Copy the extracted files into your RoF2 directory.
3. Overwrite all files when prompted.

**Configure eqhost.txt**

If you are running locally, use:

```text
[LoginServer]
Host=127.0.0.1:5999
```

If you are connecting remotely, change Host to match your server's IP and port.

Your client is now ready.

---

### 3. Server Setup

**Download the Server Packet**

Download the server package from the release page:

https://github.com/Kraqurjak/Multiclass-Server-Release/releases/tag/V1.0

This package includes:

* quests  
* plugins  
* spire  
* all required server scripts  

**Build the Server**

1. Run `python generate_vcxproj.py` to generate the new `akk-stack` structure.
2. Open `code/EQEmu.sln` in Visual Studio and compile in **Release / x64**.
3. Binaries will automatically deploy to `server/bin/`.

**Important: zlib-ng1.dll**

* Do not overwrite the zlib-ng1.dll included in the Server-Packet.  
* The server requires zlib-ng1.dll to run.

A backup copy is included in:

* Server-Packet/zlib-ng1 Backup/

If you delete or overwrite it, copy the backup into your bin directory.

**Final Step**

* Run the server executables (or Spire).  
* If your database and configuration files are correct, the server should start normally.

---

### Additional Notes

If you do not know how to compile the server, precompiled binaries are provided:

* Compiled-Server.rar

Place the contents of this archive into the bin folder inside the Server-Packet directory.

This is not required if you are compiling your own server.

---
---
---


# EQEmulator Core Server
| Drone (Linux x64) | Drone (Windows x64)   |
|:---:|:---:|
|[![Build Status](http://drone.akkadius.com/api/badges/EQEmu/Server/status.svg)](http://drone.akkadius.com/EQEmu/Server)   |[![Build Status](http://drone.akkadius.com/api/badges/EQEmu/Server/status.svg)](http://drone.akkadius.com/EQEmu/Server)   |

***

**EQEmulator is a custom completely from-scratch open source server implementation for EverQuest built mostly on C++**
 * MySQL/MariaDB is used as the database engine (over 200+ tables)
 * Perl and LUA are both supported scripting languages for NPC/Player/Quest oriented events
 * Open source database (Project EQ) has content up to expansion OoW (included in server installs)
  * Game server environments and databases can be heavily customized to create all new experiences
 * Hundreds of Quests/events created and maintained by Project EQ

## Server Installs
| |Windows|Linux|
|:---:|:---:|:---:|
|**Install Count**|![Windows Install Count](http://analytics.akkadius.com/?install_count&windows_count)|![Linux Install Count](http://analytics.akkadius.com/?install_count&linux_count)| 
### > Windows 

* [Install Guide](https://docs.eqemu.io/server/installation/server-installation-windows/)

### > Debian/Ubuntu/CentOS/Fedora

* [Install Guide](https://docs.eqemu.io/server/installation/server-installation-linux/)

* You can use curl or wget to kick off the installer (whichever your OS has)
> curl -O https://raw.githubusercontent.com/EQEmu/Server/master/utils/scripts/linux_installer/install.sh install.sh && chmod 755 install.sh && ./install.sh

> wget --no-check-certificate https://raw.githubusercontent.com/EQEmu/Server/master/utils/scripts/linux_installer/install.sh -O install.sh && chmod 755 install.sh && ./install.sh 

## Supported Clients

|Titanium Edition|Secrets of Faydwer|Seeds of Destruction|Underfoot|Rain of Fear|
|:---:|:---:|:---:|:---:|:---:|
|<img src="http://i.imgur.com/hrwDxoM.jpg" height="150">|<img src="http://i.imgur.com/cRDW5tn.png" height="150">|<img src="http://i.imgur.com/V48kuVn.jpg" height="150">|<img src="http://i.imgur.com/IJQ0XMa.jpg" height="150">|<img src="http://i.imgur.com/OMpHkKa.png" height="100">|

## Bug Reports <img src="http://i.imgur.com/daf1Vjw.png" height="20">
* Please use the [issue tracker](https://github.com/EQEmu/Server/issues) provided by GitHub to send us bug
reports or feature requests.
* The [EQEmu Forums](http://www.eqemulator.org/forums/) are also a place to submit and get help with bugs.

## Contributions <img src="http://image.flaticon.com/icons/png/512/25/25231.png" width="20">

* The preferred way to contribute is to fork the repo and submit a pull request on
GitHub. If you need help with your changes, you can always post on the forums or
try Discord. You can also post unified diffs (`git diff` should do the trick) on the
[Server Code Submissions](http://www.eqemulator.org/forums/forumdisplay.php?f=669)
forum, although pull requests will be much quicker and easier on all parties.

## Contact <img src="http://gamerescape.com/wp-content/uploads/2015/06/discord.png" height="20">

 - Discord Channel: https://discord.gg/QHsm7CD
 - **User Discord Channel**: `#general`
 - **Developer Discord Channel**: `#eqemucoders`

## Resources
- [EQEmulator Forums](http://www.eqemulator.org/forums)
- [EQEmulator Wiki](https://docs.eqemu.io/)

## Related Repositories
* [ProjectEQ Quests](https://github.com/ProjectEQ/projecteqquests)
* [Maps](https://github.com/Akkadius/EQEmuMaps)
* [Installer Resources](https://github.com/Akkadius/EQEmuInstall)
* [Zone Utilities](https://github.com/EQEmu/zone-utilities) - Various utilities and libraries for parsing, rendering and manipulating EQ Zone files.

## Other License Info

* The server code and utilities are released under **GPLv3**
* We also include some small libraries for convienence that may be under different licensing
  * SocketLib - GPL LibXML
  * zlib - zlib license
  * MariaDB/MySQL - GPL
  * GPL Perl - GPL / ActiveState (under the assumption that this is a free project)
  * CPPUnit - GLP StringUtilities - Apache
  * LUA - MIT

## Contributors

<a href="https://github.com/EQEmu/server/graphs/contributors">
  <img src="https://contributors-img.firebaseapp.com/image?repo=EQEmu/server" />
</a>

