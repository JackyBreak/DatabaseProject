DROP DATABASE IF EXISTS `demo`;
CREATE DATABASE `demo`;
USE `demo`;
CREATE TABLE `userTable`(
`userId` INT(5) PRIMARY KEY auto_increment,
`username` VARCHAR(50) NOT NULL,
`password` VARCHAR(50) NOT NULL,
`firstName` VARCHAR(50) NOT NULL,
`lastName` VARCHAR(50) NOT NULL,
`dateOfBirth` DATE NOT NULL,
`gender` VARCHAR(50) NOT NULL,
`country` VARCHAR(50) NOT NULL,
`state` VARCHAR(50) NOT NULL,
`city` VARCHAR(50) NOT NULL,
`address1` VARCHAR(50) NOT NULL,
`address2` VARCHAR(50),
`zipCode` INT(5) NOT NULL,
`email` VARCHAR(50) NOT NULL
);

CREATE TABLE `passengertable`(
	`passengerId` INT(5) auto_increment,
    `firstName` VARCHAR(50) NOT NULL,
    `lastName` VARCHAR(50) NOT NULL,
    `dateOfBirth` DATE NOT NULL,
    `gender` VARCHAR(50) NOT NULL,
    `country` VARCHAR(50) NOT NULL,
    `userId` INT(5),
    PRIMARY KEY (`passengerId`),
    FOREIGN KEY (`userId`) REFERENCES usertable(`userId`)
);

CREATE TABLE `routestable`(
	`routeId` INT(5) AUTO_INCREMENT,
    `airportName1` VARCHAR(5) NOT NULL,
	`airportName2` VARCHAR(5) NOT NULL,
    PRIMARY KEY(`routeId`)
);

CREATE TABLE `aircraftstable`(
	`aircraftId` INT(5) AUTO_INCREMENT,
    `capacity` INT(3) NOT NULL,
    PRIMARY KEY(`aircraftId`)
);

CREATE TABLE `flightstable` (
	`flightId` INT(5) AUTO_INCREMENT,
    `departureCity` VARCHAR(5) NOT NULL,
    `arrivalCity` VARCHAR(5) NOT NULL,
    `departureTime` DATETIME NOT NULL,
    `arrivalTime` DATETIME AS (DATE_ADD(`departureTime`, interval 2 HOUR)),
    `aircraftId` INT(5) NOT NULL,
    `maxCapacity` INT(3) NOT NULL,
    `currentCapacity` INT(3) NOT NULL,
    PRIMARY KEY(`flightId`)
);

CREATE TABLE `user_flight_schedule`(
	`scheduleId` INT(5) AUTO_INCREMENT,
    `userId` INT(5) NOT NULL,
    `flightId` INT(5) NOT NULL,
    PRIMARY KEY(`scheduleId`),
    FOREIGN KEY(`flightId`) REFERENCES flightstable(`flightId`),
    FOREIGN KEY(`userId`) REFERENCES usertable(`userId`)
);

DELIMITER //
CREATE PROCEDURE showPassengerWithUserId(IN user_id INT(5))
BEGIN
SELECT passengerId, firstName, lastName, dateOfBirth, gender, country
FROM passengertable
WHERE userId=user_id;
END //

CREATE PROCEDURE generateDateTimes()
BEGIN
DECLARE x INT;
SET x=100;
WHILE x>0 DO
INSERT INTO `timeschedule` (departureTime) VALUES
(FROM_UNIXTIME(UNIX_TIMESTAMP('2019-04-24 00:00:00') + FLOOR(0 + (RAND() * 2592000))));
SET x=x-1;
END WHILE;
END //

CREATE PROCEDURE generateFlights()
BEGIN
DECLARE x INT;
DECLARE y INT;
DECLARE z INT;
SET x=500;
WHILE x>0 DO
SET y=(FLOOR(1 + (RAND() * 6)));
SET z=(FLOOR(1 + (RAND() * 9)));
INSERT INTO `flightstable` (departureCity, arrivalCity, departureTime, aircraftId, maxCapacity, currentCapacity)
VALUES ((SELECT airportName1 FROM routestable WHERE routeId=y), (SELECT airportName2 FROM routestable WHERE routeID=y), (FROM_UNIXTIME(UNIX_TIMESTAMP('2019-04-24 00:00:00') + FLOOR(0 + (RAND() * 2592000)))), z, (SELECT aircraftstable.capacity FROM aircraftstable WHERE aircraftstable.aircraftId = z ), (SELECT aircraftstable.capacity FROM aircraftstable WHERE aircraftstable.aircraftId = z ));
SET x=x-1;
END WHILE;
END //

