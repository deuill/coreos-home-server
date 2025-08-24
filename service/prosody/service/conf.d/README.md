# Additional Configuration for Prosody

Any file with an extension of `.cfg.lua` placed in this directory will be included as part of
Prosody's configuration; for example, a new component:

```lua
Component "irc.example.com"
  component_secret = ENV_PROSODY_BIBOUMI_PASSWORD or ""
  modules_enabled = {"privilege"}

Component "upload.example.com" "http_file_share"
  http_file_share_access = {"irc.example.com"}
```

This assumes that a `PROSODY_BIBOUMI_PASSWORD` environment variable is also provided, potentially as
drop-in environment configuration for the `prosody` service.
