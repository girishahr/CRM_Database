/*------------------------*/
/*---Insert Transaction---*/
/*------------------------*/

DELIMITER $$
DROP PROCEDURE IF EXISTS insert_transaction $$
CREATE PROCEDURE insert_transaction (IN table_name text, IN command LONGTEXT) 
    BEGIN
       DECLARE duplicate_key INT DEFAULT 0;
                 DECLARE code CHAR(5) DEFAULT '00000';
                 DECLARE msg TEXT;
                 DECLARE nrows INT;
                 DECLARE result TEXT;
				 DECLARE batch_id INT DEFAULT 1001;
       BEGIN
            get diagnostics condition 1 code = returned_sqlstate, msg = message_text;
       END;
       -- LOCK TABLES `case_audit_details` WRITE;
       BEGIN               
           DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT "SQLEXCEPTION occured" AS errorMessage;
           DECLARE EXIT HANDLER FOR SQLSTATE "23000" SELECT "SQLSTATE 23000" AS errorMessage; 
		   SET SQL_SAFE_UPDATES = 0;
		   
		   SET batch_id = (SELECT MAX(BATCH_ID) FROM AUDIT_DETAILS);
		   IF batch_id IS NOT NULL THEN
				SET batch_id = (SELECT MAX(BATCH_ID) FROM AUDIT_DETAILS) + 1;
           ELSE
				SET batch_id = 1001;
		   END IF;
			
				  SET @query = command;
				  PREPARE stmt FROM @query;
				  EXECUTE stmt;
				  
           IF duplicate_key = 1 THEN
				INSERT INTO audit_details (migration_date, batch_id, table_name, message)
				SELECT CURRENT_TIMESTAMP AS migration_date, batch_id, table_name AS table_name, 'Duplicate key ignored' AS message;
           END IF;
		   
           IF code = '00000' THEN
				GET DIAGNOSTICS nrows = ROW_COUNT;
				IF nrows != 0 THEN
					SET result = CONCAT('insert succeeded, row count = ',nrows);
					INSERT INTO audit_details (migration_date, batch_id, table_name, message)
					SELECT CURRENT_TIMESTAMP AS migration_date, batch_id, table_name AS table_name, result AS message;
                END IF;
              ELSE
                SET result = CONCAT('insert failed, error = ',code,', message = ',msg);
                INSERT INTO audit_details (migration_date, batch_id, table_name, message)
                SELECT CURRENT_TIMESTAMP AS migration_date, batch_id, table_name AS table_name, result AS message;
           END IF;                            
        END;
END $$
DELIMITER ;

/*------------------------*/
/*---Delete Transaction---*/
/*------------------------*/

DELIMITER $$
DROP PROCEDURE IF EXISTS delete_transaction $$
CREATE PROCEDURE delete_transaction (IN table_name text, IN command LONGTEXT) 
    BEGIN
       DECLARE duplicate_key INT DEFAULT 0;
                 DECLARE code CHAR(5) DEFAULT '00000';
                 DECLARE msg TEXT;
                 DECLARE nrows INT;
                 DECLARE result TEXT;
       BEGIN
            get diagnostics condition 1 code = returned_sqlstate, msg = message_text;
       END;
       -- LOCK TABLES `case_audit_details` WRITE;
       BEGIN               
           DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT "SQLEXCEPTION occured" AS errorMessage;
           DECLARE EXIT HANDLER FOR SQLSTATE "23000" SELECT "SQLSTATE 23000" AS errorMessage; 
		   SET SQL_SAFE_UPDATES = 0;
		   
				  SET @query = command;
				  PREPARE stmt FROM @query;
				  EXECUTE stmt;
				  
           IF duplicate_key = 1 THEN
                INSERT INTO audit_details (migration_date, table_name, message)
				SELECT CURRENT_TIMESTAMP AS migration_date, table_name AS table_name, 'Duplicate key ignored' AS message;
           END IF;
		   
           IF code = '00000' THEN
                GET DIAGNOSTICS nrows = ROW_COUNT;
				IF nrows != 0 THEN
					SET result = CONCAT('delete succeeded, row count = ',nrows);
					INSERT INTO audit_details (migration_date, table_name, message)
					SELECT CURRENT_TIMESTAMP AS migration_date, table_name AS table_name, result AS message;
                END IF;
              ELSE
                SET result = CONCAT('delete failed, error = ',code,', message = ',msg);
                INSERT INTO audit_details (migration_date, table_name, message)
                SELECT CURRENT_TIMESTAMP AS migration_date, table_name AS table_name, result AS message;
           END IF;                            
        END;
END $$
DELIMITER ;

/*--------------------------*/
/*---Truncate Transaction---*/
/*--------------------------*/

DELIMITER $$
DROP PROCEDURE IF EXISTS truncate_transaction $$
CREATE PROCEDURE truncate_transaction (IN table_name text, IN command LONGTEXT) 
    BEGIN
       DECLARE duplicate_key INT DEFAULT 0;
                 DECLARE code CHAR(5) DEFAULT '00000';
                 DECLARE msg TEXT;
                 DECLARE nrows INT;
                 DECLARE result TEXT;
       BEGIN
            get diagnostics condition 1 code = returned_sqlstate, msg = message_text;
       END;
       -- LOCK TABLES `case_audit_details` WRITE;
       BEGIN               
           DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT "SQLEXCEPTION occured" AS errorMessage;
           DECLARE EXIT HANDLER FOR SQLSTATE "23000" SELECT "SQLSTATE 23000" AS errorMessage; 
		   SET SQL_SAFE_UPDATES = 0;
		   
				  SET @query = command;
				  PREPARE stmt FROM @query;
				  EXECUTE stmt;
				  
           IF duplicate_key = 1 THEN
                INSERT INTO audit_details (migration_date, table_name, message)
				SELECT CURRENT_TIMESTAMP AS migration_date, table_name AS table_name, 'Duplicate key ignored' AS message;
           END IF;
		   
           IF code = '00000' THEN
                GET DIAGNOSTICS nrows = ROW_COUNT;
				IF nrows != 0 THEN
					SET result = CONCAT('truncate succeeded, row count = ',nrows);
					INSERT INTO audit_details (migration_date, table_name, message)
					SELECT CURRENT_TIMESTAMP AS migration_date, table_name AS table_name, result AS message;
				END IF;
              ELSE
                SET result = CONCAT('truncate failed, error = ',code,', message = ',msg);
                INSERT INTO audit_details (migration_date, table_name, message)
                SELECT CURRENT_TIMESTAMP AS migration_date, table_name AS table_name, result AS message;
           END IF;                            
        END;
END $$
DELIMITER ;

/********* Insert Party ID *********/

