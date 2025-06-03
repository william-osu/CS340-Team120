-- #############################
-- Reset
-- #############################

DROP PROCEDURE IF EXISTS sp_Reset_Database;

DELIMITER //


CREATE PROCEDURE sp_Reset_Database()



BEGIN
START TRANSACTION;

SET FOREIGN_KEY_CHECKS=0;
SET AUTOCOMMIT = 0;

Drop TABLE IF EXISTS Constellations;
Drop TABLE IF EXISTS Stars;
Drop TABLE IF EXISTS Shows;
Drop TABLE IF EXISTS Customers;
Drop TABLE IF EXISTS Show_Stars;
Drop TABLE IF EXISTS Show_Constellations;
Drop TABLE IF EXISTS Show_Customers;



--
-- Entity tables: Constellations, Stars, Shows, Customers
--
CREATE OR REPLACE TABLE Constellations (
    constellation_id int AUTO_INCREMENT,
    name CHAR(100) NOT NULL,
    northern_hemisphere BIT,
    PRIMARY KEY (constellation_id)
);

-- temperature in kelvin, radius in solar radius, spectral class in O-B-A-F-G-K-M (hot to cold)
CREATE OR REPLACE TABLE Stars (
    star_id int AUTO_INCREMENT,
    constellation_id int NULL,
    proper_name VARCHAR(50) NULL,
    temperature DECIMAL(10, 0) NOT NULL,
    radius DECIMAL(20, 0) NULL,
    color CHAR(50) NULL,
    spectral_class CHAR(1) NOT NULL,
    PRIMARY KEY (star_id),
    FOREIGN KEY (constellation_id) REFERENCES Constellations(constellation_id)
);

-- Date in "year-month-day hour:minute:second" format
CREATE OR REPLACE TABLE Shows (
    show_id int AUTO_INCREMENT,
    title VARCHAR(500) NULL,
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (show_id)
);

CREATE OR REPLACE TABLE Customers (
    customer_id int AUTO_INCREMENT,
    name VARCHAR(500) NOT NULL,
    phone_number VARCHAR(15) NULL,
    email VARCHAR(500) NOT NULL,
    PRIMARY KEY (customer_id)
);

