# 📱 libimobiledevice in Docker

Build and run the latest upstream **libimobiledevice** stack inside an Ubuntu Docker container without installing the source-built libraries and utilities directly on the host.

This project is intended for experimentation, development, and demonstrations where you want to compare Ubuntu's packaged version of libimobiledevice with the latest version built directly from upstream source.

# 🐳 Why Docker?

If you're working with an iPhone or iPad on Ubuntu, you may want to experiment with the latest version of libimobiledevice without replacing or modifying the packages installed on your host system.

A virtual machine isn't ideal for this use case because USB device passthrough can make working with an iPhone considerably more complicated.

Docker gives us a useful middle ground:

```text
┌───────────────────────────────────────────────┐
│ Ubuntu Host                                   │
│                                               │
│  iPhone ──USB──> usbmuxd                      │
│                    │                          │
│                    │ /var/run/usbmuxd         │
│                    ▼                          │
│          ┌───────────────────────┐             │
│          │ Docker Container      │             │
│          │                       │             │
│          │ libimobiledevice      │             │
│          │ ideviceinfo           │             │
│          │ idevice_id            │             │
│          │ idevicepair           │             │
│          │ idevicebackup2        │             │
│          └───────────────────────┘             │
└───────────────────────────────────────────────┘
```

The host continues to handle the physical USB connection and `usbmuxd`. The Docker container uses the host's `usbmuxd` Unix socket to communicate with the device.

This means we don't need to pass the physical USB device directly into the container.

# 🔨 What Gets Built?

The Dockerfile builds the current upstream versions of the libimobiledevice dependency stack:

