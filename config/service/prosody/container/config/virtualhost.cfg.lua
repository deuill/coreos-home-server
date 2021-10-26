-- Base virtual host for Prosody.
--
-- By default, this is configured  to run components required for compliance with modern clients,
-- and evolves according to these requirements.

local host_base = os.getenv("PROSODY_HOST") or "localhost"
local host_external = os.getenv("PROSODY_HOST_EXTERNAL") or "external.localhost"

VirtualHost(host_base)
  http_host = host_external
  http_external_url = "https://" .. host_external .. "/"
  certificate = "/etc/ssl/private/certificates/" .. host_base .. ".crt"
  authentication = "imap"
  auth_append_host = true

Component(host_external) "muc"
  modules_enabled = {"muc_mam", "vcard_muc"}
  name = "The " .. host_base .. " chat-room server"
  certificate = "/etc/ssl/private/certificates/" .. host_external .. ".crt"
  restrict_room_creation = "local"
  max_history_messages = 100

Component(host_external) "http_upload"
  http_external_url = "https://" .. host_external .. "/"
  http_upload_expire_after = 60 * 60 * 24 * 7
  http_upload_file_size_limit = 1024 * 1024 * 32
  http_upload_quota = 1024 * 1024 * 1024
