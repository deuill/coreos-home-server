require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables", "imap4flags"];

addflag "\\Seen";
pipe :copy "learn-rspamd.script" ["spam"];
