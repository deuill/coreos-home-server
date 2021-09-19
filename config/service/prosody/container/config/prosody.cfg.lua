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

-- Enable use of libevent for better performance under high load
-- For more information see: https://prosody.im/doc/libevent
use_libevent = true

-- Run Prosody under a restricted user and group, to prevent runaway permissions.
prosody_user = "prosody"
prosody_group = "prosody"

-- Prosody will always look in its source directory for modules, but
-- this option allows you to specify additional locations where Prosody
-- will look for modules first. For community modules, see https://modules.prosody.im/
plugin_paths = {"/usr/lib/prosody/community-modules"}

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

	-- Not essential, but recommended
	"carbons"; -- Keep multiple clients in sync
	"pep"; -- Enables users to publish their mood, activity, playing music and more
	"private"; -- Private XML storage (for room bookmarks, etc.)
	"blocklist"; -- Allow users to block communications with other users
	"vcard4"; -- Allow users to set vCards in v4 format.
	"vcard_legacy"; -- Allow users to set vCards in legacy formats.

	-- Nice to have
	"version"; -- Replies to server version requests
	"uptime"; -- Report how long server has been running
	"time"; -- Let others know the time here on this server
	"ping"; -- Replies to XMPP pings with pongs
	"register"; -- Allow users to register on this server using a client and change passwords
	"mam"; -- Store messages in an archive and allow users to access it
	"smacks"; -- Stream management for resuming dropped connections.
	"csi"; -- Chat state information.
	"csi_simple"; -- Enables simple traffic optimisation for clients that have reported themselves as inactive.
	"filter_chatstates"; -- Don't send chat state notifications when client is inactive.
	"throttle_presence"; -- Don't send presence information when client is inactive.
	"cloud_notify"; -- Support for push notifications.

	-- Admin interfaces
	--"admin_adhoc"; -- Allows administration via an XMPP client that supports ad-hoc commands
	--"admin_telnet"; -- Opens telnet console interface on localhost port 5582

	-- HTTP modules
	--"bosh"; -- Enable BOSH clients, aka "Jabber over HTTP"
	"websocket"; -- XMPP over WebSockets
	-- "http_files"; -- Serve static files from a directory over HTTP

	-- Other specific functionality
	--"limits"; -- Enable bandwidth limiting for XMPP connections
	--"groups"; -- Shared roster support
	--"server_contact_info"; -- Publish contact information for this service
	--"announce"; -- Send announcement to all online users
	--"welcome"; -- Welcome users who register accounts
	--"watchregistrations"; -- Alert admins of registrations
	--"motd"; -- Send a message to users when they log in
	--"legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
	"proxy65"; -- Enables a file transfer proxy service which clients behind NAT can use
	"conversejs"; -- Web-based frontend for XMPP
	"bookmarks"; -- Next-generation group-chat bookmarks
	"turncredentials"; -- Connect to TURN/STUN server.
}

-- These modules are auto-loaded, but should you want
-- to disable them then uncomment them here:
modules_disabled = {
	--"offline"; -- Store offline messages
	--"c2s"; -- Handle client connections
	--"s2s"; -- Handle server-to-server connections
	"posix"; -- POSIX functionality, sends server to background, enables syslog, etc.
}

-- Disable account creation by default, for security
-- For more information see https://prosody.im/doc/creating_accounts
allow_registration = false

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

-- Some servers have invalid or self-signed certificates. You can list
-- remote domains here that will not be required to authenticate using
-- certificates. They will be authenticated using DNS instead, even
-- when s2s_secure_auth is enabled.
--s2s_insecure_domains = { "insecure.example" }

-- Even if you leave s2s_secure_auth disabled, you can still require valid
-- certificates for some domains by specifying a list here.
--s2s_secure_domains = { "jabber.org" }

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
	driver   = "MySQL",
	host     = os.getenv("PROSODY_DATABASE_HOST") or "localhost",
	database = os.getenv("PROSODY_DATABASE_NAME") or "prosody",
	username = os.getenv("PROSODY_DATABASE_USERNAME") or "prosody",
	password = os.getenv("PROSODY_DATABASE_PASSWORD") or ""
}

-- For the "sql" backend, you can uncomment *one* of the below to configure:
--sql = { driver = "SQLite3", database = "prosody.sqlite" } -- Default. 'database' is the filename.
--sql = { driver = "MySQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }
--sql = { driver = "PostgreSQL", database = "prosody", username = "prosody", password = "secret", host = "localhost" }

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
turncredentials_host   = os.getenv("PROSODY_TURN_HOST") or "localhost"
turncredentials_secret = os.getenv("PROSODY_TURN_SECRET") or ""

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
certificates = "certificates"

-- Listen on all interfaces for component connections.
component_interface = "0.0.0.0"

----------- Virtual hosts -----------
-- You need to add a VirtualHost entry for each domain you wish Prosody to serve.
-- Settings under each VirtualHost entry apply *only* to that host.

VirtualHost "localhost"

-- Disable TLS for local connections, which generally don't require encryption.
modules_disabled = {"tls"}

--------- Additional configuration ---------
include "conf.d/*.cfg.lua"
