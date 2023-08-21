/*-----------------------*/
/*-----CUSTOMER-1145-----*/
/*-----------------------*/

ALTER TABLE `customerdb`.`agent_notes` 
ADD COLUMN `Party_Name` VARCHAR(200) NULL DEFAULT NULL AFTER `Channel`,
ADD COLUMN `Contact_Info` VARCHAR(200) NULL DEFAULT NULL AFTER `Party_Name`,
ADD COLUMN `Type` VARCHAR(50) NULL DEFAULT NULL AFTER `Contact_Info`,
ADD COLUMN `Pin_Flag` VARCHAR(1) NULL DEFAULT NULL AFTER `Type`;