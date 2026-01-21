# Local address for internal Pod network.
local_addrs = [10.89.0.0/16];

# Use local Unbound DNS resolver before falling back to public DNS resolver.
dns {
    nameserver = "master-slave:unbound,1.1.1.1";
}
