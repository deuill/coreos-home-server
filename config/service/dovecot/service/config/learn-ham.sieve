require ["vnd.dovecot.pipe", "copy", "imapsieve", "environment", "variables"];

if environment :matches "imap.mailbox" "*" {
    set "mailbox" "${1}";
}

if string :matches "${mailbox}" ["*/Trash", "Trash"] {
    stop;
}

pipe :copy "learn-rspamd.script" ["ham"];
