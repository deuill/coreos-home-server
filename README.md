# CoreOS Home Server Setup

This repository contains support files for deploying a simple server setup based on Fedora CoreOS,
and mainly based around [systemd](https://systemd.io) and [Podman](https://podman.io).

## Pre-requisites

Effective use of the source-files here requires that you have the following dependencies installed
on your host:

  - `gpg` for secret management and image validation.
  - `butane` for rendering out host and service configuration.
  - `virsh` and `virt-install` with `qemu` for virtual host testing.

All of the requirements are checked during the various Makefile invocations, and will return fatal
errors unless fulfilled. In addition to the aforementioned build-time dependencies, the build host
needs the following setup procedures performed:

### Import GPG key for image validation:

This is required for validating the signatures for installation media when deploying bare-metal and
virtual hosts:

```sh
curl https://getfedora.org/static/fedora.gpg | gpg --import
```

## Setup and Deployment

Initial server deployment is managed by the included Makefile, which also allows for testing against
a virtualized environment. Configuration for virtual and physical servers is managed by [Fedora
CoreOS configuration](https://coreos.github.io/butane/) (*aka* Butane) files, which will typically
define host-specific configuration, and merge in additional, standard configuration; check the
[virtual host configuration](host/virtual/spec.bu) for an example.

You can prepare host configuration for consumption by using the `deploy` target for the included
Makefile, e.g.:

```
make deploy HOST=example
```

This will compile the host-specific `host/example/spec.bu` file to its corresponding Ignition format
via the `butane` utility (which is expected to be installed on the system), and serve the final
result over HTTP on the local network. This, of course, assumes that you'll be installing on [bare
metal](https://docs.fedoraproject.org/en-US/fedora-coreos/bare-metal/) on a system on your local
network -- support for additional targets may be added in the future.

## Testing

A virtual host is included for development and testing; using this requires that you have `virsh`
and `virt-install` installed on your system. Using the virtual environment is simple:

```
make deploy-virtual
```

This will automatically download the Fedora CoreOS image for the `VERSION` specified in the
Makefile, compile included Butane files, and start a virtual machine on the terminal running the
`make` command. If you want to see the various command run under the hood, add the `VERBOSE=1`
parameter to the `make` invocation.

By default, you can use the `<Ctrl>]` key-combination to escape the virtual machine, and can use the
`make destroy-virtual` command to drop any resources initialized for the virtual host.

## Services

In addition to host-specific configuration, servers will typically include a number of services,
managed by `systemd` and `podman`. These are intended to be deployed via Ignition on server setup,
but also be managed throughout the server's life-cycle.

The mechanisms for building and deploying services are simple and fairly consistent. Firstly, Podman
containers and systemd services are built and enabled using the included `container-build` systemd
service. This will read files from `/etc/coreos-home-server` (copied onto the server during
deployment) and build container images and systemd service definitions as needed.

## License

All code in this repository is covered by the terms of the MIT License, the full text of which can be found in the LICENSE file.
