CREATE DATABASE gotogether;


USE gotogether;


DROP TABLE IF EXISTS users;
CREATE TABLE users(
	id SERIAL PRIMARY KEY,
    firstname VARCHAR(50),
    lastname VARCHAR(50),
    email VARCHAR(120) UNIQUE,
    phone BIGINT,
    user_type ENUM('visitor', 'host', 'moderator')COMMENT 'visitor-goes to events; host-creates events',
    INDEX users_phone_idx(phone),
    INDEX users_firstname_lastname_idx(firstname, lastname)
);


DROP TABLE IF EXISTS partners_request;
CREATE TABLE partners_request (
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    partners_status ENUM('requested', 'approved', 'declined'),
	requested_at DATETIME DEFAULT NOW(),
	confirmed_at DATETIME,
	INDEX (initiator_user_id),
    INDEX (target_user_id),
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (target_user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(),
    INDEX messages_from_user_id (from_user_id),
    INDEX messages_to_user_id (to_user_id),
    FOREIGN KEY (from_user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE CASCADE
);
DROP TABLE IF EXISTS galary;
CREATE TABLE galary(
	id SERIAL PRIMARY KEY,
    user_id BIGINT UNSIGNED COMMENT 'the one downloaded photo',
    filename VARCHAR(255),
    size INT,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE SET NULL
);
DROP TABLE IF EXISTS u_profiles;
CREATE TABLE u_profiles (
	user_id SERIAL PRIMARY KEY,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (photo_id)REFERENCES galary(id)ON UPDATE CASCADE ON DELETE SET NULL
);

DROP TABLE IF EXISTS event_types;
CREATE TABLE event_types(
	id SERIAL PRIMARY KEY,
	name VARCHAR (100)
);
DROP TABLE IF EXISTS genre_types;
CREATE TABLE genre_types(
	id SERIAL PRIMARY KEY,
	name VARCHAR (100)
);

DROP TABLE IF EXISTS events;
CREATE TABLE events(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255),
	photo_id BIGINT UNSIGNED NULL,
	body TEXT,
    created_at DATETIME DEFAULT NOW(),
    event_date DATETIME,
    hometown VARCHAR(100),
    event_type BIGINT UNSIGNED NULL,
	genre_type BIGINT UNSIGNED NULL,
 	host_id BIGINT UNSIGNED NULL,
 	INDEX events_name_idx(name),
 	FOREIGN KEY (event_type) REFERENCES event_types(id)ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (genre_type) REFERENCES genre_types(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 	FOREIGN KEY (photo_id) REFERENCES galary(id)ON UPDATE CASCADE ON DELETE SET NULL,
 	FOREIGN KEY (host_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE SET NULL
 );


DROP TABLE IF EXISTS participants;
CREATE TABLE participants(
	user_id BIGINT UNSIGNED NOT NULL,
	event_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (user_id, event_id),
    FOREIGN KEY (user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(id)ON UPDATE CASCADE ON DELETE CASCADE	
);
