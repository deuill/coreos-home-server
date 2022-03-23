-- Base virtual host for Prosody.
--
-- By default, this is configured  to run components required for compliance with modern clients,
-- and evolves according to these requirements.

local host_base = os.getenv("PROSODY_HOST") or "localhost"
local host_external = os.getenv("PROSODY_HOST_EXTERNAL") or "external.localhost"

-- The primary virtual host, typically anchored to the root domain (e.g. "example.com"). User JIDs
-- will need to match this domain name.
VirtualHost(host_base)
  http_host         = host_external
  http_external_url = "https://" .. host_external .. "/"
  authentication    = "imap"
  auth_append_host  = true
  http_paths = {
    conversejs = "/web"
  }

-- The component responsible for multi-user chats.
Component(host_external) "muc"
  name                   = "The " .. host_base .. " chat-room server"
  restrict_room_creation = "local"
  max_history_messages   = 100
  modules_enabled = {
    "muc_mam",
    "vcard_muc"
  }

-- The component responsible for HTTP file uploads.
Component(host_external) "http_file_share"
  http_file_share_expire_after = 60 * 60 * 24 * 31
  http_file_share_size_limit   = 1024 * 1024 * 32
  http_file_share_daily_quota  = 1024 * 1024 * 128
  http_file_share_global_quota = 1024 * 1024 * 1024 * 5
  http_host                    = host_external
  http_external_url            = "https://" .. host_external .. "/"
  http_paths = {
    file_share = "/upload"
  }
