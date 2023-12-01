# CoreOS Service Configuration

This directory contains a set of common services available for deployment onto a CoreOS Home Server
setup, and managed via systemd and Podman. Each service is given its own subdirectory, and each
follows a set of common conventions in laying out its files.

Specifically, for a service `example`, we might find the following files and directories under the
corresponding directory:

  - `spec.bu` -- This file is typically included by the host configuration, and is intended with
    installing any additional service files required for enabling the service.

  - `Containerfile` -- This file is used in building a container image, handled by the
    `container-build@example` service and presumably used in the systemd file for the `example`
    service.

  - `example.env.template` -- An optional file containing `KEY=value` definitions that can then be
    used in the systemd service. Host-wide environment is also available in this context, and can be
    used in expanding shared configuration, secrets, etc. This file is used by the
    `container-environment@example` service.

  - `systemd/` -- This directory contains systemd configuration, to be copied into the host-wide
    `/etc/systemd/system` directory. You'll typically find things like `example.service` files
    which run the service under Podman, as well as potential one-off services which copy files
    around in pre-existing Podman containers.

  - `quadlet/` -- This directory contains configuration for
    [Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html), aka
    `podman-systemd.unit`, which allows for generating comprehensive Systemd configuration from more
    idiomatic templates. Most services will be found as `example.container` files, installed under
    `/etc/containers/systemd` in running systems.

  - `container/` -- This directory contains any static files included in the Podman image, including
    templated configuration, scripts, etc.

  - `service/` -- This (largely optional) directory contains files required by the systemd services
    themselves, and which are not included in the Podman images by default; examples include
    database migration files, one-off configuration files, etc.

Of all these files, the only ones whose paths are mandated by external services are the
`Containerfile` and `<name>.env.template` files, neither of which are required by anything other
than convention (i.e. you can choose not to build a container image via the systemd service).

Each service here might have additional details on how it's expected to be deployed and used, check
the respective `README.md` files for more information.