- 📦 [libplist](https://github.com/libimobiledevice/libplist)
- 🔗 [libimobiledevice-glue](https://github.com/libimobiledevice/libimobiledevice-glue)
- 🔌 [libusbmuxd](https://github.com/libimobiledevice/libusbmuxd)
- 🔐 [libtatsu](https://github.com/libimobiledevice/libtatsu)
- 📱 [libimobiledevice](https://github.com/libimobiledevice/libimobiledevice)

Everything is installed under:

```text
/opt/libimobiledevice
```

The Docker image automatically adds:

```text
/opt/libimobiledevice/bin
```

to `PATH`.

As a result, tools such as `ideviceinfo` and `idevice_id` can be run directly without manually exporting environment variables.

# 📋 Requirements

The host needs:

- 🐧 Linux
- 🐳 Docker
- 🔌 A working `usbmuxd` installation
- 📱 An iPhone or iPad connected over USB

Ubuntu 24.04 is used as the base image.

# 🔌 Verify usbmuxd on the Host

Before using the container, make sure the host can see the device.

For example:

```bash
idevice_id -l
```

If your host already has libimobiledevice installed, this should display the device UDID.

You can also check that the usbmuxd socket exists:

```bash
ls -l /var/run/usbmuxd
```

The important part for this project is that the host has a working:

```text
/var/run/usbmuxd
```

socket.

# 🏗️ Build the Docker Image

Clone this repository and change into the project directory:

```bash
git clone https://github.com/DouglasFreshHabian/iOS
cd libimobiledevice-docker
```

Build the image:

```bash
docker build -t libimobiledevice-docker .
```

The Dockerfile downloads the current upstream source repositories and compiles them.

The first build may take several minutes.

# 🚀 Run the Container

Start the container with the host's `usbmuxd` socket mounted:

```bash
docker run -it --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

You should now be inside the container.

# ✅ Verify the Installation

Check where the tools are coming from:

```bash
which ideviceinfo
```

Expected:

```text
/opt/libimobiledevice/bin/ideviceinfo
```

Check the version:

```bash
ideviceinfo --version
```

Check for connected devices:

```bash
idevice_id -l
```

You should see the UDID of the connected device.

For example:

```text
00008110-001200A92E63801E
```

You can also test:

```bash
idevicepair validate
```

and:

```bash
idevicebackup2 --version
```

# ⚡ Running Individual Commands Without Opening a Shell

You don't have to start an interactive shell every time.

For example:

```bash
docker run --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker \
    ideviceinfo
```

Or:

```bash
docker run --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker \
    idevice_id -l
```

This is useful for scripting.

# 🔄 Updating to the Latest Upstream Code

The Dockerfile uses shallow Git clones:

```bash
git clone --depth 1
```

This means a new Docker build retrieves the current tip of each upstream repository.

To rebuild using fresh source:

```bash
docker build --no-cache -t libimobiledevice-docker .
```

Then run the newly built image:

```bash
docker run -it --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

### 🤔 Why `--no-cache`?

Without `--no-cache`, Docker may reuse previously completed build layers.

Using:

```bash
docker build --no-cache ...
```

forces Docker to execute the source download and compilation steps again.

This is useful when you specifically want to test the latest upstream code.

# 🆚 Comparing Ubuntu's Version With Upstream

One of the reasons for this project is to experiment with the difference between the distribution-provided version and the current upstream version.

On Ubuntu, you can inspect the packaged version with:

```bash
apt policy libimobiledevice6
```

and related packages.

The Docker image, on the other hand, contains versions compiled directly from the upstream Git repositories.

For example:

```bash
ideviceinfo --version
```

inside the container reports the source-built version.

This makes it possible to experiment with newer functionality without replacing the Ubuntu packages on the host.

# 🐍 Why Not a Python Virtual Environment?

A Python virtual environment such as:

```bash
python3 -m venv .venv
```

isolates Python packages.

libimobiledevice is not a Python package. It is primarily a collection of native C libraries and command-line utilities.

Therefore, a Python virtual environment doesn't isolate the things we actually want to isolate:

- 📚 shared libraries
- ⚙️ native executables
- 🧩 system dependencies
- 🛠️ compiler/build dependencies
- 🔎 library search paths

Docker provides the appropriate level of isolation for this experiment.

# 💻 Why Not a Virtual Machine?

A VM would provide stronger isolation, but it also introduces another layer between the physical USB device and libimobiledevice.

For iPhone/iPad work, USB connectivity is particularly important.

With this Docker setup:

```text
iPhone
   │
   │ USB
   ▼
Ubuntu host
   │
   │ usbmuxd socket
   ▼
Docker container
   │
   ▼
libimobiledevice
```

The host retains responsibility for the physical USB connection while the container isolates the libimobiledevice installation.

# 📦 Persistent Development Container

The examples above use:

```text
--rm
```

which removes the container when it exits.

For development, you may instead want a persistent container:

```bash
docker run -it \
    --name libimobiledevice-source \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

After exiting, the container still exists.

List it with:

```bash
docker ps -a
```

Start it again:

```bash
docker start libimobiledevice-source
```

Then open a new shell inside it:

```bash
docker exec -it libimobiledevice-source bash
```

# 🏛️ Architecture

The important part of this setup is that Docker is **not** handling the physical USB device directly.

Instead:

```text
                  Physical USB
                     │
                     ▼
               ┌─────────────┐
               │ Ubuntu host │
               │             │
               │   usbmuxd   │
               └──────┬──────┘
                      │
                 Unix socket
            /var/run/usbmuxd
                      │
                      ▼
           ┌─────────────────────┐
           │ Docker container    │
           │                     │
           │ libimobiledevice    │
           │                     │
           │ idevice_id          │
           │ ideviceinfo         │
           │ idevicepair         │
           │ idevicebackup2      │
           └─────────────────────┘
```

The container therefore doesn't need direct access to `/dev/bus/usb`.

# 🩺 Troubleshooting

### `idevice_id: command not found`

Check:

```bash
echo "$PATH"
```

It should contain:

```text
/opt/libimobiledevice/bin
```

Also check:

```bash
ls -l /opt/libimobiledevice/bin/
```

The Dockerfile sets the environment automatically, so if the image was built from the current Dockerfile, manually exporting `PATH` should not be necessary.

### 📱 The Device Isn't Detected

First check the host:

```bash
ls -l /var/run/usbmuxd
```

Then make sure the socket is mounted into the container:

```bash
ls -l /var/run/usbmuxd
```

inside the container.

Try:

```bash
idevice_id -l
```

If the host's usbmuxd isn't running correctly, the container won't be able to communicate with the phone.

### 🔨 Rebuild From Scratch

If you're unsure whether Docker is reusing an old build layer:

```bash
docker build --no-cache -t libimobiledevice-docker .
```

# 🔐 Security Considerations

The container is given access to the host's `usbmuxd` socket:

```bash
-v /var/run/usbmuxd:/var/run/usbmuxd
```

That is intentional and is what allows the containerized libimobiledevice tools to communicate with the host's device-management service.

Do not treat the container as a completely isolated environment once host resources such as sockets are explicitly shared with it.

# 🎯 Project Goals

This project is primarily an educational and experimental setup.

It demonstrates how to:

1. 🔨 Build a native Linux project directly from upstream Git.
2. 📦 Keep that installation isolated from the host.
3. 🐳 Use Docker without requiring direct USB passthrough.
4. 🔗 Share a Unix socket between the host and container.
5. 🆚 Compare distribution packages with current upstream software.
6. ♻️ Reproduce the build environment from a Dockerfile.

# 🎥 Livestream Walkthrough

A useful way to demonstrate this project is to build it incrementally:

### 📦 Part 1 — Ubuntu Package

Start with the normal Ubuntu installation:

```bash
apt install libimobiledevice-utils
```

Check:

```bash
ideviceinfo --version
```

### 🔨 Part 2 — Source Build

Build libimobiledevice directly from upstream source inside an Ubuntu container.

Compare:

```bash
ideviceinfo --version
```

and:

```bash
idevicebackup2 --version
```

This demonstrates the difference between the distribution package and the current upstream code.

### 🐳 Part 3 — Dockerfile

Turn the manual build process into a Dockerfile:

```bash
docker build -t libimobiledevice-docker .
```

Now the entire build becomes reproducible.

### 🔌 Part 4 — USB Communication

Run:

```bash
docker run -it --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

Then:

```bash
idevice_id -l
```

This demonstrates that the container doesn't need direct USB passthrough.

### 🔄 Part 5 — Rebuilding

Finally, demonstrate:

```bash
docker build --no-cache -t libimobiledevice-docker .
```

to retrieve and compile the latest upstream code again.

---

# 📜 License

This repository contains a Dockerfile and build configuration for projects maintained by the libimobiledevice project.

The software built by this Dockerfile remains subject to the licenses of its respective upstream projects.

---

<!-- 
    Fresh Forensics, LLC | Douglas Fresh Habian | 2026
    github.com/DouglasFreshHabian
    freshforensicsllc@tuta.com
-->
