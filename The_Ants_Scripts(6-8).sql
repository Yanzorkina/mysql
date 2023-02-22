USE `ANTS`;


-- Вывести список персонажей сервера с указанием их класса и уровня.

SELECT 
c.char_id,
c.name,
h.description as 'class',
c.lvl as 'level'
FROM
`characters` c 
LEFT JOIN
heroes h ON c.char_hero_id = h.hero_id 
ORDER BY c.char_id ;

-- Показать таблицу популярности классов созданных персонажей.

SELECT 
count(*) as class_count,
h.description 
FROM 
`characters` c 
LEFT JOIN
heroes h ON c.char_hero_id = h.hero_id 
GROUP BY 
c.char_hero_id
ORDER BY
class_count DESC ;

-- Показать имя самого активного персонажа в чате.

SELECT
count(*) as cnt,
(SELECT name FROM `characters` c2 WHERE char_id = c.from_char_id) as char_name
FROM chat c 
GROUP BY char_name 
ORDER BY cnt DESC 
LIMIT 1;

-- Показать имя персонажа, который убил больше всего монстров.

SELECT 
count(*) as cnt,
(SELECT name FROM `characters` c WHERE char_id = f.char_id)
FROM fights f 
WHERE fight_status = 'win'
GROUP BY char_id  
ORDER BY cnt DESC 
LIMIT 1;


-- Представление с рейтингом дуэлей.

CREATE OR REPLACE VIEW v_duel_rating
AS 
	SELECT 
	count(*) AS duel_win,
	c.char_id,
	c.name
	FROM
	duels d 
	JOIN
	`characters` c ON (d.from_char_id = c.char_id AND d.duel_status = 'win') OR (d.to_char_id = c.char_id AND d.duel_status = 'lose')
	GROUP BY c.char_id
	ORDER BY duel_win DESC
	LIMIT 10;


-- Представление с рейтингом развития персонажей.

CREATE OR REPLACE VIEW v_characters_rating
AS 
	SELECT
	c.name,
	c.lvl,
	h.description 
	FROM
	`characters` c 
	JOIN
	heroes h ON c.char_hero_id = h.hero_id 
	ORDER BY c.lvl DESC
	LIMIT 10;

-- Процедура: Рассчет урона умением номер 1 для любого персонажа.

	-- Согласно механике игры, у каждого персонажа есть набор из четырех умений, у каждого умения есть множитель атаки, есть
	-- базовая атака для каждого класса и коэффициент урона, зависящий от уровня персонажа. Все перемножаем, получаем урон умением.

		-- Посчитаем вручную для первого персонажа:
			-- уровень персонажа = (6)
			SELECT lvl FROM `characters` WHERE char_id = 1;
			-- текущий коэффициент атаки = (300)
			SELECT coefficient FROM char_lvl WHERE lvl = (SELECT lvl FROM `characters` WHERE char_id = 1);
			-- текущая атака = (базовая атака (1200) * текущий коэффициент атаки (300) для уровня 6) = (3600)
			SELECT (
				(SELECT base_atk FROM heroes WHERE hero_id = (SELECT char_hero_id FROM `characters` WHERE char_id = 1))*
				(SELECT coefficient FROM char_lvl WHERE lvl = (SELECT lvl FROM `characters` WHERE char_id = 1))
			);
			-- найдем множитель урона для первого умения (из четырех доступных для персонажа)
			SELECT multiplier FROM skills WHERE skill_id = (SELECT skill_1 FROM heroes WHERE hero_id = (SELECT char_hero_id from `characters` WHERE char_id = 1));
			-- найдем атаку первым скилом для персонажа 1, перемножив текущую атаку на множитель умения
			SELECT (
				(SELECT base_atk FROM heroes WHERE hero_id = (SELECT char_hero_id FROM `characters` WHERE char_id = 1))*
					(SELECT coefficient FROM char_lvl WHERE lvl = (SELECT lvl FROM `characters` WHERE char_id = 1)) *
						(SELECT multiplier FROM skills WHERE skill_id = (SELECT skill_4 FROM heroes WHERE hero_id = 
						(SELECT char_hero_id from `characters` WHERE char_id = 1)))
			);
		-- переносим в процедуру:

DROP PROCEDURE IF EXISTS sp_skill_1_damage_dealed;
DELIMITER //
CREATE PROCEDURE sp_skill_1_damage_dealed(for_char_id BIGINT)
BEGIN
	SELECT (
	(SELECT base_atk FROM heroes WHERE hero_id = (SELECT char_hero_id FROM `characters` WHERE char_id = for_char_id))*
		(SELECT coefficient FROM char_lvl WHERE lvl = (SELECT lvl FROM `characters` WHERE char_id =for_char_id)) *
			(SELECT multiplier FROM skills WHERE skill_id = (SELECT skill_1 FROM heroes WHERE hero_id = 
			(SELECT char_hero_id from `characters` WHERE char_id = for_char_id)))
) AS final_damage;
END//
DELIMITER ;

-- пример вызова процедуры:
CALL sp_skill_1_damage_dealed (3);
CALL sp_skill_1_damage_dealed (10);


-- триггер, предупреждающий о попытке продать аккаунт через игровой чат.

DELIMITER $$
$$
CREATE TRIGGER check_account_sales
BEFORE INSERT
ON chat FOR EACH ROW
BEGIN
	IF NEW.body RLIKE 'продам аккаунт' THEN
		SET NEW.body = 'REPORT! персонаж-отправитель нарушает правила игры, сообщите администратору';
	END IF;
END
$$
DELIMITER ;

-- проверка работы триггера.

INSERT INTO chat (from_char_id, body) VALUES (5, 'срочно продам аккаунт дешево');