CREATE PROCEDURE searchFlights(IN input_dep VARCHAR(5), IN input_arr VARCHAR(5), IN input_date DATE)
BEGIN
SELECT flightId, departureCity, arrivalCity, departureTime, arrivalTime, aircraftId, currentCapacity FROM flightstable WHERE departureCity = input_dep AND arrivalCity = input_arr AND DATE(departureTime)=input_date;
END //

CREATE PROCEDURE addFlights(IN user_id INT(5), IN flight_id INT(5))
BEGIN
DECLARE numberOfPassenger INT(5);
DECLARE beforeCapacity INT(5);
DECLARE afterCapacity INT(5);
SET numberOfPassenger = (SELECT COUNT(passengerId) FROM `passengertable` WHERE `userId` = user_id);
SET beforeCapacity = (SELECT currentCapacity FROM flightstable WHERE flightId=flight_id);
SET afterCapacity = beforeCapacity-numberOfPassenger;

INSERT INTO `user_flight_schedule` (userId, flightId) VALUES (user_id, flight_id);

UPDATE `flightstable` SET `currentCapacity` = afterCapacity WHERE `flightId`=flight_id;
END //

CREATE PROCEDURE checkIn(IN first_name VARCHAR(50), IN last_name VARCHAR(50))
BEGIN
DECLARE user_id INT(5);
DECLARE flight_id INT(5);
SET user_id = (SELECT userId FROM passengertable WHERE first_name= firstName AND last_name= lastName);
SET flight_id = (SELECT flightId FROM user_flight_schedule WHERE userId=user_id);
SELECT departureCity, arrivalCity, departureTime, arrivalTime, aircraftId FROM flightstable WHERE flightId=flight_id;
END //
DELIMITER ;


INSERT INTO `usertable` VALUES
(1, 'Jacky', '1234', 'Jacky', 'Zheng', "1997-07-26", "M", "United States", "Iowa", "Iowa City", "602 Westgate St.", NULL, 52246, "jian-zheng@uiowa.edu"),
(2, 'Laoju', '4321', 'Laoju', 'Wang', '1994-09-15', 'M', 'China', 'Shanghai', 'Shanghai', 'Random Address', NULL, 10099, 'LaojuWang@qq.com');

INSERT INTO `demo`.`usertable` (`username`, `password`, `firstName`, `lastName`, `dateOfBirth`, `gender`, `country`, `state`, `city`, `address1`, `zipCode`, `email`) VALUES 
('AdaW', '1234', 'Ada', 'Wang', '1988-12-12', 'F', 'United States', 'Iowa', 'Iowa City', '602 Eastgate St.', '52246', 'ada-wang@gmail.com');

INSERT INTO `demo`.`passengertable` (`firstName`, `lastName`, `dateOfBirth`, `gender`, `country`, `userId`) VALUES ('Ada', 'Wang', '1989-12-12', 'F', 'China', 1);
INSERT INTO `demo`.`passengertable` (`firstName`, `lastName`, `dateOfBirth`, `gender`, `country`, `userId`) VALUES ('Andrew', 'Wilson', '1965-11-08', 'M', 'United States',1);
INSERT INTO `demo`.`passengertable` (`firstName`, `lastName`, `dateOfBirth`, `gender`, `country`, `userId`) VALUES ('Kirk', 'William', '1988-01-25', 'F', 'United States',1);
INSERT INTO `demo`.`passengertable` (`firstName`, `lastName`, `dateOfBirth`, `gender`, `country`, `userId`) VALUES ('GMC', 'Terrain', '2012-01-01', 'M', 'United States',2);
INSERT INTO `passengertable` (firstName, lastName, dateOfBirth, gender, country, userId) VALUES ('Jacky', 'Zheng', "1997-07-26", 'M', 'China', 1);
INSERT INTO `aircraftstable` (capacity) VALUES (250), (200), (100), (300), (70), (75),(50), (30), (210);
INSERT INTO `routestable` (airportName1, airportName2)VALUES ('CID','ORD'),('CID','DTW'),('ORD','DTW'), ('ORD', 'CID'), ('DTW', 'CID'), ('DTW','ORD');
CALL generateFlights();
									
