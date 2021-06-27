VirtualHost(os.getenv("PROSODY_HOST"))
  http_host = os.getenv("PROSODY_HOST_EXTERNAL")
  http_external_url = "https://" .. os.getenv("PROSODY_HOST_EXTERNAL") .. "/"
  certificate = "/etc/ssl/private/certificates/" .. os.getenv("PROSODY_HOST") .. ".crt"
  authentication = "imap"
  auth_append_host = true

Component(os.getenv("PROSODY_HOST_EXTERNAL")) "muc"
  modules_enabled = {"muc_mam", "vcard_muc"}
  name = "The " .. os.getenv("PROSODY_HOST") .. " chat-room server"
  certificate = "/etc/ssl/private/certificates/" .. os.getenv("PROSODY_HOST_EXTERNAL") .. ".crt"
  restrict_room_creation = "local"
  max_history_messages = 100

Component(os.getenv("PROSODY_HOST_EXTERNAL")) "http_upload"
  http_external_url = "https://" .. os.getenv("PROSODY_HOST_EXTERNAL") .. "/"
  http_upload_expire_after = 60 * 60 * 24 * 7
  http_upload_file_size_limit = 1024 * 1024 * 32
  http_upload_quota = 1024 * 1024 * 1024