DELIMITER $$
DROP PROCEDURE IF EXISTS insert_party_id $$
CREATE PROCEDURE insert_party_id () 
    BEGIN
        DECLARE crs INT DEFAULT 0; 
        DECLARE TOT_CNT BIGINT(10);
		DECLARE Max_party_id BIGINT;
		DECLARE Party_id_cnt BIGINT;
        SET SQL_SAFE_UPDATES = 0;
        SET TOT_CNT= (select count(id) as count from clients);
		SET Party_id_cnt = (select count(*) from party limit 10);
		SET Max_party_id = (select right(max(party_id),5) AS Max_party_id from party where Created_By='MIG_Sample_Data');
        
        DROP TEMPORARY TABLE IF EXISTS sequence_number;
        CREATE TEMPORARY TABLE `sequence_number` (
              Sequence_id bigint NOT NULL AUTO_INCREMENT,
              party_id bigint DEFAULT NULL,
              batch_number bigint,
              cbs_party_id bigint,
              PRIMARY KEY (`Sequence_id`),
			  KEY `idx_Seq_cbs_party_id` (`cbs_party_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

        DROP TEMPORARY TABLE IF EXISTS party_id_seq_num;
        CREATE TEMPORARY TABLE `party_id_seq_num` (
              Sequence_id bigint NOT NULL AUTO_INCREMENT,
              cbs_party_id bigint DEFAULT NULL,
              PRIMARY KEY (`Sequence_id`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
			
		IF Max_party_id=0 or Party_id_cnt=0 THEN
			SET Max_party_id=72000;
		ELSE 
			SET Max_party_id=Max_party_id+1;
		END IF;

        WHILE crs < TOT_CNT DO
            Insert INTO sequence_number(party_id,batch_number)
            select CONCAT(substring(DATE_FORMAT(current_date, "%Y"),-2,2) ,(case length(DAYOFYEAR(current_date)) WHEN  1 then CONCAT(00,DAYOFYEAR(current_date)) 
                                        when 2 then CONCAT(0,DAYOFYEAR(current_date))
                                        when 3 then DAYOFYEAR(current_date) end),lpad(Max_party_id,5,'0'))+(crs+1) as sequnence_number,
                                        CONCAT(substring(DATE_FORMAT(current_date, "%Y"),-2,2) ,(case length(DAYOFYEAR(current_date)) WHEN  1 then CONCAT(00,DAYOFYEAR(current_date)) 
                                        when 2 then CONCAT(0,DAYOFYEAR(current_date))
                                        when 3 then DAYOFYEAR(current_date) end));
            SET crs = crs + 1;
        END WHILE;

      -- Truncate table party_id_seq_num;
        INSERT INTO party_id_seq_num(cbs_party_id)
        SELECT /*+PARALLEL(32) USE_HASH(4)*/ DISTINCT id
        FROM clients
        ORDER BY creation_date ASC; 

        UPDATE sequence_number B USE INDEX (idx_Seq_cbs_party_id)
        INNER JOIN party_id_seq_num A ON B.Sequence_id = A.Sequence_id
        SET b.cbs_party_id=a.cbs_party_id;

    END $$
DELIMITER ;

/********* Migration of data with SP's *********/

DELIMITER $$
DROP PROCEDURE IF EXISTS SP_Migration $$
CREATE PROCEDURE `SP_Migration`()
BEGIN

CREATE TABLE IF NOT EXISTS Batch_Duration (
`Id` bigint NOT NULL AUTO_INCREMENT,
`Batch_Name` VARCHAR(50) DEFAULT NULL,
`Batch_Start` DATETIME DEFAULT NULL,
`Batch_End` DATETIME DEFAULT NULL,
`Batch_Duration` VARCHAR(100) DEFAULT NULL,
PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO Batch_Duration (`Batch_Name`, `Batch_Start`)
SELECT 'Data Migration' AS Batch_Name, CURRENT_TIMESTAMP AS Batch_Start;

/*---------------------*/
/*----Staging Table----*/
/*---------------------*/

-- SET GLOBAL MAX_ALLOWED_PACKET=67108864;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
-- SET @@SESSION.SQL_LOG_BIN= 0;
-- SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';
-- SET GLOBAL local_infile = true;
SET SESSION group_concat_max_len = 1000000;
-- SET bulk_insert_buffer_size= 1024 * 1024 * 256;
-- SET global general_log_file='C:/migration/detail.log';
-- SET global log_output = 'file';
-- SET global general_log = on;
-- SET global max_allowed_packet=128000000; 

/*----------------------------*/
/*----ODS Schema_Structure----*/
/*----------------------------*/

/*----Clients----*/

CREATE TABLE IF NOT EXISTS `temp_clients` (
  `last_name` varchar(50) DEFAULT NULL,
  `migration_event_key` varchar(100) DEFAULT NULL,
  `preferred_language` varchar(30) DEFAULT NULL,
  `notes` varchar(50) DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `group_loan_cycle` int DEFAULT NULL,
  `email_address` varchar(50) DEFAULT NULL,
  `encoded_key` varchar(100) DEFAULT NULL,
  `id` bigint NOT NULL,
  `state` varchar(20) DEFAULT NULL,
  `assigned_user_key` varchar(100) DEFAULT NULL,
  `client_role_key` varchar(100) DEFAULT NULL,
  `last_modified_date` varchar(50) DEFAULT NULL,
  `home_phone` varchar(30) DEFAULT NULL,
  `creation_date` varchar(50) DEFAULT NULL,
  `birth_date` varchar(20) DEFAULT NULL,
  `assigned_centre_key` varchar(100) DEFAULT NULL,
  `approved_date` varchar(50) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `profile_picture_key` varchar(100) DEFAULT NULL,
  `profile_signature_key` varchar(100) DEFAULT NULL,
  `mobile_phone` varchar(30) DEFAULT NULL,
  `closed_date` varchar(50) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `activation_date` varchar(50) DEFAULT NULL,
  `_sdc_received_at` varchar(50) DEFAULT NULL,
  `_sdc_sequence` bigint DEFAULT NULL,
  `_sdc_table_version` varchar(50) DEFAULT NULL,
  `_sdc_batched_at` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----Clients_Addresses----*/

CREATE TABLE IF NOT EXISTS `temp_clients__addresses` (
  `country` varchar(20) DEFAULT NULL,
  `parent_key` varchar(100) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `latitude` varchar(20) DEFAULT NULL,
  `postcode` varchar(20) DEFAULT NULL,
  `index_in_list` int DEFAULT NULL,
  `encoded_key` varchar(100) DEFAULT NULL,
  `region` varchar(200) DEFAULT NULL,
  `line2` varchar(200) DEFAULT NULL,
  `line1` varchar(200) DEFAULT NULL,
  `longitude` varchar(20) DEFAULT NULL,
  `_sdc_source_key_id` bigint DEFAULT NULL,
  `_sdc_sequence` bigint DEFAULT NULL,
  `_sdc_level_0_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----Clients_Custom_Fields----*/

CREATE TABLE IF NOT EXISTS `temp_clients__custom_fields` (
  `field_set_id` varchar(100) DEFAULT NULL,
  `id` varchar(100) DEFAULT NULL,
  `value` varchar(12000) DEFAULT NULL,
  `_sdc_source_key_id` BIGINT DEFAULT NULL,
  `_sdc_sequence` varchar(50) DEFAULT NULL,
  `_sdc_level_0_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----Clients_ID_Documents----*/

CREATE TABLE IF NOT EXISTS `temp_clients__id_documents` (
  `identification_document_template_key` varchar(100) DEFAULT NULL,
  `issuing_authority` varchar(200) DEFAULT NULL,
  `client_key` varchar(100) DEFAULT NULL,
  `document_type` varchar(50) DEFAULT NULL,
  `index_in_list` int DEFAULT NULL,
  `valid_until` varchar(30) DEFAULT NULL,
  `encoded_key` varchar(100) DEFAULT NULL,
  `document_id` varchar(100) DEFAULT NULL,
  `_sdc_source_key_id` bigint DEFAULT NULL,
  `_sdc_sequence` bigint DEFAULT NULL,
  `_sdc_level_0_id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----Audit_Details----*/

CREATE TABLE IF NOT EXISTS `audit_details` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `Batch_id` bigint NOT NULL DEFAULT 1001,
  `migration_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `table_name` varchar(100) NOT NULL,
  `message` varchar(5000) NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----ODS_Audit_Replica----*/

CREATE TABLE IF NOT EXISTS `ods_audit_replica` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `migration_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `max_creation_date` date NULL,
  `max_last_modified_date` date NULL,
  `Flag` Int DEFAULT 0,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----------------------------------*/
/*----Migration Schema Structure----*/
/*----------------------------------*/

/****** mig_clients ******/

CREATE TABLE IF NOT EXISTS `mig_clients` (
  `party_id` bigint NOT NULL,
  `cbs_party_id` bigint NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `middle_name` varchar(50) DEFAULT NULL,
  `dob` varchar(20) DEFAULT NULL,
  `gender` varchar(20) DEFAULT NULL,
  `salutation` text,
  `suffix` text,
  `civil_Status` text,
  `place_Of_Birth` text,
  `nationality` text,
  `no_Of_Dependents` text,
  `arn_No` text,
  `idm_Arn_No` text,
  `party_status` varchar(20) DEFAULT NULL,
  `Is_DOSRI` int NOT NULL DEFAULT '0',
  `IS_RPT` int NOT NULL DEFAULT '0',
  `is_fatca` varchar(10) DEFAULT NULL,
  `party_type` text,
  `preferred_address_id` int NOT NULL DEFAULT '0',
  `fatca_W9_IdType` text,
  `fatca_W9_IdNumber` text,
  `App_Channel_Type` varchar(3) NOT NULL DEFAULT '',
  `App_Product_Type` binary(0) DEFAULT NULL,
  `App_Party_Type` binary(0) DEFAULT NULL,
  `Channel_Type` binary(0) DEFAULT NULL,
  `Product_Type` binary(0) DEFAULT NULL,
  `sssgsis` text,
  `tinid` text,
  `Is_Record_Edited` binary(0) DEFAULT NULL,
  `Party_matrix_header_Id` binary(0) DEFAULT NULL,
  `My_Job` text,
  `Card_Issuance_Status` text,
  `is_active` int DEFAULT NULL,
  `created_date` datetime DEFAULT NULL,
  `created_by` varchar(50) DEFAULT NULL,
  `approved_date` datetime DEFAULT NULL,
  `activation_date` datetime DEFAULT NULL,
  KEY `idx_mig_cbs_party_id` (`cbs_party_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Party ******/

CREATE TABLE IF NOT EXISTS `party` (
  `Row_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `CBS_party_id` varchar(10) DEFAULT NULL,
  `First_Name` varchar(50) NOT NULL,
  `Last_Name` varchar(50) DEFAULT NULL,
  `Middle_Name` varchar(50) DEFAULT NULL,
  `DOB` date DEFAULT NULL,
  `Gender` varchar(20) DEFAULT NULL,
  `Salutation` varchar(20) DEFAULT NULL,
  `Suffix` varchar(32) DEFAULT NULL,
  `Civil_Status` varchar(20) DEFAULT NULL,
  `Place_Of_Birth` varchar(75) DEFAULT NULL,
  `Nationality` varchar(75) DEFAULT NULL,
  `No_Of_Dependents` varchar(75) DEFAULT NULL, -- varchar(32)
  `Arn_No` varchar(50) DEFAULT NULL,
  `Idm_Arn_No` varchar(45) DEFAULT NULL,
  `Party_Status` varchar(75) NOT NULL,
  `Is_DOSRI` tinyint DEFAULT NULL,
  `Is_RPT` tinyint DEFAULT NULL,
  `Is_FATCA` varchar(10) DEFAULT NULL,
  `Party_Type` varchar(30) DEFAULT NULL,
  `Preferred_Address_Id` varchar(50) DEFAULT NULL,
  `fatca_W9_IdType` varchar(100) DEFAULT NULL,
  `fatca_W9_IdNumber` varchar(100) DEFAULT NULL,
  `App_Channel_Type` varchar(50) DEFAULT NULL,
  `App_Product_Type` varchar(50) DEFAULT NULL,
  `App_Party_Type` varchar(50) DEFAULT NULL,
  `Channel_Type` varchar(50) DEFAULT NULL,
  `Product_Type` varchar(50) DEFAULT NULL,
  `sssGsis` varchar(75) DEFAULT NULL,
  `tinId` varchar(75) DEFAULT NULL,
  `Is_Record_Edited` tinyint DEFAULT NULL,
  `Party_matrix_header_Id` varchar(20) DEFAULT NULL,
  `My_Job` varchar(100) DEFAULT NULL,
  `card_Issuance_Status` varchar(10) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Approved_Date` datetime DEFAULT NULL,
  `Activation_Date` datetime DEFAULT NULL,
  `Updated_Date` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Row_Id`),
  KEY `FK_Person_User_CivilStatus_idx` (`Civil_Status`),
  KEY `FK_Person_User_CustomerIdType_idx` (`Party_Type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Address ******/

CREATE TABLE IF NOT EXISTS `address` (
  `Address_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Address_Type` varchar(50) NOT NULL,
  `Number_And_Street` varchar(100) DEFAULT NULL,
  `Barangay` varchar(100) DEFAULT NULL,
  `LandMark` varchar(100) DEFAULT NULL,
  `Comments` varchar(100) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `State` varchar(100) DEFAULT NULL,
  `Region` varchar(100) DEFAULT NULL,
  `Country` varchar(100) DEFAULT NULL,
  `Country_Code` varchar(20) DEFAULT NULL,
  `Zip_Code` varchar(20) DEFAULT NULL,
  `Nom_Index` varchar(30) DEFAULT NULL,
  `Date_Since_Residing` varchar(20) DEFAULT NULL,
  `Is_Preferred_Address` tinyint NOT NULL,
  `Province` varchar(100) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Address_Id`),
  UNIQUE KEY `AddressId_UNIQUE` (`Address_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Consent_Details ******/

CREATE TABLE IF NOT EXISTS `consent_details` (
  `Consent_Details_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `Consent_Type` varchar(50) NOT NULL,
  `Consent_Capture_Source` varchar(50) NOT NULL,
  `Consent_Channel` varchar(50) DEFAULT NULL,
  `Status` tinyint NOT NULL,
  `Comments` varchar(100) DEFAULT NULL,
  `Consent_Details` json DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) DEFAULT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Consent_Details_Id`),
  UNIQUE KEY `Consent_Details_Id_UNIQUE` (`Consent_Details_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Contact ******/

CREATE TABLE IF NOT EXISTS `contact` (
  `Contact_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `Contact_Type` varchar(50) NOT NULL,
  `Contact_Value` varchar(150) NOT NULL,
  `Contact_Period` varchar(20) DEFAULT NULL,
  `Is_Preferred` tinyint DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Contact_Id`),
  UNIQUE KEY `ContactId_UNIQUE` (`Contact_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Party_Status ******/

CREATE TABLE IF NOT EXISTS `party_status` (
  `Status_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `CBS_party_id` varchar(10) DEFAULT NULL,
  `Status_Type` varchar(100) NOT NULL,
  `Status_Flag` tinyint DEFAULT '0',
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Status_Id`),
  UNIQUE KEY `Status_Id_UNIQUE` (`Status_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Relationship ******/

CREATE TABLE IF NOT EXISTS `relationship` (
  `Relationship_Id` int NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Relationship_Type` varchar(30) DEFAULT NULL,
  `Name` varchar(300) NOT NULL,
  `DOB` date DEFAULT NULL,
  `Nationality` varchar(50) DEFAULT NULL,
  `Address` json DEFAULT NULL,
  `Share_Percentage` bigint DEFAULT NULL,
  `Is_Nominee` varchar(1) DEFAULT NULL,
  `Nominee_Index` varchar(10) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Relationship_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** System_Integration_Status ******/

CREATE TABLE IF NOT EXISTS `system_integration_status` (
  `SIS_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `System_Name` varchar(100) NOT NULL,
  `Enrollment_Status` varchar(10) NOT NULL DEFAULT 'P',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`SIS_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Occupation ******/

CREATE TABLE IF NOT EXISTS `occupation` (
  `Occupation_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `Nature_Of_Occupation` varchar(100) DEFAULT NULL,
  `Nature_Of_Occupation_Code` varchar(32) DEFAULT NULL,
  `Organization` varchar(100) DEFAULT NULL,
  `Industry_Type` varchar(75) DEFAULT NULL,
  `Industry_Type_Code` varchar(30) DEFAULT NULL,
  `Occupation_Type` varchar(75) DEFAULT NULL,
  `Occupation_Type_Code` varchar(30) DEFAULT NULL,
  `Occupation_Status` varchar(75) DEFAULT NULL,
  `Occupation_Status_Code` varchar(30) DEFAULT NULL,
  `Date_Of_Commencement` varchar(30) DEFAULT NULL,
  `Monthly_Income` varchar(20) DEFAULT NULL,
  `Annual_Income` varchar(20) DEFAULT NULL,
  `Fund_Source_Name` varchar(75) DEFAULT NULL,
  `Fund_Source_Code` varchar(75) DEFAULT NULL,
  `Source_Of_Wealth` varchar(100) DEFAULT NULL,
  `Proof_Of_SOW` varchar(100) DEFAULT NULL,
  `Party_Linked_Companies` varchar(200) DEFAULT NULL,
  `Party_Banks` varchar(200) DEFAULT NULL,
  `Proof_Of_Address` varchar(100) DEFAULT NULL,
  `Proof_Of_Income` varchar(50) DEFAULT NULL,
  `Salary_Period` varchar(50) DEFAULT NULL,
  `Salary_Dates` varchar(30) DEFAULT NULL,
  `Proof_Of_Billing` varchar(100) DEFAULT NULL,
  `Profession` varchar(50) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Occupation_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** KYC_Details ******/

CREATE TABLE IF NOT EXISTS `kyc_details` (
  `KYC_Details_Id` int NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `Document_Id` varchar(100) NOT NULL,
  `Document_Type` varchar(100) NOT NULL,
  `Issuing_Authority` varchar(100) DEFAULT NULL,
  `Valid_Until` varchar(20) DEFAULT NULL,
  `National_Id` varchar(75) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`KYC_Details_Id`),
  KEY `FK_KYCHighRisk_Person_idx` (`Party_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Asset_Details ******/

CREATE TABLE IF NOT EXISTS `asset_details` (
  `Asset_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Asset_Number` varchar(30) NOT NULL,
  `Asset_Description` varchar(100) DEFAULT NULL,
  `Product_Id` bigint DEFAULT NULL,
  `Purchase_Date` date DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Price` float DEFAULT NULL,
  `Valid_Upto` date DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) DEFAULT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Asset_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Device_Details ******/

CREATE TABLE IF NOT EXISTS `device_details` (
  `Device_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Device_IP` varchar(35) NOT NULL, -- varchar(15)
  `Latitude` decimal DEFAULT NULL,
  `Longitude` decimal DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Device_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** External_System_Response ******/

CREATE TABLE IF NOT EXISTS `external_system_response` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `External_System_Name` varchar(50) NOT NULL,
  `External_Response_Details` json DEFAULT NULL,
  `Overall_Status` varchar(100) DEFAULT NULL,
  `Case_Id` varchar(100) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Consent_Details_Id_UNIQUE` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/****** Referral_Promotion ******/

CREATE TABLE IF NOT EXISTS `referral_promotion` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Referral_Code` varchar(50) DEFAULT NULL,
  `Promo_Code` varchar(50) DEFAULT NULL,
  `Company_Code` varchar(200) DEFAULT NULL,
  `Agent_Code` varchar(50) DEFAULT NULL,
  `Ref_Promo_Flag` varchar(50) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'Y',
  PRIMARY KEY (`Id`,`Party_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*------------------------*/
/*----Replica from ODS----*/
/*------------------------*/

/*SET @max_last_modified_date := (select str_to_date(LEFT(Max(last_modified_date), 10), '%Y-%m-%d') from clients);
SET @max_creation_date := (Select str_to_date(LEFT(Max(creation_date), 10), '%Y-%m-%d') from clients);
SET @mig_flag := (Select max(flag) from ods_audit_replica);
IF @mig_flag IS NULL THEN
	INSERT INTO ods_audit_replica(`max_creation_date`, `max_last_modified_date`, `Flag`) 
	SELECT @max_creation_date, @max_last_modified_date, 0;
ELSE
	INSERT INTO ods_audit_replica(`max_creation_date`, `max_last_modified_date`, `Flag`) 
	SELECT @max_creation_date, @max_last_modified_date, 1;
END IF;*/

SET @party_cnt := (select count(*) from party limit 1);
IF @party_cnt <> 0 THEN
	DROP TABLE IF EXISTS temp_clients_count;
	CREATE TABLE temp_clients_count
	SELECT DISTINCT id as CBS_party_id, 'LD' as Flag from clients a WHERE EXISTS (SELECT 1 FROM temp_clients b WHERE a.id = b.id and a.last_modified_date <> b.last_modified_date);
	
	INSERT INTO temp_clients_count
	SELECT DISTINCT id as CBS_party_id, 'CD' as Flag from clients a WHERE NOT EXISTS (SELECT 1 FROM temp_clients b WHERE a.id = b.id);
	
	INSERT INTO temp_clients_count
	(SELECT DISTINCT _sdc_source_key_id as CBS_party_id, 'NR' as Flag from clients__addresses a 
	WHERE NOT EXISTS (SELECT 1 FROM temp_clients__addresses b WHERE a._sdc_source_key_id = b._sdc_source_key_id)
	AND EXISTS (SELECT 1 FROM temp_clients_count c WHERE c.CBS_party_id <> a._sdc_source_key_id and c.Flag = 'CD')
	UNION
	SELECT DISTINCT _sdc_source_key_id as CBS_party_id, 'NR' as Flag from clients__custom_fields a 
	WHERE NOT EXISTS (SELECT 1 FROM temp_clients__custom_fields b WHERE a._sdc_source_key_id = b._sdc_source_key_id)
	AND EXISTS (SELECT 1 FROM temp_clients_count c WHERE c.CBS_party_id <> a._sdc_source_key_id and c.Flag = 'CD')
	UNION
	SELECT DISTINCT _sdc_source_key_id as CBS_party_id, 'NR' as Flag from clients__id_documents a 
	WHERE NOT EXISTS (SELECT 1 FROM temp_clients__id_documents b WHERE a._sdc_source_key_id = b._sdc_source_key_id)
	AND EXISTS (SELECT 1 FROM temp_clients_count c WHERE c.CBS_party_id <> a._sdc_source_key_id and c.Flag = 'CD'));

ELSE
	DROP TABLE IF EXISTS temp_clients_count;
	CREATE TABLE temp_clients_count
	SELECT DISTINCT id as CBS_party_id, 'CD' as Flag from clients a;
END IF;

/*----Clients_Addresses----*/

IF @party_cnt <> 0 THEN
	CALL delete_transaction("temp_clients__addresses (LD)", "DELETE FROM temp_clients__addresses a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients__addresses (LD)", "INSERT INTO temp_clients__addresses (country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
	FROM clients__addresses a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients__addresses (CD)", "INSERT INTO temp_clients__addresses (country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id FROM clients__addresses a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='CD')");
	
	CALL delete_transaction("temp_clients__addresses (NR)", "DELETE FROM temp_clients__addresses a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	CALL insert_transaction("temp_clients__addresses (NR)", "INSERT INTO temp_clients__addresses (country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
	FROM clients__addresses a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	CALL insert_transaction("temp_clients__addresses (NR)", "INSERT INTO temp_clients__addresses (country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT * FROM clients__addresses a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
ELSE
	CALL insert_transaction("temp_clients__addresses (CD)", "INSERT INTO temp_clients__addresses (country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id FROM clients__addresses a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='CD')");
END IF ;

/*----Clients_Custom_Fields----*/

IF @party_cnt <> 0 THEN
	CALL delete_transaction("temp_clients__custom_fields (LD)", "DELETE FROM temp_clients__custom_fields a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients__custom_fields (LD)", "INSERT INTO temp_clients__custom_fields (field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
	FROM clients__custom_fields a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients__custom_fields (CD)", "INSERT INTO temp_clients__custom_fields (field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id FROM clients__custom_fields a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='CD')");
	
	CALL delete_transaction("temp_clients__custom_fields (NR)", "DELETE FROM temp_clients__custom_fields a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	CALL insert_transaction("temp_clients__custom_fields (NR)", "INSERT INTO temp_clients__custom_fields (field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
	FROM clients__custom_fields a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	CALL insert_transaction("temp_clients__custom_fields (NR)", "INSERT INTO temp_clients__custom_fields (field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT * FROM clients__custom_fields a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	
ELSE
	CALL insert_transaction("temp_clients__custom_fields (CD)", "INSERT INTO temp_clients__custom_fields (field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id FROM clients__custom_fields a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='CD')");
END IF ;

/*----Clients_ID_Documents----*/

IF @party_cnt <> 0 THEN
	CALL delete_transaction("temp_clients__id_documents (LD)", "DELETE FROM temp_clients__id_documents a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients__id_documents (LD)", "INSERT INTO temp_clients__id_documents (identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
	FROM clients__id_documents a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients__id_documents (CD)", "INSERT INTO temp_clients__id_documents (identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id FROM clients__id_documents a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='CD')");
	
	CALL delete_transaction("temp_clients__id_documents (NR)", "DELETE FROM temp_clients__id_documents a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	CALL insert_transaction("temp_clients__id_documents (NR)", "INSERT INTO temp_clients__id_documents (identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
	FROM clients__id_documents a WHERE Exists (select 1 from temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
	CALL insert_transaction("temp_clients__id_documents (NR)", "INSERT INTO temp_clients__id_documents (identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT * FROM temp_clients__id_documents a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='NR')");
ELSE
	CALL insert_transaction("temp_clients__id_documents (CD)", "INSERT INTO temp_clients__id_documents (identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
	SELECT identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id FROM clients__id_documents a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a._sdc_source_key_id=b.cbs_party_id and Flag='CD')");
END IF ;

/*----Clients----*/

IF @party_cnt <> 0 THEN
	CALL delete_transaction("temp_clients (LD)", "DELETE FROM temp_clients a WHERE Exists (select 1 from temp_clients_count b where a.id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients (LD)", "INSERT INTO temp_clients (last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at)
	SELECT last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at
	FROM clients a WHERE Exists (select 1 from temp_clients_count b where a.id=b.cbs_party_id and Flag='LD')");
	CALL insert_transaction("temp_clients (CD)", "INSERT INTO temp_clients (last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at)
	SELECT last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at FROM clients a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a.id=b.cbs_party_id and Flag='CD')");
ELSE
	CALL insert_transaction("temp_clients (CD)", "INSERT INTO temp_clients (last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at)
	SELECT last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at FROM clients a WHERE EXISTS (SELECT 1 FROM temp_clients_count b where a.id=b.cbs_party_id and Flag='CD')");
END IF ;

/*----Count_Clients (Temporary Table)----*/

DROP TABLE IF EXISTS temp_count_clients;

CREATE TABLE IF NOT EXISTS `temp_count_clients` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `CBS_party_id` bigint NOT NULL,
  `Creation_Date` date DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO temp_count_clients(CBS_party_id, Creation_Date)
SELECT /*+PARALLEL(32)*/ id as CBS_party_id, str_to_date(left(creation_date,10), '%Y-%m-%d') AS Creation_Date 
FROM temp_clients ORDER BY str_to_date(left(creation_date,10), '%Y-%m-%d');

/*----------------------*/
/*----Data Migration----*/
/*----------------------*/

/********* Matching Record is Inserted *********/

SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

CALL insert_party_id(); 

DROP TEMPORARY TABLE IF EXISTS tclients;
CREATE TEMPORARY TABLE tclients
SELECT /*+PARALLEL(32) USE_HASH(4)*/ a.id AS Party_Id,
	a.id AS CBS_party_id,
	CASE WHEN a.first_name != '' THEN a.first_name ELSE NULL END AS First_Name,
	CASE WHEN a.last_name != '' THEN a.last_name ELSE NULL END AS Last_Name,
	CASE WHEN a.middle_name != '' THEN a.middle_name ELSE NULL END AS Middle_Name,
	CASE WHEN a.birth_date != '' THEN a.birth_date ELSE NULL END AS DOB,
	CASE WHEN a.gender != '' THEN CONCAT(UPPER(SUBSTRING(a.gender,1,1)),LOWER(SUBSTRING(a.gender,2))) ELSE NULL END AS Gender,
	-- CASE WHEN a.gender != '' THEN a.gender ELSE NULL END AS Gender,
	-- a.state AS Party_Status,
	CONCAT(UPPER(SUBSTRING(a.state,1,1)),LOWER(SUBSTRING(a.state,2))) AS Party_Status,
	-- CASE WHEN a.state = "active" THEN 1 ELSE 0 END AS Is_Active,
	1 AS Is_Active,
	a.creation_date AS Created_Date,
	'MIG_Sample_Data' AS Created_By,
	CONVERT(a.approved_date, DATETIME) AS Approved_Date,
	CONVERT(a.activation_date, DATETIME) AS Activation_Date
	FROM temp_clients a WHERE EXISTS (select 1 from temp_clients_count b where a.id=b.cbs_party_id);

DROP TEMPORARY TABLE IF EXISTS tclients__custom_fields;
CREATE TEMPORARY TABLE tclients__custom_fields
SELECT /*+PARALLEL(32) USE_HASH(4)*/ _sdc_source_key_id as cbs_party_id,
	CASE b.id WHEN 'salutation' THEN IFNULL(b.value, NULL) END AS salutation,
	CASE b.id WHEN 'suffix' THEN IFNULL(b.value, NULL) END AS Suffix,
	CASE b.id WHEN 'civil_Status' THEN IFNULL(b.value, NULL) END AS Civil_Status,
	CASE b.id WHEN 'place_Of_Birth' THEN IFNULL(b.value, NULL) END AS Place_Of_Birth,
	CASE b.id WHEN 'nationality' THEN IFNULL(b.value, NULL) END AS Nationality,
	CASE b.id WHEN 'no_Of_Dependents' THEN IFNULL(b.value, NULL) END AS No_Of_Dependents,
	CASE b.id WHEN 'arn_No' THEN IFNULL(b.value, NULL) END AS Arn_No,
	CASE b.id WHEN 'arn_No' THEN IFNULL(b.value, NULL) END AS Idm_Arn_No,
	CASE b.id WHEN 'fatca_Cert_US_Non_US' THEN IFNULL(b.value, NULL) END AS Is_FATCA,
	CASE b.id WHEN 'emp_Type' THEN IFNULL(b.value, NULL) END AS Party_Type,
	CASE b.id WHEN 'fatca_W9_IdType' THEN IFNULL(b.value, NULL) END AS fatca_W9_IdType,
	CASE b.id WHEN 'fatca_W9_IdNumber' THEN IFNULL(b.value, NULL) END AS fatca_W9_IdNumber,			
	CASE b.id WHEN 'identity_SssGsisId' THEN IFNULL(b.value, NULL) END AS sssGsis,
	CASE b.id WHEN 'identity_TinId' THEN IFNULL(b.value, NULL) END AS tinId,
	CASE b.id WHEN 'my_Job' THEN IFNULL(b.value, NULL) END AS My_Job,
	CASE b.id WHEN 'card_Issuance_Status' THEN IFNULL(b.value, NULL) END AS Card_Issuance_Status
	FROM temp_clients__custom_fields b WHERE EXISTS (select 1 from temp_clients_count c where b._sdc_source_key_id=c.cbs_party_id)
	AND b.field_set_id in('_Emp_Details','_Personal_Details','_Identification_Details')
	AND b.id IN('salutation', 'civil_Status', 'place_Of_Birth', 'nationality', 'no_Of_Dependents', 'arn_No', 'idm_Arn_No', 'fatca_W9_IdType', 'fatca_W9_IdNumber','fatca_Cert_US_Non_US','emp_Type','identity_SssGsisId','identity_TinId','card_Issuance_Status','my_Job','suffix');

TRUNCATE TABLE mig_clients;   
INSERT INTO mig_clients (`party_id`, `cbs_party_id`, `first_name`, `last_name`, `middle_name`, `dob`, `gender`, `salutation`,
`suffix`, `civil_Status`, `place_Of_Birth`, `nationality`, `no_Of_Dependents`, `arn_No`, `idm_Arn_No`, `party_status`, `Is_DOSRI`,
`IS_RPT`, `is_fatca`, `party_type`, `preferred_address_id`, `fatca_W9_IdType`, `fatca_W9_IdNumber`, `App_Channel_Type`, `App_Product_Type`, `App_Party_Type`, `Channel_Type`, `Product_Type`, `sssgsis`, `tinid`, `Is_Record_Edited`, `Party_matrix_header_Id`, `My_Job`,
`Card_Issuance_Status`, `is_active`, `created_date`, `created_by`, `approved_date`, `activation_date`)
SELECT /*+PARALLEL(32) USE_HASH(4)*/ a.party_id,
	a.cbs_party_id,
	Max(first_name) AS first_name,
	Max(last_name) AS last_name,
	Max(middle_name) AS middle_name,
	Max(dob) AS dob,
	Max(gender) AS gender,
	Max(salutation) AS salutation,
	Max(suffix) AS suffix,
	Max(civil_status) AS civil_Status,
	Max(place_of_birth) AS place_Of_Birth,
	Max(nationality) AS nationality,
	Max(no_of_dependents) AS no_Of_Dependents,
	Max(arn_no) AS arn_No,
	Max(idm_arn_no) AS idm_Arn_No,
	Max(party_status) AS party_status,
	0 AS Is_DOSRI,
	0 AS IS_RPT,
	Max(is_fatca) AS is_fatca,
	Max(party_type) AS party_type,
	0 AS preferred_address_id,
	Max(fatca_W9_IdType) AS fatca_W9_IdType,
	Max(fatca_W9_IdNumber) AS fatca_W9_IdNumber,
	'APP' AS App_Channel_Type,
	NULL AS App_Product_Type,
	NULL AS App_Party_Type,
	NULL AS Channel_Type,
	NULL AS Product_Type,
	Max(sssGsis) AS sssgsis,
	Max(tinId) AS tinid,
	NULL AS Is_Record_Edited,
	NULL AS Party_matrix_header_Id,
	Max(My_Job) AS My_Job,
	Max(card_Issuance_Status) AS Card_Issuance_Status,
	Max(is_active)AS is_active,
	a.Created_Date AS created_date,
	'MIG_Sample_Data' AS created_by,
	Max(Approved_Date) AS approved_date,
	Max(Activation_Date) AS activation_date
	FROM tclients a LEFT JOIN tclients__custom_fields b on a.cbs_party_id=b.cbs_party_id GROUP BY cbs_party_id;

/*SELECT "UPDATE mig_clients";
UPDATE mig_clients B USE INDEX (idx_mig_cbs_party_id)
INNER JOIN sequence_number A ON B.cbs_party_id = A.cbs_party_id
SET b.Party_Id=a.Party_Id WHERE b.cbs_party_id not in (select id from clients);*/

UPDATE mig_clients B USE INDEX (idx_mig_cbs_party_id)
INNER JOIN sequence_number A ON B.cbs_party_id = A.cbs_party_id
SET b.Party_Id=a.Party_Id WHERE b.cbs_party_id in (select cbs_party_id from temp_clients_count where FLAG='CD');

/********* Party *********/

IF @party_cnt = 0 THEN 
	CALL insert_transaction("party", "INSERT IGNORE INTO party (party_id, cbs_party_id, first_name, last_name, middle_name, dob, gender, salutation, suffix, civil_status, place_of_birth, nationality, no_of_dependents, arn_no, idm_arn_no, party_status, is_dosri, is_rpt, is_fatca, party_type, preferred_address_id, fatca_W9_IdType, fatca_W9_IdNumber, app_channel_type, app_product_type, app_party_type, channel_type, product_type, sssgsis, tinid, is_record_edited, party_matrix_header_id, My_Job, Card_Issuance_Status, is_active, created_date, created_by, approved_date, activation_date, Is_Latest_rec) 
	SELECT /*+ PARALLEL(mig_clients 4) USE_HASH(mig_clients) ORDERED */ DISTINCT party_id, cbs_party_id, first_name, last_name, middle_name, dob, gender, salutation Salutation, suffix, civil_status, place_of_birth, nationality, no_of_dependents, arn_no, idm_arn_no, party_status, is_dosri, is_rpt, is_fatca, party_type, preferred_address_id, fatca_W9_IdType, fatca_W9_IdNumber, app_channel_type, app_product_type, app_party_type, channel_type, product_type, sssgsis, tinid, is_record_edited, party_matrix_header_id, My_Job, Card_Issuance_Status, is_active, created_date, created_by, approved_date, activation_date, 'Y' AS Is_Latest_rec FROM mig_clients
	ORDER BY party_id");
ELSE
	Update party a set Is_Latest_rec='N', is_active=0 
	where  Exists (select 1 from temp_clients_count b where a.cbs_party_id=b.cbs_party_id and b.flag='LD');

	CALL insert_transaction("party", "INSERT IGNORE INTO party (party_id, cbs_party_id, first_name, last_name, middle_name, dob, gender, salutation, suffix, civil_status, place_of_birth, nationality, no_of_dependents, arn_no, idm_arn_no, party_status, is_dosri, is_rpt, is_fatca, party_type, preferred_address_id, fatca_W9_IdType, fatca_W9_IdNumber, app_channel_type, app_product_type, app_party_type, channel_type, product_type, sssgsis, tinid, is_record_edited, party_matrix_header_id, My_Job, Card_Issuance_Status, is_active, created_date, created_by, approved_date, activation_date, Is_Latest_rec) 
	SELECT /*+ PARALLEL(mig_clients 4) USE_HASH(mig_clients) ORDERED */ DISTINCT party_id, cbs_party_id, first_name, last_name, middle_name, dob, gender, salutation Salutation, suffix, civil_status, place_of_birth, nationality, no_of_dependents, arn_no, idm_arn_no, party_status, is_dosri, is_rpt, is_fatca, party_type, preferred_address_id, fatca_W9_IdType, fatca_W9_IdNumber, app_channel_type, app_product_type, app_party_type, channel_type, product_type, sssgsis, tinid, is_record_edited, party_matrix_header_id, My_Job, Card_Issuance_Status, '1' AS is_active, created_date, created_by, approved_date, activation_date, 'Y' AS Is_Latest_rec FROM mig_clients
	ORDER BY party_id");
END IF;

/********* Address *********/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("address", "TRUNCATE TABLE address");
ELSE
	UPDATE address a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE address a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("address", "INSERT IGNORE INTO address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with Correspondence_cte as (select /*+ PARALLEL(mig_clients 4) PARALLEL(clients 4) USE_HASH(clients__addresses) ORDERED */ 
distinct a.party_id As Party_Id, 
'Correspondence Address' as Address_Type,
CASE WHEN concat(c.line1,c.line2) != '' THEN concat(c.line1, ', ', c.line2) ELSE NULL END as Number_And_Street,
NULL as Barangay,
NULL as LandMark,
NULL as Comments,
CASE WHEN c.city != '' THEN c.city ELSE NULL END as City,
NULL as State,
CASE WHEN c.region != '' THEN c.region ELSE NULL END as Region,
CASE WHEN c.country != '' THEN c.country ELSE NULL END as Country,
'PHL' as Country_Code,
CASE WHEN c.postcode != '' THEN c.postcode ELSE NULL END as Zip_Code,
NULL as Nom_Index,
NULL as Date_Since_Residing,
0 as Is_Preferred_Address,
NULL as Province,
1 as Is_Active,
CURRENT_TIMESTAMP as Created_date,
'MIG_Sample_Data' as Created_By,
'Y' as Is_Latest_rec
from mig_clients a INNER JOIN
temp_clients b INNER JOIN
temp_clients__addresses c 
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' 
THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from Correspondence_cte where Address_Type <> '' group by Party_Id");

CALL insert_transaction("address", "INSERT IGNORE INTO address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with clients__addresses as (select /*+PARALLEL(8)*/ distinct a.party_id As Party_Id, 
case d.field_set_id when '_Perm_Address' then 'Permanent Address' end as Address_Type,
case d.field_set_id when '_Perm_Address' then case d.id when 'perm_Street' then IFNULL(d.value, NULL) end end as Number_And_Street,
NULL as Barangay,
NULL as LandMark,
NULL as Comments,
case d.field_set_id when '_Perm_Address' then case d.id when 'perm_City' then IFNULL(d.value, NULL) end end as City,
case d.field_set_id when '_Perm_Address' then case d.id when 'perm_State' then IFNULL(d.value, NULL) end end as State,
c.region as Region,
case d.field_set_id when '_Perm_Address' then case d.id when 'perm_Country' then IFNULL(d.value, NULL) end end as Country,
'PHL' as Country_Code,
case d.field_set_id when '_Perm_Address' then case d.id when 'perm_ZipCode' then IFNULL(d.value, NULL) end end as Zip_Code,
NULL as Nom_Index,
NULL as Date_Since_Residing,
0 as Is_Preferred_Address,
NULL as Province,
1 as Is_Active,
CURRENT_TIMESTAMP as Created_date,
'MIG_Sample_Data' as Created_By,
'Y' as Is_Latest_rec
from mig_clients a INNER JOIN
temp_clients b INNER JOIN
temp_clients__addresses c INNER JOIN
temp_clients__custom_fields d
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id
AND d.field_set_id ='_Perm_Address'
AND b.id = d._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from clients__addresses where Address_Type <> '' group by Party_Id");

CALL insert_transaction("address", "INSERT IGNORE INTO address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with clients__addresses as (select /*+PARALLEL(8)*/ distinct a.party_id As Party_Id, 
case d.field_set_id when '_Biz_Address' then 'Business Address' end as Address_Type,
case d.field_set_id when '_Biz_Address' then case d.id when 'biz_Street' then IFNULL(d.value, NULL) end end as Number_And_Street,
NULL as Barangay,
NULL as LandMark,
NULL as Comments,
case d.field_set_id when '_Biz_Address' then case d.id when 'biz_City' then IFNULL(d.value, NULL) end end as City,
case d.field_set_id when '_Biz_Address' then case d.id when 'biz_State' then IFNULL(d.value, NULL) end end as State,
c.region as Region,
case d.field_set_id when '_Biz_Address' then case d.id when 'biz_Country' then IFNULL(d.value, NULL) end end as Country,
'PHL' as Country_Code,
case d.field_set_id when '_Biz_Address' then case d.id when 'biz_ZipCode' then IFNULL(d.value, NULL) end end as Zip_Code,
NULL as Nom_Index,
NULL as Date_Since_Residing,
0 as Is_Preferred_Address,
NULL as Province,
1 as Is_Active,
CURRENT_TIMESTAMP as Created_date,
'MIG_Sample_Data' as Created_By,
'Y' as Is_Latest_rec
from mig_clients a INNER JOIN
temp_clients b INNER JOIN
temp_clients__addresses c INNER JOIN
temp_clients__custom_fields d
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id
AND d.field_set_id ='_Biz_Address'
AND b.id = d._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from clients__addresses where Address_Type <> '' group by Party_Id");

CALL insert_transaction("address", "INSERT IGNORE INTO address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with clients__addresses as (select /*+PARALLEL(8)*/ distinct a.party_id As Party_Id, 
case d.field_set_id when '_Emp_Address' then 'Employee Address' end as Address_Type,
case d.field_set_id when '_Emp_Address' then case d.id when 'emp_Street' then IFNULL(d.value, NULL) end end as Number_And_Street,
NULL as Barangay,
NULL as LandMark,
NULL as Comments,
case d.field_set_id when '_Emp_Address' then case d.id when 'emp_City' then IFNULL(d.value, NULL) end end as City,
case d.field_set_id when '_Emp_Address' then case d.id when 'emp_State' then IFNULL(d.value, NULL) end end as State,
c.region as Region,
case d.field_set_id when '_Emp_Address' then case d.id when 'emp_Country' then IFNULL(d.value, NULL) end end as Country,
'PHL' as Country_Code,
case d.field_set_id when '_Emp_Address' then case d.id when 'emp_ZipCode' then IFNULL(d.value, NULL) end end as Zip_Code,
NULL as Nom_Index,
NULL as Date_Since_Residing,
0 as Is_Preferred_Address,
NULL as Province,
1 as Is_Active,
CURRENT_TIMESTAMP as Created_date,
'MIG_Sample_Data' as Created_By,
'Y' as Is_Latest_rec
from mig_clients a INNER JOIN
temp_clients b INNER JOIN
temp_clients__addresses c INNER JOIN
temp_clients__custom_fields d
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id
AND d.field_set_id ='_Emp_Address'
AND b.id = d._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from clients__addresses where Address_Type <> '' group by Party_Id");

/********* Address (nom_Index) *********/

DROP TEMPORARY TABLE IF EXISTS nom_clients;
CREATE TEMPORARY TABLE `nom_clients` (
    Id bigint NOT NULL AUTO_INCREMENT,
    Party_Id bigint(10) unsigned zerofill,
	CBS_party_id bigint,
    Nom_Index varchar(30),
PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO nom_clients (`CBS_party_id`, `Nom_Index`)
with nom_clients as (SELECT DISTINCT _sdc_source_key_id, case when value IN (0,1,2,3) then value end as Nom_Index 
FROM clients__custom_fields where _sdc_source_key_id IN 
(select cbs_party_id from Party where party_id in
(select party_id from address)) and id='nom_Index')
select _sdc_source_key_id as CBS_party_id, Group_concat(Nom_Index) as Nom_Index FROM nom_clients 
where Nom_Index IS NOT NULL group by CBS_party_id;

UPDATE nom_clients a
INNER JOIN mig_clients m ON a.CBS_party_id = m.CBS_party_id
SET a.Party_Id=m.Party_Id;

UPDATE address a
INNER JOIN nom_clients c ON a.Party_Id = c.Party_Id
SET a.Nom_Index=c.Nom_Index;

UPDATE address a
INNER JOIN nom_clients c ON a.Party_Id = c.Party_Id
SET a.Nom_Index=c.Nom_Index;

/********* Consent Details *********/
IF @party_cnt = 0 THEN 
	CALL truncate_transaction("Consent_Details", "TRUNCATE TABLE Consent_Details");
ELSE
	UPDATE Consent_Details a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE Consent_Details a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("Consent_Details", "INSERT IGNORE INTO Consent_Details (Party_Id, Consent_Type, Consent_Capture_Source, Consent_Channel, Status, Comments, Consent_Details, Created_Date, Created_By, Is_Latest_rec)
SELECT /*+PARALLEL(8)*/ Distinct a.party_id as Party_Id,
       CASE WHEN c.id = 'marketing_Consent' THEN 'marketing_Consent' ELSE c.id END as Consent_Type,
       'APP' as Consent_Capture_Source,
       'APP' as Consent_Channel,
	   CASE WHEN c.value = 'Y' THEN 1 ELSE 0 END as Status,
	   NULL AS Comments,
	   NULL AS Consent_Details,
       CURRENT_TIMESTAMP as Created_Date,
       'MIG_Sample_Data' as Created_By,
	   'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id 
       WHERE c.id = 'marketing_Consent'");

/********* Contact *********/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("contact", "TRUNCATE TABLE contact");
ELSE
	UPDATE contact a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE contact a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("contact", "INSERT IGNORE INTO `contact` (`Party_Id`, `Contact_Type`, `Contact_Value`, `Contact_Period`, `Is_Preferred`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
Select /*+PARALLEL(8)*/ distinct party_id, 'Preferred Email' as Contact_Type, b.email_address as Contact_Value, NULL as Contact_Period, 0 as Is_Preferred, 1 as Is_Active, current_date as Created_Date, 'MIG_Sample_Data' as Created_By, 'Y' as Is_Latest_rec From party a1 INNER JOIN temp_clients b ON a1.cbs_party_id = b.id where b.email_address <> ''
UNION
select /*+PARALLEL(8)*/ distinct party_id, 'Mobile Phone Number' as Contact_Type, b.mobile_phone as Contact_Value, NULL as Contact_Period, 0 as Is_Preferred, 1 as Is_Active, current_date as Created_Date, 'MIG_Sample_Data' as Created_By, 'Y' as Is_Latest_rec From party a2 INNER JOIN temp_clients b ON a2.cbs_party_id = b.id where b.mobile_phone <> ''
UNION
select /*+PARALLEL(8)*/ distinct party_id, 'Alternate Mobile Number' as Contact_Type, b.home_phone as Contact_Value, NULL as Contact_Period, 0 as Is_Preferred, 1 as Is_Active, current_date as Created_Date, 'MIG_Sample_Data' as Created_By, 'Y' as Is_Latest_rec From party a3 INNER JOIN temp_clients b ON a3.cbs_party_id = b.id where b.home_phone <> ''");

/********* Party_Status *********/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("party_status", "TRUNCATE TABLE party_status");
ELSE
	UPDATE party_status a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE party_status a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("party_status", "INSERT IGNORE INTO `party_status` (`party_id`, `cbs_party_id`, `status_type`, `status_flag`, `created_date`, `created_by`, `Is_Latest_rec`)
WITH party_status_cte AS (SELECT /*+PARALLEL(8)*/ DISTINCT party_id as party_id,
                cbs_party_id as cbs_party_id,
				CASE WHEN c.field_set_id='_Status' THEN REPLACE(c.id, '_', '') END as status_type,
                CASE WHEN c.id='is_Bankrupt' THEN CASE WHEN c.value='TRUE' THEN 1 ELSE 0 END
				WHEN c.id='is_Deceased' THEN CASE WHEN c.value='TRUE' THEN 1 ELSE 0 END 
				WHEN c.id='is_Garnishment' THEN CASE WHEN c.value='TRUE' THEN 1 ELSE 0 END 
				WHEN c.id='is_Non_KYC' THEN CASE WHEN c.value='TRUE' THEN 1 ELSE 0 END
				WHEN c.id='is_AML_Block' THEN CASE WHEN c.value='TRUE' THEN 1 ELSE 0 END 
				WHEN c.id='is_Fraud_Block' THEN CASE WHEN c.value='TRUE' THEN 1 ELSE 0 END
				END as status_flag,
                CURRENT_TIMESTAMP as created_date,
                'MIG_Sample_Data' as created_by,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id)
SELECT * FROM party_status_cte WHERE status_type IS NOT NULL");

/********* Relationship (Nominee) *********/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("relationship", "TRUNCATE TABLE relationship");
ELSE
	UPDATE relationship a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE relationship a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

INSERT IGNORE INTO relationship (`Party_Id`, `Relationship_Type`, `Name`, `DOB`, `Nationality`, `Address`,
`Share_Percentage`, `Is_Nominee`, `Nominee_Index`, `Is_Active`, `created_date`, `created_by`, `Is_Latest_rec`)
with cte1 as (SELECT /*+PARALLEL(8)*/ party_id,
b.id AS cbs_party_id,
a.id,
_sdc_source_key_id,
_sdc_level_0_id,
value,
case when a.id='nom_City' then _sdc_level_0_id end as assigned_value
FROM temp_clients__custom_fields a
INNER JOIN temp_clients b ON a._sdc_source_key_id = b.id
INNER JOIN party c ON b.id = c.cbs_party_id
where field_set_id in('_Nom_Details')),
cte2 as (SELECT party_id,t1._sdc_source_key_id,id,_sdc_level_0_id,value,
(CASE WHEN assigned_value IS NULL
THEN @prevValue
ELSE @prevValue := assigned_value END) assigned_sdc_level_0_id
FROM cte1 t1
CROSS JOIN (SELECT @prevValue := NULL) t2
group by _sdc_source_key_id,id,_sdc_level_0_id
ORDER BY t1._sdc_source_key_id)
select party_id as Party_Id,
IFNULL(max(nom_Relationship), NULL) as Relationship_Type,
IFNULL(max(nom_Name), NULL) as Name,
IFNULL(max(nom_DOB), NULL) as DOB,
IFNULL(max(nom_Country), NULL) as Nationality,
concat('{', '"Street":', '"', IFNULL(max(nom_Street), NULL), '"', ', ', '"City":', '"', IFNULL(max(nom_City), NULL), '"', ', ', '"ZipCode":', '"', IFNULL(max(nom_ZipCode), NULL), '"', ', ', '"State":', '"', IFNULL(max(nom_State), NULL), '"', ', ', '"Country":', '"', IFNULL(max(nom_Country), NULL), '"', '}') AS Address,
Null as Share_Percentage,
'Y' as Is_Nominee,
max(nom_Index) as Nominee_Index,
1 as Is_Active,
CURRENT_TIMESTAMP as Created_Date,
'MIG_Sample_Data' as Created_By,
'Y' as Is_Latest_rec
from(
select _sdc_source_key_id,
party_id,
assigned_sdc_level_0_id,
Case when a.id='nom_City' then value End as nom_City,
Case when a.id='nom_Street' then value  End as nom_Street,
Case when a.id='_index' then value  End as _index,
Case when a.id='nom_Relationship' then value  End as nom_Relationship,
Case when a.id='nom_DOB' then value  End as nom_DOB,
Case when a.id='nom_Index' then value  End as nom_Index,
Case when a.id='nom_Name' then value  End as nom_Name,
Case when a.id='nom_State' then value  End as nom_State,
Case when a.id='nom_ZipCode' then value  End as nom_ZipCode,
Case when a.id='nom_Country' then value  End as nom_Country
from cte2 a 
group by _sdc_source_key_id, id, assigned_sdc_level_0_id
order by _sdc_source_key_id, assigned_sdc_level_0_id)a 
group by _sdc_source_key_id, assigned_sdc_level_0_id
order by _sdc_source_key_id, CAST(_index AS UNSIGNED);

/********* Relationship (Spouse) *********/

CALL insert_transaction("relationship (Spouse)", "INSERT IGNORE INTO relationship (`Party_Id`, `Relationship_Type`, `Name`, `DOB`, `Nationality`, `Address`,
`Share_Percentage`, `Is_Nominee`, `Nominee_Index`, `Is_Active`, `created_date`, `created_by`, `Is_Latest_rec`)
with cte1 as (SELECT /*+PARALLEL(8)*/ party_id, b.id AS cbs_party_id, a.id, _sdc_source_key_id, _sdc_level_0_id, value,
case when a.id='spouse_Nationality' then _sdc_level_0_id end as assigned_value
FROM temp_clients__custom_fields a
INNER JOIN temp_clients b ON a._sdc_source_key_id = b.id
INNER JOIN party c ON b.id = c.cbs_party_id
where field_set_id in('_Spouse_Details')),
cte2 as (SELECT party_id, t1._sdc_source_key_id, id, _sdc_level_0_id, value,
(CASE WHEN assigned_value IS NULL
THEN @prevValue
ELSE @prevValue := assigned_value END) assigned_sdc_level_0_id
FROM cte1 t1
CROSS JOIN (SELECT @prevValue := NULL) t2
group by _sdc_source_key_id,id,_sdc_level_0_id
ORDER BY t1._sdc_source_key_id)
select party_id as Party_Id,
'Spouse' as Relationship_Type,
IFNULL(max(spouse_Name), NULL) as Name,
IFNULL(max(spouse_DOB), NULL) as DOB,
IFNULL(max(spouse_Nationality), NULL) as Nationality,
NULL  AS Address,
NULL as Share_Percentage,
'Y' as Is_Nominee,
NULL as Nominee_Index,
1 as Is_Active,
CURRENT_TIMESTAMP as Created_Date,
'MIG_Sample_Data' as Created_By,
'Y' as Is_Latest_rec
from (select _sdc_source_key_id, party_id, assigned_sdc_level_0_id,
Case when a.id='spouse_Nationality' then value End as spouse_Nationality,
Case when a.id='spouse_Employment' then value  End as spouse_Employment,
Case when a.id='spouse_Name' then value  End as spouse_Name,
Case when a.id='spouse_DOB' then value  End as spouse_DOB,
Case when a.id='spouse_Place_Of_Birth' then value  End as spouse_Place_Of_Birth
from cte2 a 
group by _sdc_source_key_id,id,assigned_sdc_level_0_id
order by _sdc_source_key_id,assigned_sdc_level_0_id)a 
group by _sdc_source_key_id,assigned_sdc_level_0_id
order by _sdc_source_key_id");

/********* System_Integration_Status *********/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("system_integration_status", "TRUNCATE TABLE system_integration_status");
ELSE
	UPDATE system_integration_status a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE system_integration_status a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("system_integration_status", "INSERT IGNORE INTO `system_integration_status` (`party_id`, `system_name`, `enrollment_status`, `created_date`, `created_by`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT party_id AS Party_Id,
                c.id AS System_Name,
                c.value AS Enrollment_Status,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_Sys_Intg_Status'");

/********* Occupation *********/

DROP TEMPORARY TABLE IF EXISTS temp_occupation;

CREATE TEMPORARY TABLE temp_occupation  
SELECT /* +PARALLEL(32) USE_HASH(32) */ DISTINCT `party_id` AS Party_Id,
        CASE c.id WHEN 'emp_Work_Nature' THEN value ELSE NULL END AS nature_of_occupation,
		CASE c.id WHEN 'emp_Work_Nature_Code' THEN value ELSE NULL END AS nature_of_occupation_code, 
		CASE c.id WHEN 'emp_Employer_Name' THEN value ELSE NULL END AS 'Organization',
		CASE c.id WHEN 'emp_Indus_Type' THEN value ELSE NULL END AS industry_type, 
		CASE c.id WHEN 'emp_Indus_Type_Code' THEN value ELSE NULL END AS industry_type_code,
		CASE c.id WHEN 'emp_Type' THEN value ELSE NULL END AS occupation_type,
		CASE c.id WHEN 'emp_Type_Code' THEN value ELSE NULL END AS occupation_type_code, 
		CASE c.id WHEN 'emp_Status' THEN value ELSE NULL END AS occupation_status,
		CASE c.id WHEN 'emp_Status_Code' THEN value end AS occupation_status_code,
		IF(CASE c.id WHEN 'emp_Yrs_In_Cur_Comp' THEN IFNULL(c.value, NULL) END > CASE c.id WHEN 'emp_Mths_In_Cur_Comp' THEN IFNULL(c.value, NULL) END, CASE c.id WHEN 'emp_Yrs_In_Cur_Comp' THEN 
        DATE_SUB((str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d') - INTERVAL IFNULL(c.value, NULL) YEAR), 
        INTERVAL DAYOFMONTH(str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d'))-1 DAY) END, 
        CASE c.id WHEN 'emp_Mths_In_Cur_Comp' THEN 
        DATE_SUB((str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d') - INTERVAL IFNULL(c.value, NULL) MONTH), 
        INTERVAL DAYOFMONTH(str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d'))-1 DAY) END) AS date_of_commencement,
		CASE c.id WHEN 'fin_Mthly_Income' THEN value ELSE NULL END AS monthly_income,
		CASE c.id WHEN 'fin_Ann_Income' THEN value ELSE NULL END AS annual_income, 
		CASE c.id WHEN 'fin_Src_Of_Funds' THEN value ELSE NULL END AS fund_source_name,
		NULL AS fund_source_code,
		CASE c.id WHEN 'kyc_Src_Of_Wealth' THEN value ELSE NULL END AS source_of_wealth, 
		CASE c.id WHEN 'kyc_Proof_Of_SOW' THEN value ELSE NULL END AS proof_of_sow,
		CASE c.id WHEN 'kyc_Cust_Linked_Companies' THEN value ELSE NULL END AS party_linked_companies,
		CASE c.id WHEN 'kyc_Cust_Banks' THEN value end AS party_banks,
		CASE c.id WHEN 'kyc_Adrs_Proof' THEN value end AS proof_of_address,
        CASE c.id WHEN 'identity_Proof_Of_Income' THEN c.value ELSE NULL END As Proof_Of_Income,
		NULL AS Salary_Period,
        NULL AS Salary_Dates,
        CASE c.id WHEN 'identity_Proof_Of_Billing' THEN c.value ELSE NULL END As Proof_Of_Billing,
        NULL AS Profession,
        1 AS Is_Active,
        CURRENT_TIMESTAMP AS Created_Date,
        'MIG_Sample_Data' AS Created_By,
		'Y' as Is_Latest_rec
FROM mig_clients a
INNER JOIN temp_clients__custom_fields c
ON a.cbs_party_id = c._sdc_source_key_id
WHERE field_set_id IN ('_Emp_Details', '_Fin_Details', '_Identification_Details', '_KYC_High_Risk', '_Personal_Details') AND 
id IN ('emp_Work_Nature','emp_Work_Nature_Code','emp_Employer_Name','emp_Indus_Type','emp_Indus_Type_Code','emp_Type',
'emp_Type_Code','emp_Status','emp_Status_Code','emp_Yrs_In_Cur_Comp','fin_Mthly_Income','fin_Ann_Income','fin_Src_Of_Funds',
'kyc_Src_Of_Wealth','kyc_Proof_Of_SOW','kyc_Cust_Linked_Companies','kyc_Cust_Banks','kyc_Adrs_Proof','identity_Proof_Of_Income',
'identity_Proof_Of_Billing','emp_Yrs_In_Cur_Comp','emp_Mths_In_Cur_Comp');

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("occupation", "TRUNCATE TABLE occupation");
ELSE
	UPDATE occupation a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE occupation a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("occupation", "INSERT IGNORE INTO occupation (`Party_Id`, `Nature_Of_Occupation`, `Nature_Of_Occupation_Code`, `Organization`, `Industry_Type`, `Industry_Type_Code`, `Occupation_Type`, `Occupation_Type_Code`, `Occupation_Status`, `Occupation_Status_Code`, `Date_Of_Commencement`, `Monthly_Income`, `Annual_Income`, `Fund_Source_Name`, `Fund_Source_Code`, `Source_Of_Wealth`, `Proof_Of_SOW`, `Party_Linked_Companies`, `Party_Banks`, `Proof_Of_Address`, `Proof_Of_Income`, `Salary_Period`, `Salary_Dates`, `Proof_Of_Billing`, `Profession`, `Is_Active`, `Created_Date`, `Created_by`, `Is_Latest_rec`) 
SELECT /* +PARALLEL(32) USE_HASH (32) */ DISTINCT party_id,
                Max(nature_of_occupation) AS nature_of_occupation,
                Max(nature_of_occupation_code) AS nature_of_occupation_code,
                Max(organization) AS 'organization',
                Max(industry_type) AS industry_type,
                Max(industry_type_code) AS industry_type_code,
                Max(occupation_type) AS occupation_type,
                Max(occupation_type_code) AS occupation_type_code,
                Max(occupation_status) AS occupation_status,
                Max(occupation_status_code) AS occupation_status_code,
                Max(date_of_commencement) AS date_of_commencement,
                Max(monthly_income) AS monthly_income,
                Max(annual_income) AS annual_income,
                Max(fund_source_name) AS fund_source_name,
                Max(fund_source_code) AS fund_source_code,
                Max(source_of_wealth) AS source_of_wealth,
                Max(proof_of_sow) AS proof_of_sow,
                Max(party_linked_companies) AS party_linked_companies,
                Max(party_banks) AS party_banks,
                Max(proof_of_address) AS proof_of_address,
				Max(Proof_Of_Income) AS Proof_Of_Income,
				salary_period,
                salary_dates,
                Max(Proof_Of_Billing) AS Proof_Of_Billing,
                Profession,
                is_active,
                created_date,
                Created_By,
				Is_Latest_rec
FROM temp_occupation GROUP BY party_id");

-- UPDATE Occupation SET date_of_commencement = (YEAR(CURRENT_TIMESTAMP) - YEAR(Date_Of_Commencement));

/********* KYC_Details *********/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("kyc_details", "TRUNCATE TABLE kyc_details");
ELSE
	UPDATE kyc_details a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE kyc_details a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("kyc_details", "INSERT IGNORE INTO `kyc_details` (`Party_Id`, `Document_Id`, `Document_Type`, `Issuing_Authority`, `Valid_Until`, `National_Id`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with identity_NationalId_cte as (
	select /*+PARALLEL(8)*/ _sdc_source_key_id,value from clients__custom_fields
	where id='identity_NationalId' group by _sdc_source_key_id)
	select distinct m.party_id as Party_Id,
			d.document_id as document_id,
			d.document_type as document_type,
			d.issuing_authority as issuing_authority,
			d.valid_until as valid_until,
			ifnull(value,NULL) as National_Id,
			1 as Is_Active,
			CURRENT_TIMESTAMP AS Created_Date,
            'MIG_Sample_Data' AS Created_By,
			'Y' as Is_Latest_rec
		from temp_clients__id_documents d
	left join identity_NationalId_cte c on c._sdc_source_key_id=d._sdc_source_key_id
	inner join temp_clients b on b.id=d._sdc_source_key_id
	inner join mig_clients m on m.cbs_party_id = b.id");
			   		   
/****** Asset_Details ******/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("asset_details", "TRUNCATE TABLE asset_details");
ELSE
	UPDATE asset_details a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE asset_details a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("asset_details", "INSERT IGNORE INTO asset_details (`Party_Id`, `Asset_Number`, `Asset_Description`, `Product_Id`, `Purchase_Date`, `Status`, `Quantity`, `Price`, `Valid_Upto`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT `party_id` AS Party_Id,
				CASE c.id WHEN 'fin_Ownr_Home' THEN 1 ELSE NULL END AS Asset_Number,
				CASE c.id WHEN 'fin_Ownr_Home' THEN 'Home Ownership' ELSE NULL END AS Asset_Description,
				NULL AS Product_Id,
				NULL AS Purchase_Date,
				c.value AS Status,
				NULL AS Quantity,
				NULL AS Price,
				NULL AS Valid_Upto,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE c.id IN('fin_Ownr_Home')");
	   
CALL insert_transaction("asset_details", "INSERT IGNORE INTO asset_details (`Party_Id`, `Asset_Number`, `Asset_Description`, `Product_Id`, `Purchase_Date`, `Status`, `Quantity`, `Price`, `Valid_Upto`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT `party_id` AS Party_Id,
				CASE c.id WHEN 'fin_Ownr_Car' THEN 2 ELSE NULL END AS Asset_Number,
				CASE c.id WHEN 'fin_Ownr_Car' THEN 'Car Ownership' ELSE NULL END AS Asset_Description,
				NULL AS Product_Id,
				NULL AS Purchase_Date,
				c.value AS Status,
				NULL AS Quantity,
				NULL AS Price,
				NULL AS Valid_Upto,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE c.id IN('fin_Ownr_Car')");

/****** Device_Details ******/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("device_details", "TRUNCATE TABLE device_details");
ELSE
	UPDATE device_details a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE device_details a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c 
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

CALL insert_transaction("device_details", "INSERT IGNORE INTO device_details (`Party_Id`, `Device_IP`, `Latitude`, `Longitude`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT `party_id` AS Party_Id,
				CASE c.id WHEN 'deviceId' THEN value ELSE NULL END AS Device_IP,
				d.latitude AS Latitude,
				d.longitude AS Longitude,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
	   INNER JOIN temp_clients__addresses d
               ON b.id = d._sdc_source_key_id
       WHERE c.id IN('deviceId')");
	   
/****** External_System_Response (Zoloz) ******/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("external_system_response", "TRUNCATE TABLE external_system_response");
ELSE
	UPDATE external_system_response a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE external_system_response a SET Is_Latest_rec='N' WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

INSERT IGNORE INTO external_system_response (`Party_Id`, `External_System_Name`, `External_Response_Details`, `Overall_Status`, `Case_Id`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with zoloz_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT party_id AS Party_Id,
				'Zoloz' AS External_System_Name,
				CASE WHEN c.id != 'id_Network_Details' THEN concat('"', REPLACE(c.id, "_", ""),'":"',TRIM(c.value),'"') ELSE 
				CASE WHEN REGEXP_LIKE(TRIM(c.value), '^[a-z]') THEN concat('"', REPLACE(c.id, "_", ""),'":', '"', TRIM(c.value),'', '"') ELSE 
				concat('"', REPLACE(c.id, "_", ""),'":',TRIM(c.value),'') END END AS External_Response_Details,
                NULL AS Overall_Status,
				NULL AS Case_Id,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id IN ('_Zoloz_Basic_Info','_Zoloz_Details'))
SELECT Party_Id, External_System_Name, 
concat('{', group_concat(External_Response_Details), '}') AS External_Response_Details, 
Overall_Status, Case_Id, Created_Date, Created_By, Is_Latest_rec from zoloz_cte group by Party_Id;

/****** External_System_Response (AML) ******/

INSERT IGNORE INTO external_system_response (`Party_Id`, `External_System_Name`, `External_Response_Details`, `Overall_Status`, `Case_Id`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with AML_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT party_id AS Party_Id,
				'amlDetails' AS External_System_Name,
				concat('"', REPLACE(REPLACE(REPLACE(c.id, "_", ""), "amlScoringFlag", "amlStatusRiskScoringFlag"), "amlNameScreeningFlag", "amlStatusNameScreeningFlag"),'":"',TRIM(c.value),'"') AS External_Response_Details,
                NULL AS Overall_Status,
				NULL AS Case_Id,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_AML_Status')
SELECT Party_Id, External_System_Name, 
concat('{', group_concat(External_Response_Details), '}') AS External_Response_Details, 
Overall_Status, Case_Id, Created_Date, Created_By, Is_Latest_rec from AML_cte group by Party_Id; 

/****** External_System_Response (Idmission) ******/

INSERT IGNORE INTO external_system_response (`Party_Id`, `External_System_Name`, `External_Response_Details`, `Overall_Status`, `Case_Id`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with IdMission_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT party_id AS Party_Id,
				'IdMissionDetails' AS External_System_Name,
				concat('"', REPLACE(c.id, "_", ""),'":"',TRIM(c.value),'"') AS External_Response_Details,
                NULL AS Overall_Status,
				NULL AS Case_Id,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_Idmission')
SELECT Party_Id, External_System_Name, 
concat('{', group_concat(External_Response_Details), '}') AS External_Response_Details, 
Overall_Status, Case_Id, Created_Date, Created_By, Is_Latest_rec from IdMission_cte group by Party_Id;

/****** Referral_Promotion ******/

IF @party_cnt = 0 THEN 
	CALL truncate_transaction("referral_promotion", "TRUNCATE TABLE referral_promotion");
ELSE
	UPDATE referral_promotion a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='LD');
	
	UPDATE referral_promotion a SET Is_Latest_rec='N', Is_Active=0 WHERE EXISTS (SELECT 1 FROM temp_clients_count b INNER JOIN mig_clients c
	WHERE c.party_id = a.party_id and c.cbs_party_id = b.cbs_party_id and b.flag='NR');
END IF;

INSERT IGNORE INTO referral_promotion (`Party_Id`, `Referral_Code`, `Promo_Code`, `Company_Code`, `Agent_Code`, `Ref_Promo_Flag`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with Referral_Promotion_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT party_id AS Party_Id,
				Case when c.id='referral_Code' then value end AS Referral_Code,
				Case when c.id='promotional_Code' then value end AS Promo_Code,
                Case when c.id='source_Company' then value end AS Company_Code,
                Case when c.id='agent_Code' then value end AS Agent_Code,
                Case when c.id='referral_Promo_Code_Flag' then value end AS Ref_Promo_Flag,
                1 AS Is_Active,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' AS Is_Latest_rec
FROM mig_clients a
       INNER JOIN temp_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN temp_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_Referral_Promotion')
SELECT Party_Id, IFNULL(max(Referral_Code),NULL) AS Referral_Code, IFNULL(max(Promo_Code),NULL) AS Promo_Code, IFNULL(max(Company_Code),NULL) AS Company_Code, IFNULL(max(Agent_Code),NULL) AS Agent_Code, IFNULL(max(Ref_Promo_Flag),NULL) AS Ref_Promo_Flag, Is_Active, 
Created_Date, Created_By, Is_Latest_rec from Referral_Promotion_cte group by Party_Id;
			   
/*------------------------------------*/
/*----DROP Temporary_ODS_Structure----*/
/*------------------------------------*/

/*DROP TABLE IF EXISTS temp_clients;
DROP TABLE IF EXISTS count_temp_clients;
DROP TABLE IF EXISTS temp_clients__addresses;
DROP TABLE IF EXISTS temp_clients__custom_fields;
DROP TABLE IF EXISTS temp_clients__id_documents;*/

/*------------------------------------*/

SET SQL_SAFE_UPDATES=0;
SET @Max_Id := (SELECT MAX(Id) FROM Batch_Duration);

UPDATE Batch_Duration SET Batch_End = (SELECT CURRENT_TIMESTAMP AS Batch_End) WHERE Id = @Max_Id;

UPDATE Batch_Duration SET Batch_Duration =
(WITH difference_in_seconds AS (
  SELECT
    Id,
    Batch_Start,
    Batch_End,
    TIMESTAMPDIFF(SECOND, Batch_Start, Batch_End) AS seconds
  FROM Batch_Duration Where Id=@Max_Id
),
 
differences AS (
  SELECT
    Id,
    Batch_Start,
    Batch_End,
    seconds,
    MOD(seconds, 60) AS seconds_part,
    MOD(seconds, 3600) AS minutes_part,
    MOD(seconds, 3600 * 24) AS hours_part
  FROM difference_in_seconds
)
 
SELECT
  CONCAT(
    FLOOR(seconds / 3600 / 24), ' days ',
    FLOOR(hours_part / 3600), ' hours ',
    FLOOR(minutes_part / 60), ' minutes ',
    seconds_part, ' seconds'
  ) AS Batch_Duration
FROM differences) WHERE id = @Max_Id;

DROP TABLE IF EXISTS crm_mig_count;
CREATE TABLE crm_mig_count
SELECT /*+PARALLEL(32) USE_HASH (32)*/
CURRENT_TIMESTAMP AS Migration_Date,
(SELECT count(*) AS mig_cllients FROM mig_clients) AS mig_cllients,
(SELECT count(*) AS party FROM party) AS party,
(SELECT count(*) AS party_status FROM party_status) AS party_status,
(SELECT count(*) AS address FROM address) AS address,
(SELECT count(*) AS Consent_Details FROM Consent_Details) AS Consent_Details,
(SELECT count(*) AS contact FROM contact) AS contact,
(SELECT count(*) AS relationship FROM relationship) AS relationship,
(SELECT count(*) AS system_integration_status FROM system_integration_status) AS system_integration_status,
(SELECT count(*) AS occupation FROM occupation) AS occupation,
(SELECT count(*) AS kyc_details FROM kyc_details) AS kyc_details,
(SELECT count(*) AS asset_details FROM asset_details) AS asset_details,
(SELECT count(*) AS device_details FROM device_details) AS device_details,
(SELECT count(*) AS external_system_response FROM external_system_response) AS external_system_response,
(SELECT count(*) AS referral_promotion FROM referral_promotion) AS referral_promotion;

END $$
DELIMITER ;