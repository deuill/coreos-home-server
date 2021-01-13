-- Create default database.
CREATE DATABASE IF NOT EXISTS `${DOVECOT_DATABASE_NAME}`;

-- Create default user with pre-defined password.
CREATE USER IF NOT EXISTS '${DOVECOT_DATABASE_USERNAME}'@'%' IDENTIFIED BY '${DOVECOT_DATABASE_PASSWORD}';
GRANT ALL PRIVILEGES ON `${DOVECOT_DATABASE_NAME}`.* TO '${DOVECOT_DATABASE_USERNAME}'@'%';

FLUSH PRIVILEGES;
USE `${DOVECOT_DATABASE_NAME}`;

BEGIN;

-- Create default schema.
CREATE TABLE IF NOT EXISTS `users` (
    `username` VARCHAR(255) NOT NULL PRIMARY KEY,
    `password` VARCHAR(255) NOT NULL,
    `maildir` VARCHAR(255) NOT NULL,
    `home` VARCHAR(255) NOT NULL DEFAULT '/var/mail/virtual',
    `uid` SMALLINT(5) UNSIGNED NOT NULL DEFAULT 5000,
    `gid` SMALLINT(5) UNSIGNED NOT NULL DEFAULT 5000,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS `domains` (
    `id` SMALLINT(6) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `domain` VARCHAR(255) NOT NULL,
    `transport` VARCHAR(255) NOT NULL DEFAULT 'virtual:',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS `aliases` (
    `id` SMALLINT(3) NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `mail` VARCHAR(255) NOT NULL,
    `destination` VARCHAR(255) NOT NULL,
    `enabled` TINYINT(1) NOT NULL DEFAULT 1,
    UNIQUE KEY `mail` (`mail`)
);

-- Create default, required entries.
INSERT INTO `domains` (domain)
    VALUES ('localhost'),
            ('localhost.localdomain');

INSERT INTO `aliases` (`mail`, `destination`)
     VALUES ('postmaster@localhost'  ,'root@localhost'),
            ('sysadmin@localhost'    ,'root@localhost'),
            ('webmaster@localhost'   ,'root@localhost'),
            ('abuse@localhost'       ,'root@localhost'),
            ('root@localhost'        ,'root@localhost'),
            ('@localhost'            ,'root@localhost'),
            ('@localhost.localdomain','@localhost');

INSERT INTO `users` (`username`, `password`, `maildir`)
     VALUES ('root@localhost', encrypt(MD5(RAND()), CONCAT('$5$', MD5(RAND()))), 'root/');

COMMIT;
