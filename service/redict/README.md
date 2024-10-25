# Redict

This directory contains a simple systemd service for running a disk-backed instance of Redict.

## Deployment

Including the `spec.bu` file here in your host configuration is enough to have Redict enabled on the
system -- no other configuration is needed. The following commands will manage the service
accordingly:

  - Starting Redict: `sudo systemctl start redict`
  - Stopping Redict: `sudo systemctl stop redict`
  - Getting logs for the running service: `journalctl -feu redict`

By default, Redict listens on the `internal` network under the `redict` hostname, port 6379. Any
services that wish to connect to Redict for that hostname and port need to also be included in the
`internal` network.

By default, a named volume is created for `redict` which is used for restoring databases on service
restart.

## Use

Depending on Redict from other systemd services is as simple as declaring an ordered dependency in
the systemd service file, for example:

```ini
[Unit]
Description=Service That Uses Redict
Wants=container-build@example.service redict.service
After=container-build@example.service redict.service
```

Redict will then be guaranteed to be running before the example service is.
