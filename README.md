# libimobiledevice in Docker

 Build and run the latest upstream **libimobiledevice** stack inside an Ubuntu Docker container without installing the source-built libraries and utilities directly on the host.

 This project is intended for experimentation, development, and demonstrations where you want to compare Ubuntu's packaged version of libimobiledevice with the latest version built directly from upstream source.

 ## Why Docker?

 If you're working with an iPhone or iPad on Ubuntu, you may want to experiment with the latest version of libimobiledevice without replacing or modifying the packages installed on your host system.

 A virtual machine isn't ideal for this use case because USB device passthrough can make working with an iPhone considerably more complicated.

 Docker gives us a useful middle ground:

```
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

## What gets built?

The Dockerfile builds the current upstream versions of the libimobiledevice dependency stack:

- [libplist](<https://github.com/libimobiledevice/libplist>)
- [libimobiledevice-glue](<https://github.com/libimobiledevice/libimobiledevice-glue>)
- [libusbmuxd](<https://github.com/libimobiledevice/libusbmuxd>)
- [libtatsu](<https://github.com/libimobiledevice/libtatsu>)
- [libimobiledevice](<https://github.com/libimobiledevice/libimobiledevice>)

 Everything is installed under:

```
/opt/libimobiledevice
```

 The Docker image automatically adds:

```
/opt/libimobiledevice/bin
```

 to `PATH`.

 As a result, tools such as `ideviceinfo` and `idevice_id` can be run directly without manually exporting environment variables.

 ## Requirements

 The host needs:

 - Linux
- Docker
- A working `usbmuxd` installation
- An iPhone or iPad connected over USB

 Ubuntu 24.04 is used as the base image.

 ## Verify usbmuxd on the host

 Before using the container, make sure the host can see the device.

 For example:

```
idevice_id -l
```

 If your host already has libimobiledevice installed, this should display the device UDID.

 You can also check that the usbmuxd socket exists:

```
ls -l /var/run/usbmuxd
```

 The important part for this project is that the host has a working:

```
/var/run/usbmuxd
```

 socket.

 ## Build the Docker image

 Clone this repository and change into the project directory:

```
git clone <your-repository-url>
cd libimobiledevice-docker
```

 Build the image:

```
docker build -t libimobiledevice-docker .
```

 The Dockerfile downloads the current upstream source repositories and compiles them.

 The first build may take several minutes.

 ## Run the container

 Start the container with the host's `usbmuxd` socket mounted:

```
docker run -it --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

 You should now be inside the container.

 ## Verify the installation

 Check where the tools are coming from:

```
which ideviceinfo
```

 Expected:

```
/opt/libimobiledevice/bin/ideviceinfo
```

 Check the version:

```
ideviceinfo --version
```

 Check for connected devices:

```
idevice_id -l
```

 You should see the UDID of the connected device.

 For example:

```
00008110-001200A92E63801E
```

 You can also test:

```
idevicepair validate
```

 and:

```
idevicebackup2 --version
```

 ## Running individual commands without opening a shell

 You don't have to start an interactive shell every time.

 For example:

```
docker run --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker \
    ideviceinfo
```

 Or:

```
docker run --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker \
    idevice_id -l
```

 This is useful for scripting.

 ## Updating to the latest upstream code

 The Dockerfile uses shallow Git clones:

```
git clone --depth 1
```

 This means a new Docker build retrieves the current tip of each upstream repository.

 To rebuild using fresh source:

```
docker build --no-cache -t libimobiledevice-docker .
```

 Then run the newly built image:

