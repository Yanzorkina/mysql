/*
 База данных игры "Муравьи"
 - Вход через личный кабинет (users);
 - В личном кабинете открывается доступ к персонажам (characters);
 - При создании персонажа можно выбрать один из доступных классов (heroes), каждый из которых обладает
 уникальным набором умений (skills), прогресс осуществляется через систему уровней, которые открывают
 доступ к умениям и предоставляют множитель для расчета характеристик героев (умножение базовых параметров);
 - Баланс осуществляется с помощью базовых характеристик;
 - Активность сводится к борьбе с персонажами (duels) и монстрами (fights), получению опыта и уровня;
 - Есть чат, где можно оставлять сообщения, адресация упрощена;
 - Упрощено понятие пространства, т.к. это заметно усложнит базу данных.
 **/

DROP DATABASE IF EXISTS ANTs;
CREATE DATABASE ANTs;
USE ANTs;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY, 
    login VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password_hash varchar(100),
    phone BIGINT,
    is_deleted bit default 0,
    INDEX  users_login_idx (login)
);


DROP TABLE IF EXISTS `heroes`;
CREATE TABLE `heroes` (
	hero_id SERIAL PRIMARY KEY,
	description TEXT,
	model_id BIGINT UNSIGNED,
	base_hp BIGINT UNSIGNED,
	base_atk BIGINT UNSIGNED,
	base_def BIGINT UNSIGNED,
	skill_1 BIGINT UNSIGNED,
	skill_2 BIGINT UNSIGNED,
	skill_3 BIGINT UNSIGNED,
	skill_4 BIGINT UNSIGNED
);


DROP TABLE IF EXISTS `char_lvl`;
CREATE TABLE `char_lvl` (
	lvl SERIAL PRIMARY KEY,
	coefficient BIGINT UNSIGNED,
	experience BIGINT UNSIGNED
	
);

DROP TABLE IF EXISTS `monsters`;
CREATE TABLE `monsters` (
	monster_id SERIAL PRIMARY KEY,
	monster_name TEXT,
	model_filename VARCHAR (255),
	monster_lvl BIGINT UNSIGNED,
	hp BIGINT UNSIGNED,
	atk BIGINT UNSIGNED,
	def BIGINT UNSIGNED,
	experience BIGINT UNSIGNED
    
);

DROP TABLE IF EXISTS `models`;
CREATE TABLE `models` (
	model_id SERIAL PRIMARY KEY,
	filename VARCHAR (255)
	
);

DROP TABLE IF EXISTS `avatars`;
CREATE TABLE `avatars` (
	avatar_id  SERIAL PRIMARY KEY,
	filename VARCHAR (255),
	`SIZE` BIGINT UNSIGNED
);

DROP TABLE IF EXISTS `skills`;
CREATE TABLE `skills` (
	skill_id SERIAL PRIMARY KEY,
	hero_id BIGINT UNSIGNED NOT NULL,
	skill_name VARCHAR (100),
	description TEXT,
	skill_purpose ENUM('attack', 'heal'),
	multiplier BIGINT UNSIGNED,
	skill_range BIGINT UNSIGNED,
	cooldown TIME,
	FOREIGN KEY (hero_id) REFERENCES `heroes`(hero_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS `characters`;
CREATE TABLE `characters` (
	char_id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	model_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100),
    char_hero_id BIGINT UNSIGNED NOT NULL,
    lvl BIGINT UNSIGNED NOT NULL,
	photo_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW(),
    experience INT UNSIGNED,
    FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (char_hero_id) REFERENCES `heroes`(hero_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (lvl) REFERENCES `char_lvl`(lvl) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (model_id) REFERENCES `models`(model_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (photo_id) REFERENCES `avatars`(avatar_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS `chat`;
CREATE TABLE `chat` (
	id SERIAL PRIMARY KEY,
	from_char_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке
	FOREIGN KEY (from_char_id) REFERENCES `characters`(char_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS `duels`;
CREATE TABLE `duels` (
	id SERIAL PRIMARY KEY,
	from_char_id BIGINT UNSIGNED NOT NULL,
    to_char_id BIGINT UNSIGNED NOT NULL,
    duel_status ENUM('win', 'lose'),
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (from_char_id) REFERENCES `characters`(char_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (to_char_id) REFERENCES `characters`(char_id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS `fights`;
CREATE TABLE `fights` (
	id SERIAL PRIMARY KEY,
	char_id BIGINT UNSIGNED NOT NULL,
    monster_id BIGINT UNSIGNED NOT NULL,
    fight_status ENUM('win', 'lose'),
    created_at DATETIME DEFAULT NOW(),
    
    FOREIGN KEY (char_id) REFERENCES `characters`(char_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (monster_id) REFERENCES `monsters`(monster_id) ON UPDATE CASCADE ON DELETE CASCADE
);


-- Добавляем связи умений.

ALTER TABLE heroes ADD CONSTRAINT  fk_skill_id_1 
 FOREIGN KEY (skill_1) REFERENCES `skills`(skill_id)  
 ON UPDATE CASCADE ON DELETE CASCADE; 
 
ALTER TABLE heroes ADD CONSTRAINT  fk_skill_id_2 
 FOREIGN KEY (skill_2) REFERENCES `skills`(skill_id)  
 ON UPDATE CASCADE ON DELETE CASCADE; 
 
ALTER TABLE heroes ADD CONSTRAINT  fk_skill_id_3 
 FOREIGN KEY (skill_3) REFERENCES `skills`(skill_id)  
 ON UPDATE CASCADE ON DELETE CASCADE; 
 
ALTER TABLE heroes ADD CONSTRAINT  fk_skill_id_4 
 FOREIGN KEY (skill_4) REFERENCES `skills`(skill_id)  
 ON UPDATE CASCADE ON DELETE CASCADE;








