DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL primary key, -- BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'фамилия',
    email VARCHAR(120) UNIQUE,
    phone BIGINT UNIQUE COMMENT 'я бы тоже сделала unique',
    INDEX users_phone_ind(phone),
    INDEX users_firstname_lastname_idx(firstname, lastname)
);

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id SERIAL PRIMARY KEY, 
    gender CHAR(1),
    birthday DATE,
    Photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
	id SERIAL primary key, -- т.к. лайков будет много, есть смысл сделать индекс просто номером, ведь хранение композитного индекса "пользователь-дата и время лайка" займет больше места?
    who_likes BIGINT UNSIGNED NOT NULL,
    liked_at DATETIME DEFAULT NOW(),
    -- не думаю, что нужно индексировать по пользователю, мы же не смотрим лайки по пользователю.
    FOREIGN KEY (who_likes) REFERENCES users(id)  
);

DROP TABLE IF EXISTS attachments;
CREATE TABLE attachments (
    id SERIAL primary key,
    uploaded_at DATETIME DEFAULT NOW(),
    creator_id BIGINT UNSIGNED NOT NULL,
    attachment_like_id BIGINT UNSIGNED NOT NULL,
    INDEX attachment_creator_id (creator_id),
    FOREIGN KEY (creator_id) REFERENCES users(id),
    FOREIGN KEY (attachment_like_id) REFERENCES likes(id)
);
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    delivered_at DATETIME DEFAULT NOW(),
    read_at DATETIME DEFAULT NOW(),
    attachment_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM('outbox', 'sent', 'received', 'delivered', 'read', 'failed'),
    INDEX messages_from_user_id (from_user_id),
    INDEX messages_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id),
    FOREIGN KEY (attachment_id) REFERENCES attachments(id)
);

DROP TABLE IF EXISTS friends_requests;
CREATE TABLE friends_requests (
    ini_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    requested_at DATETIME DEFAULT NOW(),
    confirmed_at DATETIME DEFAULT NOW(),
    PRIMARY KEY (ini_user_id, target_user_id),
    INDEX (ini_user_id),
    INDEX (target_user_id),
    FOREIGN KEY (ini_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)
);
    
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
    creator_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    attachment_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    `status` ENUM('private', 'global', 'friends'),
    post_like_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY posts_creator_time (creator_id, created_at),
    INDEX posts_creator_id (creator_id),
    FOREIGN KEY (creator_id) REFERENCES users(id),
    FOREIGN KEY (attachment_id) REFERENCES attachments(id),
    FOREIGN KEY (post_like_id) REFERENCES likes(id)
);

