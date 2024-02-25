# Coturn

This directory contains a systemd service for running an instance of Coturn.

## Deployment

Including the `spec.bu` file here in your host configuration is enough to have Coturn enabled on the
system -- no other configuration is needed. The following commands will manage the service
accordingly:

  - Starting Coturn: `sudo systemctl start coturn`
  - Stopping Coturn: `sudo systemctl stop coturn`
  - Getting logs for the running service: `journalctl -feu coturn`

Coturn will, by default, bind to and listen on the following host ports, both TCP and UDP:

  - `3478`
  - `3479`
  - `5349`
  - `5350`

  These ports correspond to ports required for STUN and TURN listeners. In addition, clients are
  expected to be able to bind to a range of UDP ports, as defined in the host configuration for
  `COTURN_RELAY_PORT_MIN` and `COTURN_RELAY_PORT_MAX`. All above ports and all ports in the range
  configured need to be accessible via the public Internet for Coturn to operate correctly.

## Configuration

Coturn requires host configuration before use, specifically:

  - `COTURN_AUTH_SECRET`: A static password used by services that use Coturn internally to establish
  STUN/TURN sessions.
  - `COTURN_REALM`: The domain name used externally by clients using Coturn for STUN/TURN, e.g. `turn.example.com`.
  - `COTURN_EXTERNAL_IP`: The external/WAN IP which Coturn can be found on, e.g. `203.0.113.10`.
  - `COTURN_RELAY_PORT_MIN`: The lowest-numbered port Coturn will allocate for new STUN/TURN
    sessions, e.g. `51000`.
  - `COTURN_RELAY_PORT_MAX`: The highest-numbered port Coturn will allocate for new STUN/TURN
  sessions, e.g. `51100`.

## Use

Depending on Coturn from other systemd services is as simple as declaring an ordered dependency in
the systemd service file, for example:

```ini
[Unit]
Description=Service That Uses Coturn
Wants=container-build@example.service coturn.service
After=container-build@example.service coturn.service
```

Coturn will then be guaranteed to be running before the example service is.
