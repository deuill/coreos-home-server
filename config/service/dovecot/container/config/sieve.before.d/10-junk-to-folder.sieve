require ["fileinto", "mailbox"];

if header :contains "X-Spam" "Yes" {
    fileinto :create "INBOX.Junk";
    stop;
}
