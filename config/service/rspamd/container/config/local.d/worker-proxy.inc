# Configuration for proxy worker.

milter = yes;
timeout = 120s;

upstream "local" {
    default = yes;
    self_scan = yes;
}

# Bind to any IPv4 address.
bind_socket = "*v4:11332";
