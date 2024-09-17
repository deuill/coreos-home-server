# MariaDB

This directory contains a simple systemd service for running an instance of MariaDB.

## Deployment

Including the `spec.bu` file here in your host configuration is enough to have MariaDB enabled on the
system -- no other configuration is needed. The following commands will manage the service
accordingly:

  - Starting MariaDB: `sudo systemctl start mariadb`
  - Stopping MariaDB: `sudo systemctl stop mariadb`
  - Getting logs for the running service: `journalctl -feu mariadb`

By default, MariaDB listens on the `internal` network under the `mariadb` hostname, port 3306. Any
services that wish to connect to MariaDB for that hostname and port need to also be included in the
`internal` network.

The systemd service for MariaDB tries to delay readiness checks for until the listener is correctly
set up, and will run periodic health-checks to ensure the same.

## Use

Depending on MariaDB from other systemd services is as simple as declaring an ordered dependency in
the systemd service file, for example:

```ini
[Unit]
Description=Service That Uses MariaDB
Wants=container-build@example.service mariadb.service
After=container-build@example.service mariadb.service
```

MariaDB will then be guaranteed to be running before the example service is. Assuming, then, that both services are on the same network, connections to MariaDB can be made via the `mariadb` DNS name.

## Database Migrations

Services can define an initial state for databases used internally by way of special
`mariadb-migrate.sql` files, which are used by the included `mariadb-migrate@` service. 

For example, given a service `example` (in its own directory), we would need a file
`example/service/mariadb-migrate.sql`, containing SQL calls for creating databases, users:

```sql
-- Create default database.
CREATE DATABASE IF NOT EXISTS `${EXAMPLE_DATABASE_NAME}`;

-- Create default user with pre-defined password.
CREATE USER IF NOT EXISTS '${EXAMPLE_DATABASE_USERNAME}'@'%' IDENTIFIED BY '${EXAMPLE_DATABASE_PASSWORD}';
GRANT ALL PRIVILEGES ON `${EXAMPLE_DATABASE_NAME}`.* TO '${EXAMPLE_DATABASE_USERNAME}'@'%';
```

As evidenced above, this file can also have environment variables defined, which are derived from the
service-specific `example/example.env.template` file (if any exists). Running these migrations is as
simple a matter as running the aforementioned service, e.g.:

```
sudo systemctl start mariadb-migrate@example
```

The systemd journal should provide evidence of execution and reference to any issues that may have occured.
