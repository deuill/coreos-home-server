# Introduction

Welcome to the documentation for Fedora CoreOS Home-Server, a collection of scaffolding for a single-node, low-maintenance, home-server based on [Fedora CoreOS][fedora-coreos], and hosting numerous services (mail-server, XMPP server, ActivityPub server, calendaring, etc.)

This documentation is split into two major sections, describing host and service setup, respectively. For the most part, hosts and services are expected to require a minimal amount of setup and custom configuration; however, both are designed with extensibility in mind, and deployments are assumed to use these affordances where needed.

## What is Fedora CoreOS?

Fedora CoreOS is a minimal, server-oriented Linux distribution released and maintained by Red Hat, similar to other "flavours" of Fedora. Specifically, Fedora CoreOS differentiates itself by integrating with [Ignition][ignition], which allows for specifying initial server state as configuration, and for being immutable and auto-updating.

What this essentially means is that you're expected to deploy servers, as defined in static configuration, with Ignition (in a non-interactive way) and never modify their configuration again once deployed.

## What is CoreOS Home-Server?

The CoreOS Home-Server setup described here emerged as a set of [Butane][butane]/Ignition and accompanying [Podman][podman] and [systemd][systemd] configuration files used for the author's own home-server -- this being an evolution from earlier Kubernetes-based experiments.

The principal goals imprinted onto the design are:

  - Allow for the full, unattended deployment of a home-server in as simple and repeatable a process as possible; don't require manual tinkering post-install for bringing the system up to full working order.

  - Require the least amount of day-to-day care and maintenance. The system should, ideally, auto-apply both distribution-level and service level updates, and doesn't come with tooling beyond what's provided by systemd and Podman for service management.

  - Remain as self-contained and observable as possible; Podman containers are built from scratch where possible, service version updates are handled explicitly through embedded configuration, and proper working order is ensured through metrics and alerting.

  - Prefer simple over complex; secrets management is handled via simple environment files, services are managed and extended via mechanisms built into systemd, and all user-defined server configuration is concentrated in the `/etc/coreos-home-server` directory.

The end-result *should* be a system that is easy to comprehend and track the health of, and which can, to a large degree, be left alone for as long as the hardware itself allows for.

## Where do I start?

For a quick introduction to setting up your own CoreOS Home-Server test environment locally, check the [Virtual Environment][virtual-environment] section of the documentation, otherwise, proceed to the [Setting up a a New Host][host-setup] section of the documentation. For an overview of included services, as well as more information on how to set up a new service, check out the [Services][services] section of the documentation.

[fedora-coreos]: https://
[ignition]: https://
[butane]: https://
[podman]: https://
[systemd]: https://
[virtual-environment]: host/virtual
[host-setup]: host
[services]: service
