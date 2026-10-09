# 📱 iOS Forensics & Mobile Device Toolkit

A collection of commands and tools for **iOS device forensics, system monitoring, encrypted backup analysis, application inspection, crash report extraction, and password hash auditing** using Linux.

## 📑 Table of Contents

- [🖥️ System Monitoring](#️-system-monitoring)
- [🐳 Installing Docker](#-installing-docker)
- [🔬 Installing Mobile Verification Toolkit (MVT)](#-installing-mobile-verification-toolkit-mvt)
- [🔐 Encrypted iOS Backups](#-encrypted-ios-backups)
- [📂 AFC File System Access](#-afc-file-system-access)
- [🔗 Pairing and Device Information](#-pairing-and-device-information)
- [🛠️ Troubleshooting Pairing Issues](#️-troubleshooting-pairing-issues)
- [📡 iOS System Logs](#-ios-system-logs)
- [📲 Device Management](#-device-management)
- [📦 Installed Applications](#-installed-applications)
- [🔵 Bluetooth Extended Logging](#-bluetooth-extended-logging)
- [🧰 Additional pymobiledevice3 Commands](#-additional-pymobiledevice3-commands)
- [💥 Crash Report Extraction](#-crash-report-extraction)
- [🔑 Backup Password Hash Extraction](#-backup-password-hash-extraction)
- [🔓 Password Hash Auditing with Hashcat](#-password-hash-auditing-with-hashcat)
- [🐳 Running MVT with Docker](#-running-mvt-with-docker)
- [⚠️ Notes and Best Practices](#️-notes-and-best-practices)
- [📚 References](#-references)

---

## 🖥️ System Monitoring

Monitor kernel messages and connected USB devices.

### Monitor kernel messages in real time

```
sudo dmesg -w

```

### List connected USB devices

```
lsusb

```

---

## 🐳 Installing Docker

Install Docker and the Compose plugin on Debian/Ubuntu-based systems.

```
sudo apt update
sudo apt install docker.io docker-clean docker-compose-v2

```

Additional Docker packages used in some setups:

```
sudo apt install docker.io docker-buildx docker-clean

```

Verify the installation:

```
docker --version
docker compose version

```

---

## 🔬 Installing Mobile Verification Toolkit (MVT)

MVT is an open-source toolkit for examining mobile device backups and identifying indicators associated with spyware and other threats.

📚 **Official documentation:** https\://docs.mvt.re/en/latest/install/

### 1. Install dependencies

```
sudo apt update
sudo apt install python3 python3-venv python3-pip sqlite3 libusb-1.0-0

```

### 2. Install using pipx (recommended)

Install pipx:

```
sudo apt install pipx
pipx ensurepath

```

Install or upgrade MVT:

```
pipx install mvt
pipx upgrade mvt

```

> 💡 If you have not installed MVT yet, use `pipx install mvt`. Use `pipx upgrade mvt` for subsequent upgrades.

### 3. Install using Python virtual environments

Create and activate a virtual environment:

```
sudo apt install python3 python3-venv

python3 -m venv mvtEnvironment
source mvtEnvironment/bin/activate

```

Install MVT:

```
pip install mvt

```

When finished, deactivate the environment:

```
deactivate

```

### 4. Enable Bash autocompletion

```
mvt completion bash --install

```

---

## 🔐 Encrypted iOS Backups

Use `idevicebackup2` to manage iOS backups on a paired device.

### Enable backup encryption

```
idevicebackup2 -i encryption on

```

Follow the interactive prompts to configure encryption.

### Create a full backup in the current directory

```
idevicebackup2 backup --full .

```

### Create a full backup in a specified directory

```
idevicebackup2 backup --full /PATH/TO/BACKUP

```

> ⚠️ Replace `/PATH/TO/BACKUP` with your intended backup directory. Keep the backup password secure; losing it may prevent access to encrypted backup contents.

---

## 📂 AFC File System Access

Use `afcclient` to interact with the device's Apple File Conduit (AFC) service when supported and accessible.

### Start the AFC shell

```
afcclient

```

### Display device information

```
afcclient devinfo

```

### List files and directories

```
afcclient ls
afcclient ls DCIM/100APPLE/

```

### Inspect file information

```
afcclient info DCIM/100APPLE/IMG_0001.HEIC

```

### Download a file from the device

```
afcclient get DCIM/100APPLE/IMG_0001.HEIC

```

### Upload a file to the device

```
afcclient put pic.png DCIM/100APPLE/

```

> 📌 File access depends on the device, its iOS version, pairing state, and available AFC service permissions.

---

## 🔗 Pairing and Device Information

Use `libimobiledevice` utilities to inspect device details and check pairing status.

### Display basic device information

```
ideviceinfo -s

```

### List paired devices

```
idevicepair list

```

### Validate pairing

```
idevicepair validate

```

### Query a specific device property

```
ideviceinfo -k ProductVersion

```

Example output:

```
16.3.1

```

The output depends on the connected device's iOS version.

### Query a specific service domain

```
ideviceinfo -q com.apple.mobile.battery

```

This queries the specified domain when supported by the installed tool version and device.

---

## 🛠️ Troubleshooting Pairing Issues

Check the status of the USB multiplexing service (`usbmuxd`):

```
sudo systemctl status usbmuxd

```

Restart the service if necessary:

```
sudo systemctl stop usbmuxd
sudo systemctl start usbmuxd

```

Then reconnect the device and validate pairing again:

```
idevicepair validate

```

> 💡 Make sure the iPhone is unlocked when required, trust prompts have been accepted, and the USB connection is working.

---

## 📡 iOS System Logs

Use `idevicesyslog` to stream device logs and filter output.

### Stream live system logs

```
idevicesyslog

```

### List available process IDs

```
idevicesyslog pidlist

```

### Filter logs by process name

```
idevicesyslog -p wifid

```

The `wifid` filter can help inspect log messages associated with the Wi-Fi daemon.

---

## 📲 Device Management

### Change the device name

```
idevicename Fresh

```

This attempts to change the device name to `Fresh`.

### Shut down the device

```
idevicediagnostics shutdown

```

### Restart the device

```
idevicediagnostics restart

```

> ⚠️ Shutdown and restart commands interrupt device activity. Use them only when appropriate for your investigation.

---

## 📦 Installed Applications

### Install `ideviceinstaller`

Search for the package:

```
apt search ideviceinstaller

```

Install it:

```
sudo apt install ideviceinstaller

```

### List all installed applications

```
ideviceinstaller list --all

```

### List applications using pymobiledevice3

```
pymobiledevice3 apps list

```

---

## 🔵 Bluetooth Extended Logging

For Bluetooth troubleshooting or extended logging, begin by checking available device logging capabilities.

### Inspect device connectivity

```
pymobiledevice3 usbmux list

```

### Stream live logs

```
pymobiledevice3 syslog live

```

> 📌 These commands provide device connectivity and log access. Enabling Bluetooth-specific extended logging may require additional configuration depending on the iOS version, device capabilities, and available developer or diagnostic services.

---

## 🧰 Additional pymobiledevice3 Commands

### List connected devices

```
pymobiledevice3 usbmux list

```

### Stream live system logs

```
pymobiledevice3 syslog live

```

### List installed applications

```
pymobiledevice3 apps list

```

### Display Lockdown information

```
pymobiledevice3 lockdown info

```

### Pair with a device

```
pymobiledevice3 lockdown pair

```

Follow any prompts displayed by the tool.

---

## 💥 Crash Report Extraction

Extract crash reports using `idevicecrashreport`:

```
idevicecrashreport -e -k .

```

This uses the current directory as the destination for extracted reports.

Review the resulting files for relevant timestamps, process names, crash details, and other investigation artifacts.

---

## 🔑 Backup Password Hash Extraction

The following commands illustrate the preparation of backup password hashes for authorized password recovery and security auditing.

### Generate a Hashcat-compatible hash

```
./itunes_backup2hashcat ../../manifest.plist

```

The exact input file and utility version may affect whether hash extraction succeeds.

### Identify hash formats

```
hashid

```

Use the resulting hash format information to select an appropriate auditing tool and mode.

---

## 🔓 Password Hash Auditing with Hashcat

Use Hashcat only on password hashes you own or are explicitly authorized to audit.

### Audit an iTunes backup password hash

```
hashcat -m 14800 -a 0 --force hash.txt passwords.txt

```

- `-m 14800` — selects the Hashcat mode commonly associated with legacy iTunes backup password hashes.
- `-a 0` — selects dictionary attack mode.
- `hash.txt` — contains the hash to audit.
- `passwords.txt` — contains candidate passwords.
- `--force` — bypasses certain warnings; it is generally better to resolve compatibility issues rather than use it routinely.

**Verify the hash mode against your Hashcat version and the extracted hash format before running an audit.**

### Display recovered passwords

```
hashcat -m 14800 hash.txt --show

```

### Inspect the Hashcat potfile

```
cat /home/fresh/.local/share/hashcat/hashcat.potfile

```

The potfile stores previously recovered hashes and their corresponding plaintexts. Protect it as sensitive data.

### Dictionary attack against a general MD5 hash

```
hashcat -a 0 -m 0 hash.txt rockyou.txt

```

### Dictionary attack with rules

```
hashcat -a 0 -m 0 hash.txt rockyou.txt -r rules/best64.rule

```

- `-m 0` — selects raw MD5.
- `rockyou.txt` — the dictionary file.
- `-r rules/best64.rule` — applies candidate password transformations from the specified rule file.

> ⚠️ **Important:** Hashcat mode `0` is for raw MD5 hashes, not iTunes backup hashes. Select the mode that matches the actual hash format.

---

## 🐳 Running MVT with Docker

Docker can be used to run MVT in an isolated container while exposing a host directory containing an iOS backup.

### 1. Install Docker

```
sudo apt update
sudo apt install docker.io docker-buildx docker-clean

```

### 2. Start an interactive MVT container

```
docker run -it --rm \
  -v /home/fresh/iOS/Backup/:/mnt \
  ghcr.io/mvt-project/mvt \
  /bin/bash

```

Command breakdown:

- `-it` — starts an interactive terminal.
- `--rm` — removes the container when it exits.
- `-v /home/fresh/iOS/Backup/:/mnt` — mounts the host backup directory at `/mnt` inside the container.
- `ghcr.io/mvt-project/mvt` — the MVT container image.

### 3. Inspect the mounted backup

Inside the container:

```
ls /mnt

```

Identify the correct backup directory before proceeding.

### 4. Decrypt an encrypted backup

```
mvt-ios decrypt-backup \
  -p "Password" \
  -d /home/cases/ \
  /mnt/00000-0000000/

```

Replace the example password, destination, and backup directory with the appropriate values for your case.

**Parameter overview:**

- `-p` — supplies the backup password.
- `-d` — specifies the output directory for decrypted backup data.
- The final argument — identifies the source backup directory.

> 🔐 Avoid placing real passwords directly in shell history or shared documentation. Use a secure method to provide credentials, and restrict access to decrypted output.

---

## ⚠️ Notes and Best Practices

- 🔒 **Authorization:** Examine only devices and backups you own or have explicit permission to investigate.
- 🧾 **Evidence preservation:** Keep an original copy of the backup unchanged and perform analysis on a working copy.
- 🔐 **Sensitive data:** Backups, crash reports, logs, pairing records, and Hashcat potfiles can contain private information. Store them securely.
- 🧰 **Tool compatibility:** Command syntax and available functionality may vary across versions of iOS, `libimobiledevice`, `pymobiledevice3`, MVT, and Hashcat.
- 🐳 **Docker permissions:** Mounted directories retain host-side permissions and may expose sensitive files to the container.
- 📝 **Documentation:** Record tool versions, timestamps, commands, and relevant output to make investigations reproducible.

---

## 📚 References

- [Mobile Verification Toolkit (MVT) Documentation](https://docs.mvt.re/en/latest/install/)
- [MVT GitHub Repository](https://github.com/mvt-project/mvt)
- [libimobiledevice GitHub Repository](https://github.com/libimobiledevice/libimobiledevice)
- [pymobiledevice3 GitHub Repository](https://github.com/doronz88/pymobiledevice3)
- [Hashcat Documentation](https://hashcat.net/wiki/)
- [Docker Documentation](https://docs.docker.com/)

---

⭐ **Tip:** Keep this README updated as you validate commands against your installed tool versions and testing environment.
