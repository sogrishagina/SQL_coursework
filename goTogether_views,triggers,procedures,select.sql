USE gotogether;

-- Выборка - В каком городе самые активные театралы - пользователи участвуют в бОльшем количестве театральных мероприятий

SELECT up.hometown, COUNT(*) AS theatre_goers FROM participants p
JOIN u_profiles up ON p.user_id = up.user_id
JOIN theatre_events te ON p.event_id = te.id
GROUP BY up.hometown
ORDER BY theatre_goers DESC


-- Выборка - Какая комбинация самая частая в партнерстве - мужчина + женщина, женщина + мужчина и т.д.

SELECT COUNT(*) AS cnt, CONCAT('initiator - ',(SELECT gender FROM u_profiles up WHERE up.user_id = pr.initiator_user_id),
				' target - ',(SELECT gender FROM u_profiles up WHERE up.user_id = pr.target_user_id)) AS combination
FROM partners_request pr 
GROUP BY combination
ORDER BY cnt DESC;


-- Представление - театральные мероприятия

CREATE VIEW theatre_events AS
SELECT id FROM events WHERE event_type = (SELECT id FROM event_types WHERE name = 'theatre');

-- Представление - непопулярные мероприятия, в которых не участвует ни один пользователь

CREATE VIEW unpopular_events AS
SELECT * FROM events WHERE id NOT IN (SELECT event_id FROM participants); 

-- Представление - имя и фамилия пользователя

CREATE VIEW user_name AS
SELECT CONCAT(users.firstname, ' ', users.lastname)AS name,id FROM users;

/* Хранимая процедура - показать юзеру ближайшие похожие мероприятия c последним посещенным мероприятием
для результатов требуются мероприятия в будущем
*/

DELIMITER $$

CREATE PROCEDURE sp_events_offers(IN for_user_id BIGINT)
BEGIN
	WITH last_user_event AS(
	SELECT e.id, e.event_date, e.event_type, e.genre_type,e.hometown, up.user_id FROM events e
	JOIN participants p ON e.id = p.event_id 
	JOIN u_profiles up ON up.hometown = e.hometown
	WHERE p.user_id = for_user_id AND e.event_date < NOW()
	ORDER BY e.event_date DESC
	LIMIT 1)
	SELECT e.id, e.event_date, e.event_type, e.genre_type,e.hometown, lue.user_id FROM events e
	JOIN last_user_event lue ON true 
	WHERE lue.user_id = for_user_id AND e.event_date > NOW()
	AND e.event_type = lue.event_type
	AND e.genre_type = lue.genre_type
	ORDER BY e.event_date ASC
	LIMIT 3;
END $$

DELIMITER ;

/* Хранимая процедура -  показать юзеру рекламу непопулярного мероприятия в его городе, 
жанр которого - самый частый жанр мероприятий, которые посещает юзер.
для результатов требуются мероприятия в будущем */

DELIMITER $$

CREATE PROCEDURE unpopular_events_ad(IN for_user_id BIGINT)
BEGIN
	WITH user_events AS(
	SELECT e.id, e.genre_type, p.user_id FROM events e
	JOIN participants p ON e.id = p.event_id 
	WHERE p.user_id = for_user_id
	),
	 favourite_genre AS(
	SELECT genre_type, COUNT(*) as cnt FROM user_events 
	GROUP BY genre_type
	ORDER BY cnt DESC
	LIMIT 1
	)
	SELECT u_e.id, u_e.event_date, u_e.event_type, u_e.genre_type, u_e.hometown, u_p.hometown 
	FROM unpopular_events u_e
	JOIN u_profiles u_p ON u_p.hometown = u_e.hometown
	WHERE u_e.genre_type = (SELECT genre_type FROM favourite_genre) AND u_e.event_date > NOW()
	AND u_p.user_id = for_user_id
	ORDER BY u_e.event_date 
	LIMIT 3;
END $$

DELIMITER ;

-- Триггер - дата мероприятия изменена - послать юзеру сообщение

DELIMITER $$

CREATE TRIGGER event_date_changed
AFTER UPDATE
ON events FOR EACH ROW 
	BEGIN 
		IF OLD.event_date != NEW.event_date THEN 
		INSERT INTO messages (from_user_id, to_user_id, body, created_at)
		SELECT NEW.host_id, user_id, CONCAT('Date of "', NEW.name, '" was changed to ', NEW.event_date) , NOW()
		FROM participants p WHERE p.event_id=NEW.id;
		END IF;
	END $$	
	
DELIMITER ;

-- Триггер - получен ответ на запрос "стать партнером" - послать юзеру сообщение

DELIMITER $$

CREATE TRIGGER partners_status_changed
AFTER UPDATE
ON partners_request FOR EACH ROW 
	BEGIN 
	IF OLD.partners_status != NEW.partners_status THEN 
		IF NEW.partners_status = 'approved' THEN
			INSERT INTO messages (from_user_id, to_user_id, body, created_at)
			SELECT NEW.target_user_id, NEW.initiator_user_id,
			CONCAT((SELECT name FROM user_name un WHERE un.id = NEW.target_user_id), ' approved your request') , NOW();
		ELSEIF NEW.partners_status = 'declined' THEN
			INSERT INTO messages (from_user_id, to_user_id, body, created_at)
			SELECT NEW.target_user_id, NEW.initiator_user_id,
			CONCAT((SELECT name FROM user_name un WHERE un.id = NEW.target_user_id), ' declined your request') , NOW();
		END IF;
	END IF;
	END$$	
	
DELIMITER ;























