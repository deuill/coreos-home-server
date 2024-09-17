# Virtual Environment

The `virtual` host serves as both a fairly comprehensive example of a valid CoreOS Home-Server host definition, as well as a working virtual environment for testing Fedora CoreOS and included services end-to-end, using QEmu.

This documentation covers setup, basic use, and some additional jumping-off points for the virtual environment.

## Requirements and Setup

## Basic Use

## Service Endpoints

A number of included services are exposed to the host by default, and can either be accessed directly on a dedicated port, or via subdomains of `localhost`: 

| Service Name | Endpoints | Notes |
|------------------|------------|---------|
| [Dovecot](service/dovecot) | `localhost:8143`, `localhost:8993` | IMAP |
| Gitea | `localhost:7920` | Git/SSH |
| | https://gitea.localhost:8443 | Web UI |
| GotoSocial | https://social.localhost:8443 | Web UI |
| Grafana | https://metrics.localhost:8443 | Web UI |
| LLDAP | https://lldap.localhost:8443 | Web UI |
| Postfix | `localhost:8025`, `localhost:8465`, `localhost:8587` | SMTP |
| Prosody | `localhost:5222`, `localhost:5223`, `localhost:5269`, `localhost:5347` | XMPP |
| | https://chat.localhost:8443/web | Web Client |

## Accesing Services

Most services that allow for authentication will typically accept the following default credentials:

  - Username: `admin`
  - Password: `password`

Access as a regular user typically requires setup on LLDAP; for information on which user groups are required, see the documentation for each individual service, linked above.
