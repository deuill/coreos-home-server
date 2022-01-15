# Redis

This directory contains a simple systemd service for running a disk-backed instance of Redis.

## Deployment

Including the `spec.bu` file here in your host configuration is enough to have Redis enabled on the
system -- no other configuration is needed. The following commands will manage the service
accordingly:

  - Starting Redis: `sudo systemctl start redis`
  - Stopping Redis: `sudo systemctl stop redis`
  - Getting logs for the running service: `journalctl -feu redis`

By default, Redis listens on the `internal` network under the `redis` hostname, port 6379. Any
services that wish to connect to Redis for that hostname and port need to also be included in the
`internal` network.

By default, a named volume is created for `redis` which is used for restoring databases on service
restart.

## Use

Depending on Redis from other systemd services is as simple as declaring an ordered dependency in
the systemd service file, for example:

```ini
[Unit]
Description=Service That Uses Redis
Wants=container-build@example.service redis.service
After=container-build@example.service redis.service
```

Redis will then be guaranteed to be running before the example service is.
