-- Prosody XMPP Server Configuration
--
-- Information on configuring Prosody can be found on our
-- website at https://prosody.im/doc/configure
--
-- Tip: You can check that the syntax of this file is correct
-- when you have finished by running this command:
--     prosodyctl check config
-- If there are any errors, it will let you know what and where
-- they are, otherwise it will keep quiet.
--
-- Good luck, and happy Jabbering!

---------- Server-wide settings ----------
-- Settings in this section apply to the whole server and are the default settings
-- for any virtual hosts

-- This is a (by default, empty) list of accounts that are admins
-- for the server. Note that you must create the accounts separately
-- (see https://prosody.im/doc/creating_accounts for info)
-- Example: admins = { "user1@example.com", "user2@example.net" }
admins = {}

-- Prosody will always look in its source directory for modules, but
-- this option allows you to specify additional locations where Prosody
-- will look for modules first. For community modules, see https://modules.prosody.im/
plugin_paths = {"/usr/lib/prosody/modules", "/usr/lib/prosody/community-modules"}

-- This is the list of modules Prosody will load on startup.
-- It looks for mod_modulename.lua in the plugins folder, so make sure that exists too.
-- Documentation for bundled modules can be found at: https://prosody.im/doc/modules
modules_enabled = {
    -- Generally required
    "roster"; -- Allow users to have a roster. Recommended ;)
    "saslauth"; -- Authentication for clients and servers. Recommended if you want to log in.
    "tls"; -- Add support for secure TLS on c2s/s2s connections
    "dialback"; -- s2s dialback support
    "disco"; -- Service discovery
    "posix"; -- POSIX functionality, sends server to background, enables syslog, etc.

    -- Not essential, but recommended
    "carbons"; -- Keep multiple clients in sync
    "pep"; -- Enables users to publish their mood, activity, playing music and more
    "blocklist"; -- Allow users to block communications with other users
    "vcard4"; -- Allow users to set vCards in v4 format.
    "vcard_legacy"; -- Allow users to set vCards in legacy formats.

    -- Nice to have
    "version"; -- Replies to server version requests
    "uptime"; -- Report how long server has been running
    "time"; -- Let others know the time here on this server
    "ping"; -- Replies to XMPP pings with pongs
    "mam"; -- Store messages in an archive and allow users to access it
    "smacks"; -- Stream management for resuming dropped connections.
    "csi_simple"; -- Enables simple traffic optimisation for clients that have reported themselves as inactive.

    -- Push notifications
    "cloud_notify"; -- Support for push notifications.
    "cloud_notify_filters"; -- Non-standard extensions for push notification filtering preferences.
    "cloud_notify_extensions"; -- Additional, non-standard extensions for push notification support.

    -- Spam/abuse management
    "spam_reporting"; -- Allow users to report spam/abuse
    "watch_spam_reports"; -- Alert admins of spam/abuse reports by users

    -- Admin interfaces
    "admin_shell"; -- Allows for Prosody administration over a local shell

    -- HTTP modules
    "websocket"; -- XMPP over WebSockets

    -- Other specific functionality
    "conversejs"; -- Web-based frontend for XMPP
    "bookmarks"; -- Next-generation group-chat bookmarks
    "turn_external"; -- Connect to TURN/STUN server
}

-- These modules are auto-loaded, but should you want
-- to disable them then uncomment them here:
modules_disabled = {}

-- Enable direct TLS connections for clients.
c2s_direct_tls_ports = {5223}

-- Force clients to use encrypted connections? This option will
-- prevent clients from authenticating unless they are using encryption.
c2s_require_encryption = true

-- Force servers to use encrypted connections? This option will
-- prevent servers from authenticating unless they are using encryption.
-- Note that this is different from authentication
s2s_require_encryption = true

-- Force certificate authentication for server-to-server connections?
-- This provides ideal security, but requires servers you communicate
-- with to support encryption AND present valid, trusted certificates.
-- NOTE: Your version of LuaSec must support certificate verification!
-- For more information see https://prosody.im/doc/s2s#security
s2s_secure_auth = true

-- HTTP interface and port configuration.
http_ports = {5280}
http_interfaces = {"*", "::"}

-- Explicitly disable HTTPS, as we're intended to use a reverse proxy in front of Prosody.
https_ports = {}
https_interfaces = {}

-- WebSockets configuration
consider_websocket_secure = true