--
-- Intersection tables: Show_Stars, Show_Constellations, Show_Customers
--
CREATE OR REPLACE TABLE Show_Stars (
    star_id int NOT NULL,
    show_id int NOT NULL,
    FOREIGN KEY (star_id) REFERENCES Stars(star_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE OR REPLACE TABLE Show_Constellations (
    constellation_id int NOT NULL,
    show_id int NOT NULL,
    FOREIGN KEY (constellation_id) REFERENCES Constellations(constellation_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

CREATE OR REPLACE TABLE Show_Customers (
    customer_id int NOT NULL,
    show_id int NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (show_id) REFERENCES Shows(show_id)
);

--
-- Sample Data
--

-- Constellations Source: https://www.go-astronomy.com/constellations.htm
INSERT INTO Constellations (name, northern_hemisphere) VALUES
("Andromeda", 1),
("Antlia", 0),
("Apus", 0),
("Aquarius", 0),
("Aquila", 1),
("Ara", 0),
("Aries", 1),
("Auriga", 1),
("Boötes", 1),
("Caelum", 0),
("Ursa Major", 1),
("Ursa Minor", 1);


INSERT INTO Stars (constellation_id, proper_name, temperature, radius, color, spectral_class) VALUES
((SELECT constellation_id FROM Constellations WHERE name = "Ursa Major"), "Dubhe", 4650, 26.85, "Orange", "K"),
((SELECT constellation_id FROM Constellations WHERE name = "Ursa Major"), "Merak", 9700, 2.81, "Blue-White", "A"),
((SELECT constellation_id FROM Constellations WHERE name = "Ursa Major"), "Phecda", 6751, 3.38, "White", "A"),
((SELECT constellation_id FROM Constellations WHERE name = "Ursa Major"), "Megrez", 6909, 2.51, "White", "A"),
(NULL, "Sun", 5772, 1, "White", "G");

INSERT INTO Shows (title, date) VALUES
("The Big Dipper", "2025-07-13 20:00:00"),
("Astrology Night", "2025-08-13 20:00:00"),
("Venture into the Cosmos", NULL);

INSERT INTO Customers (name, phone_number, email) VALUES
("Henry Thistle", "8080298251", "Thistle@gmail.com"),
("Sad Happy", NULL, "Confused@outlook.com"),
("Wanda Cosmo", "5412345667", "FortniteGamer@yahoo.com");

INSERT INTO Show_Stars (show_id, star_id) VALUES
((SELECT show_id FROM Shows WHERE title = "The Big Dipper"), (SELECT star_id FROM Stars WHERE proper_name = "Dubhe")),
((SELECT show_id FROM Shows WHERE title = "The Big Dipper"), (SELECT star_id FROM Stars WHERE proper_name = "Merak")),
((SELECT show_id FROM Shows WHERE title = "The Big Dipper"), (SELECT star_id FROM Stars WHERE proper_name = "Phecda")),
((SELECT show_id FROM Shows WHERE title = "The Big Dipper"), (SELECT star_id FROM Stars WHERE proper_name = "Megrez")),
((SELECT show_id FROM Shows WHERE title = "Venture into the Cosmos"), (SELECT star_id FROM Stars WHERE proper_name = "Megrez"));

INSERT INTO Show_Constellations (show_id, constellation_id) VALUES
((SELECT show_id FROM Shows WHERE title = "The Big Dipper"), (SELECT constellation_id FROM Constellations WHERE name = "Andromeda")),
((SELECT show_id FROM Shows WHERE title = "Astrology Night"), (SELECT constellation_id FROM Constellations WHERE name = "Aquarius")),
((SELECT show_id FROM Shows WHERE title = "Astrology Night"), (SELECT constellation_id FROM Constellations WHERE name = "Aries"));

INSERT INTO Show_Customers (show_id, customer_id) VALUES
((SELECT show_id FROM Shows WHERE title = "The Big Dipper"), (SELECT customer_id FROM Customers WHERE name = "Henry Thistle")),
((SELECT show_id FROM Shows WHERE title = "Astrology Night"), (SELECT customer_id FROM Customers WHERE name = "Sad Happy")),
((SELECT show_id FROM Shows WHERE title = "Astrology Night"), (SELECT customer_id FROM Customers WHERE name = "Wanda Cosmo")),
((SELECT show_id FROM Shows WHERE title = "Venture into the Cosmos"), (SELECT customer_id FROM Customers WHERE name = "Henry Thistle")),
((SELECT show_id FROM Shows WHERE title = "Venture into the Cosmos"), (SELECT customer_id FROM Customers WHERE name = "Wanda Cosmo"));

SET FOREIGN_KEY_CHECKS=1;
COMMIT;

END//
DELIMITER;




-- #############################
-- CREATE section 
-- #############################

-- CREATE Constellation

DROP PROCEDURE IF EXISTS sp_CreateConstellations;

DELIMITER //

CREATE PROCEDURE sp_CreateConstellations(
    IN p_name VARCHAR(255), 
    IN p_northern_hemisphere BIT,  
    OUT p_constellation_id INT)


BEGIN
    INSERT INTO Constellations (name, northern_hemisphere) 
    VALUES (p_name, p_northern_hemisphere);

    SELECT LAST_INSERT_ID() into p_constellation_id;

    SELECT LAST_INSERT_ID() AS 'new_id';

END //
DELIMITER ;

-- CREATE Stars

DROP PROCEDURE IF EXISTS sp_CreateStars;

DELIMITER //

CREATE PROCEDURE sp_CreateStars(
    IN p_proper_name VARCHAR(50),
    IN p_constellation_id int, 
    IN p_temperature DECIMAL(10, 0),
    IN p_radius DECIMAL(20, 0),
    IN p_color CHAR(50),
    IN p_spectral_class CHAR(1),
    OUT p_star_id INT)


BEGIN
    INSERT INTO Stars (proper_name, constellation_id, temperature, radius, color, spectral_class) 
    VALUES (p_proper_name, p_constellation_id, p_temperature, p_radius, p_color, p_spectral_class);

    SELECT LAST_INSERT_ID() into p_star_id;

    SELECT LAST_INSERT_ID() AS 'new_id';

END //
DELIMITER ;

-- CREATE Shows

DROP PROCEDURE IF EXISTS sp_CreateShows;

DELIMITER //

CREATE PROCEDURE sp_CreateShows(
    IN p_title VARCHAR(255), 
    IN p_date TIMESTAMP,  
    OUT p_show_id INT)


BEGIN
    INSERT INTO Shows (title, date) 
    VALUES (p_title, p_date);

    SELECT LAST_INSERT_ID() into p_show_id;

    SELECT LAST_INSERT_ID() AS 'new_id';

END //
DELIMITER ;

-- CREATE Customer

DROP PROCEDURE IF EXISTS sp_CreateCustomer;

DELIMITER //

CREATE PROCEDURE sp_CreateCustomer(
    IN p_name VARCHAR(255), 
    IN p_phone_number VARCHAR(15), 
    IN p_email VARCHAR(500), 
    OUT p_customer_id INT)


BEGIN
    INSERT INTO Customers (name, phone_number, email) 
    VALUES (p_name, p_phone_number, p_email);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_customer_id;
    -- Display the ID of the last inserted person.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created person:
        -- CALL sp_CreatePerson('Theresa', 'Evans', 2, 48, @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;

-- CREATE Show_Stars

DROP PROCEDURE IF EXISTS sp_CreateShow_Stars;

DELIMITER //

CREATE PROCEDURE sp_CreateShow_Stars(
    IN p_star_id int, 
    IN p_show_id int)


BEGIN
    INSERT INTO Show_Stars (star_id, show_id) 
    VALUES (p_star_id, p_show_id);


END //
DELIMITER ;

-- CREATE Show_Constellations

DROP PROCEDURE IF EXISTS sp_CreateShow_Constellations;

DELIMITER //

CREATE PROCEDURE sp_CreateShow_Constellations(
    IN p_constellation_id int, 
    IN p_show_id int)


BEGIN
    INSERT INTO Show_Constellations (constellation_id, show_id) 
    VALUES (p_constellation_id, p_show_id);

END //
DELIMITER ;

-- CREATE Show_Stars

DROP PROCEDURE IF EXISTS sp_CreateShow_Customers;

DELIMITER //

CREATE PROCEDURE sp_CreateShow_Customers(
    IN p_customer_id int, 
    IN p_show_id int)


BEGIN
    INSERT INTO Show_Customers (customer_id, show_id) 
    VALUES (p_customer_id, p_show_id);


END //
DELIMITER ;


-- #############################
-- UPDATE section
-- #############################

-- UPDATE Constellations

DROP PROCEDURE IF EXISTS sp_UpdateConstellations;

DELIMITER //

CREATE PROCEDURE sp_UpdateConstellations(
    IN p_constellation_id INT, 
    IN p_name VARCHAR(255), 
    IN p_northern_hemisphere BIT)

BEGIN
    UPDATE Constellations 
    SET name = p_name, northern_hemisphere = p_northern_hemisphere
    WHERE constellation_id = p_constellation_id; 
END //
DELIMITER ;

-- UPDATE Stars

DROP PROCEDURE IF EXISTS sp_UpdateStars;

DELIMITER //

CREATE PROCEDURE sp_UpdateStars(
    IN p_star_id INT,
    IN p_proper_name VARCHAR(50),
    IN p_constellation_id int, 
    IN p_temperature DECIMAL(10, 0),
    IN p_radius DECIMAL(20, 0),
    IN p_color CHAR(50),
    IN p_spectral_class CHAR(1))

BEGIN
    UPDATE Stars 
    SET proper_name = p_proper_name, constellation_id = p_constellation_id, temperature = p_temperature, radius = p_radius, color = p_color, spectral_class = p_spectral_class
    WHERE star_id = p_star_id; 
END //
DELIMITER ;

-- UPDATE Shows

DROP PROCEDURE IF EXISTS sp_UpdateShows;

DELIMITER //

CREATE PROCEDURE sp_UpdateShows(
    IN p_show_id INT, 
    IN p_title VARCHAR(255), 
    IN p_date TIMESTAMP)

BEGIN
    UPDATE Shows
    SET title = p_title, date = p_date 
    WHERE show_id = p_show_id; 
END //
DELIMITER ;

-- UPDATE CUSTOMER

DROP PROCEDURE IF EXISTS sp_UpdateCustomer;

DELIMITER //

CREATE PROCEDURE sp_UpdateCustomer(
    IN p_customer_id INT, 
    IN p_name VARCHAR(255), 
    IN p_phone_number VARCHAR(15), 
    IN p_email VARCHAR(500)
    )

BEGIN
    UPDATE Customers 
    SET name = p_name, phone_number = p_phone_number, email = p_email 
    WHERE customer_id = p_customer_id; 
END //
DELIMITER ;

-- UPDATE Show_Stars

DROP PROCEDURE IF EXISTS sp_UpdateShow_Stars;

DELIMITER //

CREATE PROCEDURE sp_UpdateShow_Stars(
    IN p_star_id INT, 
    IN p_show_id INT)

BEGIN
    UPDATE Show_Stars
    SET star_id = p_star_id
    WHERE show_id = p_show_id; 
END //
DELIMITER ;

-- UPDATE Show_Constellations

DROP PROCEDURE IF EXISTS sp_UpdateShow_Constellations;

DELIMITER //

CREATE PROCEDURE sp_UpdateShow_Constellations(
    IN p_constellation_id INT, 
    IN p_show_id INT)

BEGIN
    UPDATE Show_Constellations
    SET constellation_id = p_constellation_id
    WHERE show_id = p_show_id; 
END //
DELIMITER ;

-- UPDATE Show_Customers

DROP PROCEDURE IF EXISTS sp_UpdateShow_Customers;

DELIMITER //

CREATE PROCEDURE sp_UpdateShow_Customers(
    IN p_customer_id INT, 
    IN p_show_id INT)

BEGIN
    UPDATE Show_Customers
    SET customer_id = p_customer_id
    WHERE show_id = p_show_id; 
END //
DELIMITER ;

-- #############################
-- DELETE Section
-- #############################

-- DELETE Constellations

DROP PROCEDURE IF EXISTS sp_DeleteConstellations;

DELIMITER //

CREATE PROCEDURE sp_DeleteConstellations(
    IN p_constellation_id INT)

BEGIN
    DECLARE error_message VARCHAR(255); 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Show_Constellations WHERE constellation_id = p_constellation_id;
        DELETE FROM Constellations WHERE constellation_id = p_constellation_id;
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in Constellations for id: ', p_constellation_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- DELETE Stars

DROP PROCEDURE IF EXISTS sp_DeleteStars;

DELIMITER //

CREATE PROCEDURE sp_DeleteStars(IN p_star_id INT)

BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Show_Stars WHERE star_id = p_star_id;
        DELETE FROM Stars WHERE star_id = p_star_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in stars for id: ', p_customer_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- DELETE Shows

DROP PROCEDURE IF EXISTS sp_DeleteShows;

DELIMITER //

CREATE PROCEDURE sp_DeleteShows(IN p_show_id INT)

BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Show_Constellations WHERE show_id = p_show_id;
        DELETE FROM Show_Stars WHERE show_id = p_show_id;
        DELETE FROM Show_Customers WHERE show_id = p_show_id;
        DELETE FROM Shows WHERE show_id = p_show_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in show for id: ', p_customer_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;

-- DELETE CUSTOMER

DROP PROCEDURE IF EXISTS sp_DeleteCustomer;

DELIMITER //

CREATE PROCEDURE sp_DeleteCustomer(IN p_customer_id INT)

BEGIN
    DECLARE error_message VARCHAR(255); 

    -- error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Roll back the transaction on any error
        ROLLBACK;
        -- Propogate the custom error message to the caller
        RESIGNAL;
    END;

    START TRANSACTION;
        DELETE FROM Show_Customers WHERE customer_id = p_customer_id;
        DELETE FROM Customers WHERE customer_id = p_customer_id;

        -- ROW_COUNT() returns the number of rows affected by the preceding statement.
        IF ROW_COUNT() = 0 THEN
            set error_message = CONCAT('No matching record found in customer for id: ', p_customer_id);
            -- Trigger custom error, invoke EXIT HANDLER
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = error_message;
        END IF;

    COMMIT;

END //
DELIMITER ;