```
docker run -it --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

 ### Why `--no-cache`?

 Without `--no-cache`, Docker may reuse previously completed build layers.

 Using:

```
docker build --no-cache ...
```

 forces Docker to execute the source download and compilation steps again.

 This is useful when you specifically want to test the latest upstream code.

 ## Comparing Ubuntu's version with upstream

 One of the reasons for this project is to experiment with the difference between the distribution-provided version and the current upstream version.

 On Ubuntu, you can inspect the packaged version with:

```
apt policy libimobiledevice6
```

 and related packages.

 The Docker image, on the other hand, contains versions compiled directly from the upstream Git repositories.

 For example:

```
ideviceinfo --version
```

 inside the container reports the source-built version.

 This makes it possible to experiment with newer functionality without replacing the Ubuntu packages on the host.

 ## Why not a Python virtual environment?

 A Python virtual environment such as:

```
python3 -m venv .venv
```

 isolates Python packages.

 libimobiledevice is not a Python package. It is primarily a collection of native C libraries and command-line utilities.

 Therefore, a Python virtual environment doesn't isolate the things we actually want to isolate:

 - shared libraries
- native executables
- system dependencies
- compiler/build dependencies
- library search paths

 Docker provides the appropriate level of isolation for this experiment.

 ## Why not a virtual machine?

 A VM would provide stronger isolation, but it also introduces another layer between the physical USB device and libimobiledevice.

 For iPhone/iPad work, USB connectivity is particularly important.

 With this Docker setup:

```
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

 ## Persistent development container

 The examples above use:

```
--rm
```

 which removes the container when it exits.

 For development, you may instead want a persistent container:

```
docker run -it \
    --name libimobiledevice-source \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

 After exiting, the container still exists.

 List it with:

```
docker ps -a
```

 Start it again:

```
docker start libimobiledevice-source
```

 Then open a new shell inside it:

```
docker exec -it libimobiledevice-source bash
```

 ## Architecture

 The important part of this setup is that Docker is **not** handling the physical USB device directly.

 Instead:

```
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

 ## Troubleshooting

 ### `idevice_id: command not found`

 Check:

```
echo "$PATH"
```

 It should contain:

```
/opt/libimobiledevice/bin
```

 Also check:

```
ls -l /opt/libimobiledevice/bin/
```

 The Dockerfile sets the environment automatically, so if the image was built from the current Dockerfile, manually exporting `PATH` should not be necessary.

 ### The device isn't detected

 First check the host:

```
ls -l /var/run/usbmuxd
```

 Then make sure the socket is mounted into the container:

```
ls -l /var/run/usbmuxd
```

 inside the container.

 Try:

```
idevice_id -l
```

 If the host's usbmuxd isn't running correctly, the container won't be able to communicate with the phone.

 ### Rebuild from scratch

 If you're unsure whether Docker is reusing an old build layer:

```
docker build --no-cache -t libimobiledevice-docker .
```

 ## Security considerations

 The container is given access to the host's `usbmuxd` socket:

```
-v /var/run/usbmuxd:/var/run/usbmuxd
```

That is intentional and is what allows the containerized libimobiledevice tools to communicate with the host's device-management service.

Do not treat the container as a completely isolated environment once host resources such as sockets are explicitly shared with it.

## Project goals

This project is primarily an educational and experimental setup.

It demonstrates how to:

1. Build a native Linux project directly from upstream Git.
2. Keep that installation isolated from the host.
3. Use Docker without requiring direct USB passthrough.
4. Share a Unix socket between the host and container.
5. Compare distribution packages with current upstream software.
6. Reproduce the build environment from a Dockerfile.

## Livestream walkthrough

 A useful way to demonstrate this project is to build it incrementally:

 ### Part 1 — Ubuntu package

 Start with the normal Ubuntu installation:

```
apt install libimobiledevice-utils
```

 Check:

```
ideviceinfo --version
```

 ### Part 2 — Source build

 Build libimobiledevice directly from upstream source inside an Ubuntu container.

 Compare:

```
ideviceinfo --version
```

 and:

```
idevicebackup2 --version
```

 This demonstrates the difference between the distribution package and the current upstream code.

 ### Part 3 — Dockerfile

 Turn the manual build process into a Dockerfile:

```
docker build -t libimobiledevice-docker .
```

 Now the entire build becomes reproducible.

 ### Part 4 — USB communication

 Run:

```
docker run -it --rm \
    -v /var/run/usbmuxd:/var/run/usbmuxd \
    libimobiledevice-docker
```

 Then:

```
idevice_id -l
```

 This demonstrates that the container doesn't need direct USB passthrough.

 ### Part 5 — Rebuilding

 Finally, demonstrate:

```
docker build --no-cache -t libimobiledevice-docker .
```

 to retrieve and compile the latest upstream code again.

---

 ## License

 This repository contains a Dockerfile and build configuration for projects maintained by the libimobiledevice project.

 The software built by this Dockerfile remains subject to the licenses of its respective upstream projects.