-- Select the authentication backend to use. The 'internal' providers
-- use Prosody's configured data storage to store the authentication data.
-- To allow Prosody to offer secure authentication mechanisms to clients, the
-- default provider stores passwords in plaintext. If you do not trust your
-- server please see https://prosody.im/doc/modules/mod_auth_internal_hashed
-- for information about using the hashed backend.
authentication = "internal_hashed"

-- Select the storage backend to use. By default Prosody uses flat files
-- in its configured data directory, but it also supports more backends
-- through modules. An "sql" backend is included by default, but requires
-- additional dependencies. See https://prosody.im/doc/storage for more info.

storage = "sql" -- Default is "internal"
sql = {
    driver   = "SQLite3",
    database = "/var/lib/prosody/prosody.sqlite",
}

-- Archiving configuration
-- If mod_mam is enabled, Prosody will store a copy of every message. This
-- is used to synchronize conversations between multiple clients, even if
-- they are offline. This setting controls how long Prosody will keep
-- messages in the archive before removing them.

archive_expires_after = "1w" -- Remove archived messages after 1 week

-- You can also configure messages to be stored in-memory only. For more
-- archiving options, see https://prosody.im/doc/modules/mod_mam

-- Logging configuration
-- For advanced logging see https://prosody.im/doc/logging
log = {{to = "console", levels = {min = "info"}, timestamps = true}}

-- Set PID file and socket in ephemeral path.
pidfile = "/run/prosody/prosody.pid"
admin_socket = "/run/prosody/prosody.sock"

-- Don't show banner when performing console commands.
console_banner = ""

-- Configuration for Converse.js
conversejs_options = {
    view_mode = "fullscreen";
}

-- Configuration for IMAP authentication.
imap_auth_host = os.getenv("PROSODY_IMAP_AUTH_HOST") or "localhost"
imap_auth_port = os.getenv("PROSODY_IMAP_AUTH_PORT") or 993
auth_imap_ssl = {
    mode = "client",
    protocol = "tlsv1_2"
}

-- Configuration for TURN/STUN.
turn_external_host   = os.getenv("PROSODY_TURN_HOST") or "localhost"
turn_external_secret = os.getenv("PROSODY_TURN_SECRET") or ""

-- Uncomment to enable statistics
-- For more info see https://prosody.im/doc/statistics
-- statistics = "internal"

-- Certificates
-- Every virtual host and component needs a certificate so that clients and
-- servers can securely verify its identity. Prosody will automatically load
-- certificates/keys from the directory specified here.
-- For more information, including how to use 'prosodyctl' to auto-import certificates
-- (from e.g. Let's Encrypt) see https://prosody.im/doc/certificates

-- Location of directory to find certificates in (relative to main config file):
certificates = "/etc/ssl/private/certificates"

-- Allow TLS connections with additional, less secure ciphers, for compatibility with older clients.
ssl = {
    protocol = "tlsv1_2+";
    ciphers = {
        "ECDHE-ECDSA-AES128-GCM-SHA256";
        "ECDHE-RSA-AES128-GCM-SHA256";
        "ECDHE-ECDSA-AES256-GCM-SHA384";
        "ECDHE-RSA-AES256-GCM-SHA384";
        "ECDHE-ECDSA-CHACHA20-POLY1305";
        "ECDHE-RSA-CHACHA20-POLY1305";
        "DHE-RSA-AES128-GCM-SHA256";
        "DHE-RSA-AES256-GCM-SHA384";
        "DHE-RSA-CHACHA20-POLY1305";
        "ECDHE-ECDSA-AES128-SHA256";
        "ECDHE-RSA-AES128-SHA256";
        "ECDHE-ECDSA-AES128-SHA";
        "ECDHE-RSA-AES128-SHA";
        "ECDHE-ECDSA-AES256-SHA384";
        "ECDHE-RSA-AES256-SHA384";
        "ECDHE-ECDSA-AES256-SHA";
        "ECDHE-RSA-AES256-SHA";
    };
}

-- Listen on all interfaces for component connections.
component_interface = "0.0.0.0"

----------- Virtual hosts -----------
-- You need to add a VirtualHost entry for each domain you wish Prosody to serve.
-- Settings under each VirtualHost entry apply *only* to that host.

VirtualHost "localhost"

-- Disable TLS for local connections, which generally don't require encryption.
modules_disabled = {"tls"}

-- Default, environment-based virtual host.
include "virtualhost.cfg.lua"

--------- Additional configuration ---------
include "conf.d/*.cfg.lua"
