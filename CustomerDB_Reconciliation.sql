DELIMITER $$
DROP PROCEDURE IF EXISTS SP_Reconciliation $$
CREATE PROCEDURE `SP_Reconciliation`(IN FromDate date, IN ToDate date)
BEGIN

DECLARE FDate date;
DECLARE TDate date;
DECLARE NDays int;
SET FDate = str_to_date(LEFT(FromDate, 10), '%Y-%m-%d');
SET TDate = str_to_date(LEFT(ToDate, 10), '%Y-%m-%d');
SET NDays = DATEDIFF(ToDate, FromDate);

CREATE TABLE IF NOT EXISTS Batch_Duration (
`Id` bigint NOT NULL AUTO_INCREMENT,
`Batch_Name` VARCHAR(50) DEFAULT NULL,
`Batch_Start` DATETIME DEFAULT NULL,
`Batch_End` DATETIME DEFAULT NULL,
`Batch_Duration` VARCHAR(100) DEFAULT NULL,
PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO Batch_Duration (`Batch_Name`, `Batch_Start`)
SELECT 'Reconciliation of Data' AS Batch_Name, CURRENT_TIMESTAMP AS Batch_Start;

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
SET SQL_SAFE_UPDATES=0;

DROP TABLE IF EXISTS temp_count_clients;
create table temp_count_clients
select distinct /*+PARALLEL(32)*/ id as cbs_party_id from temp_clients
where ((str_to_date(left(creation_date,10), '%Y-%m-%d') >= 
DATE_SUB(str_to_date(left(current_date,10), '%Y-%m-%d'),INTERVAL NDays DAY)));

insert ignore into temp_count_clients
select distinct /*+PARALLEL(32)*/ id as cbs_party_id from temp_clients
where id NOT IN (select cbs_party_id from temp_count_clients)
and (( str_to_date(left(last_modified_date,10), '%Y-%m-%d') >= 
DATE_SUB(str_to_date(left(current_date,10), '%Y-%m-%d'),INTERVAL NDays DAY)));

/** Deletion of Old Records which is not need for reconsliation**/

/*Delete from temp_clients where id 
not in(select cbs_party_id from temp_count_clients);

Delete from temp_clients__addresses where _sdc_source_key_id 
Not in(select cbs_party_id from temp_count_clients);

Delete from temp_clients__custom_fields where _sdc_source_key_id 
Not in(select cbs_party_id from temp_count_clients);
 
Delete from temp_clients__id_documents where _sdc_source_key_id
Not in(select cbs_party_id from temp_count_clients);*/


/*----------------------------*/
/*----ODS Schema_Structure----*/
/*----------------------------*/

/*----Clients----*/

CREATE TABLE IF NOT EXISTS `ODS_clients` (
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

CREATE TABLE IF NOT EXISTS `ODS_clients__addresses` (
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

CREATE TABLE IF NOT EXISTS `ODS_clients__custom_fields` (
  `field_set_id` varchar(100) DEFAULT NULL,
  `id` varchar(100) DEFAULT NULL,
  `value` varchar(12000) DEFAULT NULL,
  `_sdc_source_key_id` BIGINT DEFAULT NULL,
  `_sdc_sequence` varchar(50) DEFAULT NULL,
  `_sdc_level_0_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*----Clients_ID_Documents----*/

CREATE TABLE IF NOT EXISTS `ODS_clients__id_documents` (
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

/*------------------------*/
/*----Replica from ODS----*/
/*------------------------*/
/*----Clients_Addresses----*/


CALL insert_transaction("ODS_clients__addresses", "INSERT IGNORE INTO ODS_clients__addresses (country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
SELECT /*+PARALLEL(32)*/ country, parent_key, city, latitude, postcode, index_in_list, encoded_key, region, line2, line1, longitude, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
FROM temp_clients__addresses WHERE _sdc_source_key_id in (select cbs_party_id from temp_count_clients)");

/*----Clients_Custom_Fields----*/

CALL insert_transaction("ODS_clients__custom_fields", "INSERT IGNORE INTO ODS_clients__custom_fields (field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
SELECT /*+PARALLEL(32)*/ field_set_id, id, value, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
FROM temp_clients__custom_fields WHERE _sdc_source_key_id in (select cbs_party_id from temp_count_clients)");

/*----Clients_ID_Documents----*/

CALL insert_transaction("ODS_clients__id_documents", "INSERT IGNORE INTO ODS_clients__id_documents (identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id)
SELECT /*+PARALLEL(32)*/ identification_document_template_key, issuing_authority, client_key, document_type, index_in_list, valid_until, encoded_key, document_id, _sdc_source_key_id, _sdc_sequence, _sdc_level_0_id
FROM temp_clients__id_documents WHERE _sdc_source_key_id in (select cbs_party_id from temp_count_clients)");

/*----Clients----*/

CALL insert_transaction("ODS_clients", "INSERT IGNORE INTO ODS_clients (last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at)
SELECT /*+PARALLEL(32)*/ last_name, migration_event_key, preferred_language, notes, gender, group_loan_cycle, email_address, encoded_key, id, state, assigned_user_key, client_role_key, last_modified_date, home_phone, creation_date, birth_date, assigned_centre_key, approved_date, first_name, profile_picture_key, profile_signature_key, mobile_phone, closed_date, middle_name, activation_date, _sdc_received_at, _sdc_sequence, _sdc_table_version, _sdc_batched_at FROM temp_clients WHERE id in (select cbs_party_id from temp_count_clients)");

/*----Count_Clients (Temporary Table)----

DROP TABLE IF EXISTS temp_count_clients;

CREATE TABLE IF NOT EXISTS `temp_count_clients` (
  `Id` int NOT NULL AUTO_INCREMENT,
  `CBS_party_id` bigint NOT NULL,
  `Creation_Date` date DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO temp_count_clients(CBS_party_id, Creation_Date)
SELECT  id as CBS_party_id, str_to_date(left(creation_date,10), '%Y-%m-%d') AS Creation_Date 
FROM clients ORDER BY str_to_date(left(creation_date,10), '%Y-%m-%d');
*/
/*----------------------------------*/
/*----Migration Schema Structure----*/
/*----------------------------------*/

/****** mig_clients ******/

CREATE TABLE IF NOT EXISTS `ODS_mig_clients` (
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

CREATE TABLE IF NOT EXISTS `ODS_party` (
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

CREATE TABLE IF NOT EXISTS `ODS_address` (
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

CREATE TABLE IF NOT EXISTS `ODS_consent_details` (
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

CREATE TABLE IF NOT EXISTS `ODS_contact` (
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

CREATE TABLE IF NOT EXISTS `ODS_party_status` (
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

CREATE TABLE IF NOT EXISTS `ODS_relationship` (
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

CREATE TABLE IF NOT EXISTS `ODS_system_integration_status` (
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

CREATE TABLE IF NOT EXISTS `ODS_occupation` (
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

CREATE TABLE IF NOT EXISTS `ODS_kyc_details` (
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

CREATE TABLE  IF NOT EXISTS `ODS_asset_details` (
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

CREATE TABLE IF NOT EXISTS `ODS_device_details` (
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

CREATE TABLE IF NOT EXISTS `ODS_external_system_response` (
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

CREATE TABLE IF NOT EXISTS `ODS_referral_promotion` (
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

/*----------------------*/
/*----Data Migration----*/
/*----------------------*/

/********* Matching Record is Inserted *********/

SET @@SESSION.sql_mode='ALLOW_INVALID_DATES';

DROP TEMPORARY TABLE IF EXISTS tclients;
CREATE TEMPORARY TABLE tclients
SELECT /*+PARALLEL(32) USE_HASH(4)*/ a.id AS Party_Id,
	a.id AS CBS_party_id,
	CASE WHEN a.first_name != '' THEN a.first_name ELSE NULL END AS First_Name,
	CASE WHEN a.last_name != '' THEN a.last_name ELSE NULL END AS Last_Name,
	CASE WHEN a.middle_name != '' THEN a.middle_name ELSE NULL END AS Middle_Name,
	CASE WHEN a.birth_date != '' THEN a.birth_date ELSE NULL END AS DOB,
	CASE WHEN a.gender != '' THEN CONCAT(UPPER(SUBSTRING(a.gender,1,1)),LOWER(SUBSTRING(a.gender,2))) ELSE NULL END AS Gender,
	CONCAT(UPPER(SUBSTRING(a.state,1,1)),LOWER(SUBSTRING(a.state,2))) AS Party_Status,
	CASE WHEN a.state = "active" THEN 1 ELSE 0 END AS Is_Active,
	a.creation_date AS Created_Date,
	'MIG_Sample_Data' AS Created_By,
	CONVERT(a.approved_date, DATETIME) AS Approved_Date,
	CONVERT(a.activation_date, DATETIME) AS Activation_Date
	FROM ods_clients a;

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
	from ods_clients__custom_fields b
	WHERE b.field_set_id in('_Emp_Details','_Personal_Details','_Identification_Details')
	AND b.id IN('salutation', 'civil_Status', 'place_Of_Birth', 'nationality', 'no_Of_Dependents', 'arn_No', 'idm_Arn_No', 'fatca_W9_IdType', 'fatca_W9_IdNumber','fatca_Cert_US_Non_US','emp_Type','identity_SssGsisId','identity_TinId','my_Job','card_Issuance_Status','suffix');

INSERT IGNORE INTO ODS_mig_clients (`party_id`, `cbs_party_id`, `first_name`, `last_name`, `middle_name`, `dob`, `gender`, `salutation`,
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
	Max(Card_Issuance_Status) AS Card_Issuance_Status,
	Max(is_active)AS is_active,
	a.Created_Date AS created_date,
	'MIG_Sample_Data' AS created_by,
	Max(Approved_Date) AS approved_date,
	Max(Activation_Date) AS activation_date
	FROM tclients a LEFT JOIN tclients__custom_fields b on a.cbs_party_id=b.cbs_party_id GROUP BY cbs_party_id;

/********* Party *********/

CALL insert_transaction("ODS_party", "INSERT IGNORE INTO ODS_party (party_id, cbs_party_id, first_name, last_name, middle_name, dob, gender, salutation, suffix, civil_status, place_of_birth, nationality, no_of_dependents, arn_no, idm_arn_no, party_status, is_dosri, is_rpt, is_fatca, party_type, preferred_address_id, fatca_W9_IdType, fatca_W9_IdNumber, app_channel_type, app_product_type, app_party_type, channel_type, product_type, sssgsis, tinid, is_record_edited, party_matrix_header_id, My_Job, Card_Issuance_Status, is_active, created_date, created_by, approved_date, activation_date, Is_Latest_rec) 
SELECT /*+ PARALLEL(mig_clients 4) USE_HASH(mig_clients) ORDERED */ DISTINCT party_id, cbs_party_id, first_name, last_name, middle_name, dob, gender, salutation Salutation, suffix, civil_status, place_of_birth, nationality, no_of_dependents, arn_no, idm_arn_no, party_status, is_dosri, is_rpt, is_fatca, party_type, preferred_address_id, fatca_W9_IdType, fatca_W9_IdNumber, app_channel_type, app_product_type, app_party_type, channel_type, product_type, sssgsis, tinid, is_record_edited, party_matrix_header_id, My_Job, Card_Issuance_Status, is_active, created_date, created_by, approved_date, activation_date, 'Y' AS Is_Latest_rec FROM ods_mig_clients ORDER BY cbs_party_id");

/********* Address *********/

-- CALL truncate_transaction("address", "TRUNCATE TABLE address");

CALL insert_transaction("ODS_address", "INSERT IGNORE INTO ODS_address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with Correspondence_cte as (select /*+ PARALLEL(mig_clients 4) PARALLEL(clients 4) USE_HASH(clients__addresses) ORDERED */ 
distinct a.cbs_party_id As Party_Id, 
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
from ods_mig_clients a INNER JOIN
ods_clients b INNER JOIN
ods_clients__addresses c 
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' 
THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from Correspondence_cte where Address_Type <> '' group by Party_Id");

CALL insert_transaction("ODS_address", "INSERT IGNORE INTO ODS_address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with clients__addresses as (select /*+PARALLEL(8)*/ distinct a.cbs_party_id As Party_Id, 
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
from ods_mig_clients a INNER JOIN
ods_clients b INNER JOIN
ods_clients__addresses c INNER JOIN
ods_clients__custom_fields d
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id
AND d.field_set_id ='_Perm_Address'
AND b.id = d._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from clients__addresses where Address_Type <> '' group by Party_Id");

CALL insert_transaction("ODS_address", "INSERT IGNORE INTO ODS_address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with clients__addresses as (select /*+PARALLEL(8)*/ distinct a.cbs_party_id As Party_Id, 
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
from ods_mig_clients a INNER JOIN
ods_clients b INNER JOIN
ods_clients__addresses c INNER JOIN
ods_clients__custom_fields d
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id
AND d.field_set_id ='_Biz_Address'
AND b.id = d._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from clients__addresses where Address_Type <> '' group by Party_Id");

CALL insert_transaction("ODS_address", "INSERT IGNORE INTO ODS_address (`Party_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `LandMark`, `Comments`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Nom_Index`, `Date_Since_Residing`, `Is_Preferred_Address`, `Province`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with clients__addresses as (select /*+PARALLEL(8)*/ distinct a.cbs_party_id As Party_Id, 
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
from ods_mig_clients a INNER JOIN
ods_clients b INNER JOIN
ods_clients__addresses c INNER JOIN
ods_clients__custom_fields d
ON a.cbs_party_id = b.id
AND b.id = c._sdc_source_key_id
AND d.field_set_id ='_Emp_Address'
AND b.id = d._sdc_source_key_id)
select distinct Party_Id, Max(Address_Type) as Address_Type, CASE WHEN Max(Number_And_Street) != '' THEN Max(Number_And_Street) ELSE NULL END as Number_And_Street, Barangay, LandMark, Comments, CASE WHEN Max(City) != '' THEN Max(City) ELSE NULL END as City, CASE WHEN Max(State) != '' THEN Max(State) ELSE NULL END as State, Region, CASE WHEN Max(Country) != '' THEN Max(Country) ELSE NULL END as Country, CASE WHEN Max(Country_Code) != '' THEN Max(Country_Code) ELSE NULL END as Country_Code, CASE WHEN Max(Zip_Code) != '' THEN Max(Zip_Code) ELSE NULL END as Zip_Code, Nom_Index, Date_Since_Residing, Is_Preferred_Address, Province, Is_Active, created_date, Created_By, Is_Latest_rec from clients__addresses where Address_Type <> '' group by Party_Id");

/********* Address (nom_Index) *********/

DROP TEMPORARY TABLE IF EXISTS ODS_nom_clients;
CREATE TEMPORARY TABLE `ODS_nom_clients` (
    Id bigint NOT NULL AUTO_INCREMENT,
    Party_Id bigint(10) unsigned zerofill,
	CBS_party_id bigint,
    Nom_Index varchar(30),
PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT IGNORE INTO ODS_nom_clients (`CBS_party_id`, `Nom_Index`)
with nom_clients as (SELECT DISTINCT _sdc_source_key_id, case when value IN (0,1,2,3) then value end as Nom_Index 
FROM ods_clients__custom_fields where _sdc_source_key_id IN 
(select cbs_party_id from ods_Party where party_id in
(select party_id from ods_address)) and id='nom_Index')
select _sdc_source_key_id as CBS_party_id, Group_concat(Nom_Index) as Nom_Index FROM nom_clients 
where Nom_Index IS NOT NULL group by CBS_party_id;

UPDATE ODS_nom_clients a
INNER JOIN ods_mig_clients m ON a.CBS_party_id = m.CBS_party_id
SET a.Party_Id=m.Party_Id;

UPDATE ODS_address a
INNER JOIN ODS_nom_clients c ON a.Party_Id = c.Party_Id
SET a.Nom_Index=c.Nom_Index;

UPDATE ODS_address a
INNER JOIN ODS_nom_clients c ON a.Party_Id = c.Party_Id
SET a.Nom_Index=c.Nom_Index;

/********* Consent Details *********/

CALL truncate_transaction("Consent_Details", "TRUNCATE TABLE ODS_Consent_Details");

CALL insert_transaction("ODS_Consent_Details", "INSERT IGNORE INTO ODS_Consent_Details (Party_Id, Consent_Type, Consent_Capture_Source, Consent_Channel, Status, Comments, Consent_Details, Created_Date, Created_By, Is_Latest_rec)
SELECT /*+PARALLEL(8)*/ Distinct a.cbs_party_id as Party_Id,
       CASE WHEN c.id = 'marketing_Consent' THEN 'marketing_Consent' ELSE c.id END as Consent_Type,
       'APP' as Consent_Capture_Source,
       'APP' as Consent_Channel,
	   CASE WHEN c.value = 'Y' THEN 1 ELSE 0 END as Status,
	   NULL AS Comments,
	   NULL AS Consent_Details,
       CURRENT_TIMESTAMP as Created_Date,
       'MIG_Sample_Data' as Created_By,
	   'Y' as Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id 
       WHERE c.id = 'marketing_Consent'");

/********* Contact *********/

-- CALL truncate_transaction("contact", "TRUNCATE TABLE contact");
	   
DROP TABLE IF EXISTS contact_email_temp;
DROP TABLE IF EXISTS contact_mobile_phone_temp;
DROP TABLE IF EXISTS contact_alternate_phone_temp;   
	   
Create table contact_email_temp
Select distinct /*+PARALLEL(8)*/ cbs_party_id as party_id, 'Preferred Email' as Contact_Type, b.email_address as
 Contact_Value, NULL as Contact_Period, 0 as Is_Preferred, 1 as Is_Active, current_date as Created_Date,
 'MIG_Sample_Data' as Created_By, 'Y' as Is_Latest_rec From ods_party a1 
 INNER JOIN ods_clients b ON a1.cbs_party_id = b.id where b.email_address <> '';
 
Create table contact_mobile_phone_temp 
select distinct /*+PARALLEL(8)*/ cbs_party_id as party_id, 'Mobile Phone Number'
 as Contact_Type, d.mobile_phone as Contact_Value, NULL as Contact_Period, 
 0 as Is_Preferred, 1 as Is_Active, current_date as Created_Date, 'MIG_Sample_Data' 
 as Created_By, 'Y' as Is_Latest_rec From ods_party c INNER JOIN ods_clients d 
 ON c.cbs_party_id = d.id where d.mobile_phone <> '';
 
Create table contact_alternate_phone_temp 
select distinct /*+PARALLEL(8)*/ cbs_party_id as party_id, 'Alternate Mobile Number' as Contact_Type,
 b.home_phone as Contact_Value, NULL as Contact_Period, 0 as Is_Preferred, 
 1 as Is_Active, current_date as Created_Date, 'MIG_Sample_Data' as Created_By, 'Y' as Is_Latest_rec
 From ods_party a3 INNER JOIN ods_clients b ON a3.cbs_party_id = b.id where b.home_phone <> '';
 	   
CALL insert_transaction("ODS_contact", "INSERT IGNORE INTO `ODS_contact` (`Party_Id`, `Contact_Type`, `Contact_Value`, `Contact_Period`, `Is_Preferred`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT party_id, contact_type, contact_value, contact_period, is_preferred, is_active, created_date, created_by, is_latest_rec FROM   contact_email_temp
UNION
SELECT party_id, contact_type, contact_value, contact_period, is_preferred, is_active, created_date, created_by, is_latest_rec FROM   contact_mobile_phone_temp 
UNION 
SELECT party_id, contact_type, contact_value, contact_period, is_preferred, is_active, created_date, created_by, is_latest_rec FROM   contact_alternate_phone_temp");

/********* Party_Status *********/

CALL insert_transaction("ODS_party_status", "INSERT IGNORE INTO `ODS_party_status` (`party_id`, `cbs_party_id`, `status_type`, `status_flag`, `created_date`, `created_by`, `Is_Latest_rec`)
WITH party_status_cte AS (SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id as party_id,
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
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id and field_set_id = '_Status')
SELECT * FROM party_status_cte WHERE status_type IS NOT NULL");

/********* Relationship (Nominee) *********/

INSERT IGNORE INTO ODS_relationship (`Party_Id`, `Relationship_Type`, `Name`, `DOB`, `Nationality`, `Address`,
`Share_Percentage`, `Is_Nominee`, `Nominee_Index`, `Is_Active`, `created_date`, `created_by`, `Is_Latest_rec`)
with cte1 as (SELECT /*+PARALLEL(8)*/ c.cbs_party_id as party_id,
b.id AS cbs_party_id,
a.id,
_sdc_source_key_id,
_sdc_level_0_id,
value,
case when a.id='nom_City' then _sdc_level_0_id end as assigned_value
FROM ods_clients__custom_fields a
INNER JOIN ods_clients b ON a._sdc_source_key_id = b.id
INNER JOIN ods_party c ON b.id = c.cbs_party_id
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
'MIG_DEV' as Created_By,
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

CALL insert_transaction("ODS_relationship (Spouse)", "INSERT IGNORE INTO ODS_relationship (`Party_Id`, `Relationship_Type`, `Name`, `DOB`, `Nationality`, `Address`,
`Share_Percentage`, `Is_Nominee`, `Nominee_Index`, `Is_Active`, `created_date`, `created_by`, `Is_Latest_rec`)
with cte1 as (SELECT /*+PARALLEL(8)*/ b.id AS party_id, b.id AS cbs_party_id, a.id, _sdc_source_key_id, _sdc_level_0_id, value,
case when a.id='spouse_Nationality' then _sdc_level_0_id end as assigned_value
FROM ods_clients__custom_fields a
INNER JOIN ods_clients b ON a._sdc_source_key_id = b.id
INNER JOIN ods_party c ON b.id = c.cbs_party_id
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
'MIG_DEV' as Created_By,
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

-- CALL truncate_transaction("system_integration_status", "TRUNCATE TABLE system_integration_status");

CALL insert_transaction("ODS_system_integration_status", "INSERT IGNORE INTO `ODS_system_integration_status` (`party_id`, `system_name`, `enrollment_status`, `created_date`, `created_by`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
                c.id AS System_Name,
                c.value AS Enrollment_Status,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_Sys_Intg_Status'");

/********* Occupation *********/

DROP TEMPORARY TABLE IF EXISTS temp_occupation; 

CREATE TEMPORARY TABLE temp_occupation  
SELECT DISTINCT cbs_party_id AS Party_Id,
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
FROM ods_mig_clients a
INNER JOIN ods_clients__custom_fields c
ON a.cbs_party_id = c._sdc_source_key_id
WHERE field_set_id IN ('_Emp_Details', '_Fin_Details', '_Identification_Details', '_KYC_High_Risk', '_Personal_Details') AND 
id IN ('emp_Work_Nature','emp_Work_Nature_Code','emp_Employer_Name','emp_Indus_Type','emp_Indus_Type_Code','emp_Type',
'emp_Type_Code','emp_Status','emp_Status_Code','emp_Yrs_In_Cur_Comp','fin_Mthly_Income','fin_Ann_Income','fin_Src_Of_Funds',
'kyc_Src_Of_Wealth','kyc_Proof_Of_SOW','kyc_Cust_Linked_Companies','kyc_Cust_Banks','kyc_Adrs_Proof','identity_Proof_Of_Income','identity_Proof_Of_Billing','emp_Yrs_In_Cur_Comp','emp_Mths_In_Cur_Comp'); 

CALL insert_transaction("ODS_occupation", "INSERT IGNORE INTO ODS_occupation (`Party_Id`, `Nature_Of_Occupation`, `Nature_Of_Occupation_Code`, `Organization`, `Industry_Type`, `Industry_Type_Code`, `Occupation_Type`, `Occupation_Type_Code`, `Occupation_Status`, `Occupation_Status_Code`, `Date_Of_Commencement`, `Monthly_Income`, `Annual_Income`, `Fund_Source_Name`, `Fund_Source_Code`, `Source_Of_Wealth`, `Proof_Of_SOW`, `Party_Linked_Companies`, `Party_Banks`, `Proof_Of_Address`, `Proof_Of_Income`, `Salary_Period`, `Salary_Dates`, `Proof_Of_Billing`, `Profession`, `Is_Active`, `Created_Date`, `Created_by`, `Is_Latest_rec`) 
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

-- UPDATE ODS_occupation SET date_of_commencement = (YEAR(CURRENT_TIMESTAMP) - YEAR(Date_Of_Commencement));

/********* KYC_Details *********/

-- CALL truncate_transaction("kyc_details", "TRUNCATE TABLE kyc_details");

CALL insert_transaction("ODS_kyc_details", "INSERT IGNORE INTO `ODS_kyc_details` (`Party_Id`, `Document_Id`, `Document_Type`, `Issuing_Authority`, `Valid_Until`, `National_Id`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with identity_NationalId_cte as (
	select /*+PARALLEL(8)*/ _sdc_source_key_id,value from ods_clients__custom_fields
	where id='identity_NationalId' group by _sdc_source_key_id)
	select distinct m.party_id as Party_Id,
			d.document_id as document_id,
			d.document_type as document_type,
			d.issuing_authority as issuing_authority,
			d.valid_until as valid_until,
			ifnull(value,NULL) as National_Id,
			1 as Is_Active,
			CURRENT_TIMESTAMP AS Created_Date,
            'MIG_DEV' AS Created_By,
			'Y' as Is_Latest_rec
		from ods_clients__id_documents d
	left join identity_NationalId_cte c on c._sdc_source_key_id=d._sdc_source_key_id
	inner join ods_clients b on b.id=d._sdc_source_key_id
	inner join ODS_mig_clients m on m.cbs_party_id = b.id");
			   		   
/****** Asset_Details ******/

-- CALL truncate_transaction("asset_details", "TRUNCATE TABLE asset_details");

CALL insert_transaction("ODS_asset_details", "INSERT IGNORE INTO ODS_asset_details (`Party_Id`, `Asset_Number`, `Asset_Description`, `Product_Id`, `Purchase_Date`, `Status`, `Quantity`, `Price`, `Valid_Upto`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
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
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE c.id IN('fin_Ownr_Home')");
	   
CALL insert_transaction("ODS_asset_details", "INSERT IGNORE INTO ODS_asset_details (`Party_Id`, `Asset_Number`, `Asset_Description`, `Product_Id`, `Purchase_Date`, `Status`, `Quantity`, `Price`, `Valid_Upto`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
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
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE c.id IN('fin_Ownr_Car')");

/****** Device_Details ******/

-- CALL truncate_transaction("device_details", "TRUNCATE TABLE device_details");

CALL insert_transaction("ODS_device_details", "INSERT IGNORE INTO ODS_device_details (`Party_Id`, `Device_IP`, `Latitude`, `Longitude`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
				CASE c.id WHEN 'deviceId' THEN value ELSE NULL END AS Device_IP,
				d.latitude AS Latitude,
				d.longitude AS Longitude,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
	   INNER JOIN ods_clients__addresses d
               ON b.id = d._sdc_source_key_id
       WHERE c.id IN('deviceId')");
	   
/****** External_System_Response (Zoloz) ******/

-- CALL truncate_transaction("external_system_response", "TRUNCATE TABLE external_system_response");

INSERT IGNORE INTO ODS_external_system_response (`Party_Id`, `External_System_Name`, `External_Response_Details`, `Overall_Status`, `Case_Id`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with zoloz_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
				'Zoloz' AS External_System_Name,
				CASE WHEN c.id != 'id_Network_Details' THEN concat('"', REPLACE(c.id, "_", ""),'":"',TRIM(c.value),'"') ELSE 
				CASE WHEN REGEXP_LIKE(TRIM(c.value), '^[a-z]') THEN concat('"', REPLACE(c.id, "_", ""),'":', '"', TRIM(c.value),'', '"') ELSE 
				concat('"', REPLACE(c.id, "_", ""),'":',TRIM(c.value),'') END END AS External_Response_Details,
                NULL AS Overall_Status,
				NULL AS Case_Id,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id IN ('_Zoloz_Basic_Info','_Zoloz_Details'))
SELECT Party_Id, External_System_Name, 
concat('{', group_concat(External_Response_Details), '}') AS External_Response_Details, 
Overall_Status, Case_Id, Created_Date, Created_By, Is_Latest_rec from zoloz_cte group by Party_Id;

/****** External_System_Response (AML) ******/

INSERT IGNORE INTO ODS_external_system_response (`Party_Id`, `External_System_Name`, `External_Response_Details`, `Overall_Status`, `Case_Id`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with AML_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
				'amlDetails' AS External_System_Name,
				concat('"', REPLACE(REPLACE(REPLACE(c.id, "_", ""), "amlScoringFlag", "amlStatusRiskScoringFlag"), "amlNameScreeningFlag", "amlStatusNameScreeningFlag"),'":"',TRIM(c.value),'"') AS External_Response_Details,
                NULL AS Overall_Status,
				NULL AS Case_Id,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_AML_Status')
SELECT Party_Id, External_System_Name, 
concat('{', group_concat(External_Response_Details), '}') AS External_Response_Details, 
Overall_Status, Case_Id, Created_Date, Created_By, Is_Latest_rec from AML_cte group by Party_Id; 

/****** External_System_Response (Idmission) ******/

INSERT IGNORE INTO ODS_external_system_response (`Party_Id`, `External_System_Name`, `External_Response_Details`, `Overall_Status`, `Case_Id`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with IdMission_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
				'IdMissionDetails' AS External_System_Name,
				concat('"', REPLACE(c.id, "_", ""),'":"',TRIM(c.value),'"') AS External_Response_Details,
                NULL AS Overall_Status,
				NULL AS Case_Id,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' as Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_Idmission')
SELECT Party_Id, External_System_Name, 
concat('{', group_concat(External_Response_Details), '}') AS External_Response_Details, 
Overall_Status, Case_Id, Created_Date, Created_By, Is_Latest_rec from IdMission_cte group by Party_Id;

/****** Referral_Promotion ******/

INSERT IGNORE INTO ODS_referral_promotion (`Party_Id`, `Referral_Code`, `Promo_Code`, `Company_Code`, `Agent_Code`, `Ref_Promo_Flag`, `Is_Active`, `Created_Date`, `Created_By`, `Is_Latest_rec`)
with Referral_Promotion_cte as (SELECT /*+PARALLEL(8)*/ DISTINCT cbs_party_id AS Party_Id,
				Case when c.id='referral_Code' then value end AS Referral_Code,
				Case when c.id='promotional_Code' then value end AS Promo_Code,
                Case when c.id='source_Company' then value end AS Company_Code,
                Case when c.id='agent_Code' then value end AS Agent_Code,
                Case when c.id='referral_Promo_Code_Flag' then value end AS Ref_Promo_Flag,
                1 AS Is_Active,
                CURRENT_TIMESTAMP AS Created_Date,
                'MIG_Sample_Data' AS Created_By,
				'Y' AS Is_Latest_rec
FROM ods_mig_clients a
       INNER JOIN ods_clients b
               ON a.cbs_party_id = b.id
       INNER JOIN ods_clients__custom_fields c
               ON b.id = c._sdc_source_key_id
       WHERE field_set_id = '_Referral_Promotion')
SELECT Party_Id, IFNULL(max(Referral_Code),NULL) AS Referral_Code, IFNULL(max(Promo_Code),NULL) AS Promo_Code, IFNULL(max(Company_Code),NULL) AS Company_Code, IFNULL(max(Agent_Code),NULL) AS Agent_Code, IFNULL(max(Ref_Promo_Flag),NULL) AS Ref_Promo_Flag, Is_Active, 
Created_Date, Created_By, Is_Latest_rec from Referral_Promotion_cte group by Party_Id;
			   
/*------------------------------------*/
/*----DROP Temporary_ODS_Structure----*/
/*------------------------------------*/
/*
DROP TABLE IF EXISTS temp_clients;
DROP TABLE IF EXISTS count_temp_clients;
DROP TABLE IF EXISTS temp_clients__addresses;
DROP TABLE IF EXISTS temp_clients__custom_fields;
DROP TABLE IF EXISTS temp_clients__id_documents;
DROP  TABLE IF EXISTS  contact_email_temp;
DROP  TABLE IF EXISTS  contact_mobile_phone_temp;
DROP  TABLE IF EXISTS  contact_alternate_phone_temp;  
*/

/*-------------------*/
/*----Cheksum ODS----*/
/*-------------------*/

DROP TEMPORARY TABLE IF EXISTS chksum_ods_party;
CREATE TEMPORARY TABLE chksum_ods_party
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,a.cbs_party_id,
		first_name,last_name, middle_name,dob,gender,salutation ,suffix,civil_status,
		place_of_birth,nationality, no_of_dependents,arn_no,idm_arn_no,party_status,
		is_dosri, is_rpt,is_fatca,party_type,preferred_address_id, fatca_w9_idtype,
		fatca_w9_idnumber,app_channel_type, app_product_type,app_party_type,
		channel_type, product_type ,sssgsis,tinid,is_record_edited,
		party_matrix_header_id, card_issuance_status,my_job,is_active,created_date,
		created_by,approved_date,activation_date,is_latest_rec,
		MD5(CONCAT(IFNULL(First_Name,0),
		IFNULL(Last_Name,0),
		IFNULL(Middle_Name,0),
		IFNULL(DOB,0),
		IFNULL(Gender,0),
		IFNULL(Salutation,0),
		IFNULL(Suffix,0),
		IFNULL(Civil_Status,0),
		IFNULL(Place_Of_Birth,0),
		IFNULL(Nationality,0),
		IFNULL(No_Of_Dependents,0),
		IFNULL(Arn_No,0),
		IFNULL(Idm_Arn_No,0),
		IFNULL(Party_Status,0),
		IFNULL(Is_FATCA,0),
		IFNULL(Party_Type,0),
		IFNULL(fatca_W9_IdType,0),
		IFNULL(fatca_W9_IdNumber,0),
		IFNULL(sssGsis,0),
		IFNULL(tinId,0),
		IFNULL(Card_Issuance_Status,0),
		IFNULL(My_Job,0),
		IFNULL(Approved_Date,0),
		IFNULL(Activation_Date,0))) As Hashtag_val,
		"First_Name, Last_Name, Middle_Name, DOB, Gender, Salutation, Suffix, Civil_Status, Place_Of_Birth, Nationality, No_Of_Dependents, Arn_No, Idm_Arn_No, Party_Status, Is_FATCA, Party_Type, fatca_W9_IdType, fatca_W9_IdNumber, sssGsis, tinId, Card_Issuance_Status, My_Job, Approved_Date, Activation_Date"
		 as Taged_columns FROM ods_party a;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_party_status;
CREATE TEMPORARY TABLE chksum_ods_party_status 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,b.cbs_party_id,status_type, status_flag,a.is_latest_rec,
       MD5(CONCAT(IFNULL(status_type,0),IFNULL(status_flag,0))) Hashtag_val ,
"status_type,status_flag" Taged_columns 
FROM ods_party_status a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_address;
CREATE TEMPORARY TABLE chksum_ods_address  
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,b.cbs_party_id,
	   address_type, number_and_street,barangay,landmark, comments,city,state,region,
	   country,country_code, zip_code,nom_index,date_since_residing,
	   is_preferred_address,province ,
	   MD5(CONCAT(IFNULL(Address_Type,0),
	   IFNULL(Number_And_Street,0),
	   IFNULL(Barangay,0),
	   IFNULL(LandMark,0),
	   IFNULL(Comments,0),
	   IFNULL(City,0),
	   IFNULL(State,0),
	   IFNULL(Region,0),
	   IFNULL(Country,0),
	   IFNULL(Zip_Code,0),
	   -- IFNULL(Nom_Index,0),
	   0,
	   IFNULL(Date_Since_Residing,0),
	   IFNULL(Is_Preferred_Address,0),
	   IFNULL(Province,0))) as Hashtag_val,
	   "Number_And_Street, Barangay, LandMark, Comments, City, State, Region, Country, Zip_Code, Nom_Index,
	   Date_Since_Residing, Is_Preferred_Address, Province" AS Taged_columns
FROM ods_address a INNER JOIN ods_party b ON a.party_id= b.party_id;
 
DROP TEMPORARY TABLE IF EXISTS chksum_ods_consent_details;
CREATE TEMPORARY TABLE chksum_ods_consent_details  
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,b.cbs_party_id,consent_type,
		consent_capture_source,consent_channel, status,comments,consent_details,
		MD5(CONCAT(IFNULL(b.cbs_party_id,0),IFNULL(Consent_Type,0),IFNULL(Status,0))) as Hashtag_val, 
        "Consent_Type,Status" as Taged_columns
FROM ods_consent_details a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_contact;
CREATE TEMPORARY TABLE chksum_ods_contact  
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id ,b.cbs_party_id ,contact_type ,contact_value ,
				contact_period ,is_preferred,
				MD5(CONCAT(IFNULL(b.cbs_party_id,0),IFNULL(Contact_Type,0),IFNULL(Contact_Value,0))) as Hashtag_val, 
				"Contact_Type, Contact_Value" as Taged_columns
FROM ods_contact a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_relationship;
CREATE TEMPORARY TABLE chksum_ods_relationship 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id,relationship_type, name, 
       a.dob, a.nationality, address, share_percentage, is_nominee,nominee_index,
	   MD5(CONCAT(IFNULL(a.relationship_type,0),IFNULL(a.name,0),IFNULL(a.dob,0),IFNULL(a.nationality,0),IFNULL(a.nominee_index,0))) as Hashtag_val, 
	   "relationship_type, name,dob,nationality,nominee_index" as Taged_columns
FROM ods_relationship a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_system_integration_status;
CREATE TEMPORARY TABLE chksum_ods_system_integration_status 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, system_name,enrollment_status,
MD5(CONCAT(IFNULL(System_Name,0),
IFNULL(Enrollment_Status,0))) as Hashtag_val, 
"System_Name,Enrollment_Status,Status" as Taged_columns  
FROM ods_system_integration_status a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_occupation;
CREATE TEMPORARY TABLE chksum_ods_occupation 	   
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id,nature_of_occupation, nature_of_occupation_code,
       organization, industry_type, industry_type_code, occupation_type, occupation_type_code,
 	   occupation_status, occupation_status_code,date_of_commencement, monthly_income, annual_income,
	   fund_source_name, fund_source_code,source_of_wealth, proof_of_sow, party_linked_companies,
	   party_banks, proof_of_address,proof_of_income, salary_period, salary_dates,
	   proof_of_billing, profession,
	   MD5(CONCAT(IFNULL(cbs_party_id,0),
	       IFNULL(nature_of_occupation,0),
	       IFNULL(nature_of_occupation_code,0),
		   IFNULL(`organization`,0),
           IFNULL(industry_type,0),
		   IFNULL(industry_type_code,0),
		   IFNULL(occupation_type,0),
		   IFNULL(occupation_type_code,0),
		   IFNULL(fund_source_name,0),
		   IFNULL(fund_source_code,0),
		   IFNULL(source_of_wealth,0),
		   IFNULL(proof_of_sow,0),
		   IFNULL(party_linked_companies,0),
		   IFNULL(party_banks,0),
		   IFNULL(proof_of_address,0),
		   IFNULL(proof_of_income,0),
		   IFNULL(salary_period,0),
		   IFNULL(salary_dates,0),
		   IFNULL(proof_of_billing,0),
		   IFNULL(profession,0))) as Hashtag_val,
	   "cbs_party_id,nature_of_occupation, nature_of_occupation_code,
       organization, industry_type, industry_type_code, occupation_type, occupation_type_code,
 	   occupation_status, occupation_status_code,date_of_commencement, monthly_income, annual_income,
	   fund_source_name, fund_source_code,source_of_wealth, proof_of_sow, party_linked_companies,
	   party_banks, proof_of_address,proof_of_income, salary_period, salary_dates,
	   proof_of_billing, profession"as Taged_columns  	   
FROM ods_occupation a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_kyc_details;
CREATE TEMPORARY TABLE chksum_ods_kyc_details 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, document_id,
		document_type, issuing_authority, valid_until, national_id,
		MD5(CONCAT(IFNULL(document_id,0),
		IFNULL(document_type,0),
		IFNULL(issuing_authority,0),
		IFNULL(valid_until,0),
		IFNULL(National_Id,0)
		)) as Hashtag_val, 
		"document_id,document_type,issuing_authority,
		valid_until,National_Id" as Taged_columns
FROM ods_kyc_details a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_asset_details;
CREATE TEMPORARY TABLE chksum_ods_asset_details 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, asset_number,
	asset_description, product_id, purchase_date, status, quantity, price,valid_upto,
	MD5(CONCAT(IFNULL(Asset_Number,0),
		IFNULL(Asset_Description,0),
		IFNULL(product_id,0),
		IFNULL(purchase_date,0),
		IFNULL(status,0),
		IFNULL(quantity,0),
		IFNULL(price,0),
		IFNULL(valid_upto,0)
		)) as Hashtag_val, 
		"Asset_Number,Asset_Description,product_id,purchase_date,status,quantity,
        price,valid_upto" as Taged_columns
FROM ods_asset_details a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_device_details;
CREATE TEMPORARY TABLE  chksum_ods_device_details
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, device_ip, latitude,longitude ,
	   MD5(CONCAT(IFNULL(a.device_ip,0),
			IFNULL(latitude,0),
			IFNULL(longitude,0)
			)) as Hashtag_val, 
			"device_ip,latitude,longitude" as Taged_columns
FROM ods_device_details a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_external_system_response;
CREATE TEMPORARY TABLE chksum_ods_external_system_response
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, external_system_name,
external_response_details, overall_status, case_id ,
MD5(CONCAT(IFNULL(a.external_system_name,0),
			IFNULL(overall_status,0),
			IFNULL(case_id,0),
			IFNULL(External_Response_Details,0)
			)) as Hashtag_val, 
			"external_system_name,overall_status,case_id" as Taged_columns
FROM ods_external_system_response a INNER JOIN ods_party b ON a.party_id = b.party_id;

DROP TEMPORARY TABLE IF EXISTS chksum_ods_referral_promotion;
CREATE TEMPORARY TABLE chksum_ods_referral_promotion
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id,
       referral_code, promo_code, company_code, agent_code, ref_promo_flag, 
	   MD5(CONCAT(IFNULL(Referral_Code,0), 
				  IFNULL(Promo_Code,0), 
				  IFNULL(Company_Code,0), 
				  IFNULL(Agent_Code,0), 
				  IFNULL(Ref_Promo_Flag,0))) as Hashtag_val,  
				  "Referral_Code, Promo_Code, Company_Code, Agent_Code, Ref_Promo_Flag" as Taged_columns
FROM ods_referral_promotion a INNER JOIN ods_party b ON a.party_id = b.party_id;

/*-------------------*/
/*----Cheksum CRM----*/
/*-------------------*/

DROP TEMPORARY TABLE IF EXISTS chksum_crm_party;
CREATE TEMPORARY TABLE chksum_crm_party
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,a.cbs_party_id,
		first_name,last_name, middle_name,dob,gender,salutation ,suffix,civil_status,
		place_of_birth,nationality, no_of_dependents,arn_no,idm_arn_no,party_status,
		is_dosri, is_rpt,is_fatca,party_type,preferred_address_id, fatca_w9_idtype,
		fatca_w9_idnumber,app_channel_type, app_product_type,app_party_type,
		channel_type, product_type ,sssgsis,tinid,is_record_edited,
		party_matrix_header_id, card_issuance_status,my_job,is_active,created_date,
		created_by,approved_date,activation_date,is_latest_rec,
		MD5(CONCAT(IFNULL(First_Name,0),
		IFNULL(Last_Name,0),
		IFNULL(Middle_Name,0),
		IFNULL(DOB,0),
		IFNULL(Gender,0),
		IFNULL(Salutation,0),
		IFNULL(Suffix,0),
		IFNULL(Civil_Status,0),
		IFNULL(Place_Of_Birth,0),
		IFNULL(Nationality,0),
		IFNULL(No_Of_Dependents,0),
		IFNULL(Arn_No,0),
		IFNULL(Idm_Arn_No,0),
		IFNULL(Party_Status,0),
		IFNULL(Is_FATCA,0),
		IFNULL(Party_Type,0),
		IFNULL(fatca_W9_IdType,0),
		IFNULL(fatca_W9_IdNumber,0),
		IFNULL(sssGsis,0),
		IFNULL(tinId,0),
		IFNULL(Card_Issuance_Status,0),
		IFNULL(My_Job,0),
		IFNULL(Approved_Date,0),
		IFNULL(Activation_Date,0))) As Hashtag_val,
		"First_Name, Last_Name, Middle_Name, DOB, Gender, Salutation, Suffix, Civil_Status, Place_Of_Birth, Nationality, No_Of_Dependents, Arn_No, Idm_Arn_No, Party_Status, Is_FATCA, Party_Type, fatca_W9_IdType, fatca_W9_IdNumber, sssGsis, tinId, Card_Issuance_Status, My_Job, Approved_Date, Activation_Date"
		 as Taged_columns
FROM party a WHERE a.is_active= 1 AND is_latest_rec = 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients b WHERE a.cbs_party_id = b.cbs_party_id);
  
DROP TEMPORARY TABLE IF EXISTS chksum_crm_party_status;
CREATE TEMPORARY TABLE chksum_crm_party_status
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,b.cbs_party_id,status_type, status_flag,a.is_latest_rec,
       MD5(CONCAT(IFNULL(status_type,0),IFNULL(status_flag,0))) Hashtag_val ,
"status_type,status_flag" Taged_columns 
FROM party_status a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec ='Y' 
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = a.cbs_party_id);
  

DROP TEMPORARY TABLE IF EXISTS chksum_crm_address;
CREATE TEMPORARY TABLE chksum_crm_address 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,b.cbs_party_id,
	   address_type, number_and_street,barangay,landmark, comments,city,state,region,
	   country,country_code, zip_code,nom_index,date_since_residing,
	   is_preferred_address,province ,
	   MD5(CONCAT(IFNULL(Address_Type,0),
	   IFNULL(Number_And_Street,0),
	   IFNULL(Barangay,0),
	   IFNULL(LandMark,0),
	   IFNULL(Comments,0),
	   IFNULL(City,0),
	   IFNULL(State,0),
	   IFNULL(Region,0),
	   IFNULL(Country,0),
	   IFNULL(Zip_Code,0),
	   -- IFNULL(Nom_Index,0),
	   0,
	   IFNULL(Date_Since_Residing,0),
	   IFNULL(Is_Preferred_Address,0),
	   IFNULL(Province,0))) as Hashtag_val,
	   "Number_And_Street, Barangay, LandMark, Comments, City, State, Region, Country, Zip_Code, Nom_Index,
	   Date_Since_Residing, Is_Preferred_Address, Province" AS Taged_columns
FROM address a INNER JOIN party b ON a.party_id= b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y' 
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.party_id = c.cbs_party_id);
 

DROP TEMPORARY TABLE IF EXISTS chksum_crm_consent_details;
CREATE TEMPORARY TABLE chksum_crm_consent_details  
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id,b.cbs_party_id,consent_type,
		consent_capture_source,consent_channel, status,comments,consent_details,
		MD5(CONCAT(IFNULL(b.cbs_party_id,0),IFNULL(Consent_Type,0),IFNULL(Status,0))) as Hashtag_val, 
        "Consent_Type,Status" as Taged_columns
FROM consent_details a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active= 1 AND a.is_latest_rec = 'Y' 
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);


DROP TEMPORARY TABLE IF EXISTS chksum_crm_contact;
CREATE TEMPORARY TABLE chksum_crm_contact
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id ,b.cbs_party_id ,contact_type ,contact_value ,
				contact_period ,is_preferred,
				MD5(CONCAT(IFNULL(b.cbs_party_id,0),IFNULL(Contact_Type,0),IFNULL(Contact_Value,0))) as Hashtag_val, 
				"Contact_Type, Contact_Value" as Taged_columns
FROM contact a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);


DROP TEMPORARY TABLE IF EXISTS chksum_crm_relationship;
CREATE TEMPORARY TABLE chksum_crm_relationship
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id,relationship_type, name, 
       a.dob, a.nationality, address, share_percentage, is_nominee,nominee_index,
	   MD5(CONCAT(IFNULL(a.relationship_type,0),IFNULL(a.name,0),IFNULL(a.dob,0),IFNULL(a.nationality,0),IFNULL(a.nominee_index,0))) as Hashtag_val, 
	   "relationship_type, name,dob,nationality,nominee_index" as Taged_columns
FROM relationship a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active= 1 AND a.is_latest_rec = 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id= c.cbs_party_id);

DROP TEMPORARY TABLE IF EXISTS chksum_crm_system_integration_status;
CREATE TEMPORARY TABLE chksum_crm_system_integration_status
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, system_name,enrollment_status,
MD5(CONCAT(IFNULL(System_Name,0),
IFNULL(Enrollment_Status,0))) as Hashtag_val, 
"System_Name,Enrollment_Status,Status" as Taged_columns  
FROM system_integration_status a INNER JOIN party b ON a.party_id = b.cbs_party_id
WHERE a.is_latest_rec = 'Y' 
-- WHERE a.is_active = 1 AND a.is_latest_rec = 'Y' 
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);

DROP TEMPORARY TABLE IF EXISTS chksum_crm_occupation;
CREATE TEMPORARY TABLE chksum_crm_occupation	   
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id,nature_of_occupation, nature_of_occupation_code,
       organization, industry_type, industry_type_code, occupation_type, occupation_type_code,
 	   occupation_status, occupation_status_code,date_of_commencement, monthly_income, annual_income,
	   fund_source_name, fund_source_code,source_of_wealth, proof_of_sow, party_linked_companies,
	   party_banks, proof_of_address,proof_of_income, salary_period, salary_dates,
	   proof_of_billing, profession,
	   MD5(CONCAT(IFNULL(cbs_party_id,0),
	       IFNULL(nature_of_occupation,0),
	       IFNULL(nature_of_occupation_code,0),
		   IFNULL(`organization`,0),
           IFNULL(industry_type,0),
		   IFNULL(industry_type_code,0),
		   IFNULL(occupation_type,0),
		   IFNULL(occupation_type_code,0),
		   IFNULL(fund_source_name,0),
		   IFNULL(fund_source_code,0),
		   IFNULL(source_of_wealth,0),
		   IFNULL(proof_of_sow,0),
		   IFNULL(party_linked_companies,0),
		   IFNULL(party_banks,0),
		   IFNULL(proof_of_address,0),
		   IFNULL(proof_of_income,0),
		   IFNULL(salary_period,0),
		   IFNULL(salary_dates,0),
		   IFNULL(proof_of_billing,0),
		   IFNULL(profession,0))) as Hashtag_val,
	   "cbs_party_id,nature_of_occupation, nature_of_occupation_code,
       organization, industry_type, industry_type_code, occupation_type, occupation_type_code,
 	   occupation_status, occupation_status_code,date_of_commencement, monthly_income, annual_income,
	   fund_source_name, fund_source_code,source_of_wealth, proof_of_sow, party_linked_companies,
	   party_banks, proof_of_address,proof_of_income, salary_period, salary_dates,
	   proof_of_billing, profession"as Taged_columns  	   
FROM occupation a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);
 
DROP TEMPORARY TABLE IF EXISTS chksum_crm_kyc_details;
CREATE TEMPORARY TABLE chksum_crm_kyc_details 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, document_id,
		document_type, issuing_authority, valid_until, national_id,
		MD5(CONCAT(IFNULL(document_id,0),
		IFNULL(document_type,0),
		IFNULL(issuing_authority,0),
		IFNULL(valid_until,0),
		IFNULL(National_Id,0)
		)) as Hashtag_val, 
		"document_id,document_type,issuing_authority,
		valid_until,National_Id" as Taged_columns
FROM kyc_details a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec= 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);

DROP TEMPORARY TABLE IF EXISTS chksum_crm_asset_details;
CREATE TEMPORARY TABLE chksum_crm_asset_details 
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, asset_number,
	asset_description, product_id, purchase_date, status, quantity, price,valid_upto,
	MD5(CONCAT(IFNULL(Asset_Number,0),
		IFNULL(Asset_Description,0),
		IFNULL(product_id,0),
		IFNULL(purchase_date,0),
		IFNULL(status,0),
		IFNULL(quantity,0),
		IFNULL(price,0),
		IFNULL(valid_upto,0)
		)) as Hashtag_val, 
		"Asset_Number,Asset_Description,product_id,purchase_date,status,quantity,
        price,valid_upto" as Taged_columns
FROM asset_details a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);  

DROP TEMPORARY TABLE IF EXISTS chksum_crm_device_details;
CREATE TEMPORARY TABLE chksum_crm_device_details
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, device_ip, latitude,longitude ,
	   MD5(CONCAT(IFNULL(a.device_ip,0),
			IFNULL(latitude,0),
			IFNULL(longitude,0)
			)) as Hashtag_val, 
			"device_ip,latitude,longitude" as Taged_columns
FROM device_details a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y' 
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);

DROP TEMPORARY TABLE IF EXISTS chksum_crm_external_system_response;
CREATE TEMPORARY TABLE chksum_crm_external_system_response
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id, external_system_name,
external_response_details, overall_status, case_id ,
MD5(CONCAT(IFNULL(a.external_system_name,0),
			IFNULL(overall_status,0),
			IFNULL(case_id,0),
			IFNULL(External_Response_Details,0)
			)) as Hashtag_val, 
			"external_system_name,overall_status,case_id" as Taged_columns
FROM external_system_response a INNER JOIN party b ON a.party_id = b.party_id 
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y' 
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);

DROP TEMPORARY TABLE IF EXISTS chksum_crm_referral_promotion;
CREATE TEMPORARY TABLE chksum_crm_referral_promotion
SELECT DISTINCT /*+PARALLEL(32)*/ a.party_id, b.cbs_party_id,
       referral_code, promo_code, company_code, agent_code, ref_promo_flag, 
	   MD5(CONCAT(IFNULL(Referral_Code,0), 
				  IFNULL(Promo_Code,0), 
				  IFNULL(Company_Code,0), 
				  IFNULL(Agent_Code,0), 
				  IFNULL(Ref_Promo_Flag,0))) as Hashtag_val,  
				  "Referral_Code, Promo_Code, Company_Code, Agent_Code, Ref_Promo_Flag" as Taged_columns
FROM referral_promotion a INNER JOIN party b ON a.party_id = b.party_id
WHERE a.is_active = 1 AND a.is_latest_rec = 'Y'
AND EXISTS (SELECT 1 FROM temp_count_clients c WHERE b.cbs_party_id = c.cbs_party_id);

/********** Reconsliation starts here *****************/-- till now its executed

DROP TABLE IF EXISTS `Checksum_CRM_ODS`;
CREATE TABLE `Checksum_CRM_ODS`  ( 
     `source`             VARCHAR(50) NOT NULL DEFAULT '',
     `table_name`         VARCHAR(50) NOT NULL DEFAULT '',
     `cbs_party_id`       BIGINT NOT NULL,
     `taged_columns`      VARCHAR(1000) NOT NULL DEFAULT '',
     `source_hashtag_val` VARCHAR(1000) DEFAULT NULL,
     `target_hashtag_val` VARCHAR(1000) DEFAULT NULL,
     `mig_status`         VARCHAR(50) NOT NULL DEFAULT '',
	 `recon_date`         DATETIME DEFAULT CURRENT_TIMESTAMP
  ) engine=innodb DEFAULT charset=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; 

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS' ,'Party' as Table_Name, a.CBS_party_id, a.Taged_columns, a.Hashtag_val as Source_Hashtag_Val, 
b.Hashtag_Val as Target_Hashtag_Val, 
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_party a
inner join chksum_crm_party b on b.CBS_party_id=a.CBS_party_id;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'Party_Status' as Table_Name, a.CBS_party_id, a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_party_status a
inner join chksum_crm_party_status b on b.CBS_party_id=a.CBS_party_id 
and b.Hashtag_val=a.Hashtag_val;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`) 
Select  Distinct 'CRM_ODS', 'Address' as Table_Name, a.CBS_party_id, a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_address a
inner join chksum_crm_address b on b.CBS_party_id=a.CBS_party_id and a.address_Type=b.address_Type
group by a.CBS_party_id,a.address_Type;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'Consent_Details' as Table_Name, a.CBS_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_consent_details a
inner join chksum_crm_consent_details b on b.CBS_party_id=a.CBS_party_id 
group by a.CBS_party_id;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'Asset_Details' as Table_Name, a.CBS_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_asset_details a
inner join chksum_crm_asset_details b on b.CBS_party_id=a.CBS_party_id and a.Asset_Number=b.Asset_Number;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'system_integration_status' as Table_Name, a.CBS_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_system_integration_status a
inner join chksum_crm_system_integration_status b on b.CBS_party_id=a.CBS_party_id and a.System_Name=b.System_Name;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'kyc_details' as Table_Name, a.CBS_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_kyc_details a
inner join chksum_crm_kyc_details b on b.CBS_party_id=a.CBS_party_id and a.document_type=b.document_type and a.national_id=b.national_id;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'Contact' as Table_Name, a.CBS_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_contact a
inner join chksum_crm_contact b on b.CBS_party_id=a.CBS_party_id and a.Contact_Type=b.Contact_Type;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `cbs_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'external_system_response' as Table_Name, a.CBS_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_external_system_response a
inner join chksum_crm_external_system_response b on b.CBS_party_id=a.CBS_party_id and a.External_System_Name=b.External_System_Name;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `CBS_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'referral_promotion' as Table_Name, a.party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_referral_promotion a
inner join chksum_crm_referral_promotion b on b.CBS_party_id=a.CBS_party_id;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `CBS_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'device_details' as Table_Name, a.cbs_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_device_details a
inner join chksum_crm_device_details b on b.CBS_party_id=a.CBS_party_id;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `CBS_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'occupation' as Table_Name, a.cbs_party_id,a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_occupation a
inner join chksum_crm_occupation b on b.CBS_party_id=a.CBS_party_id;

Insert into Checksum_CRM_ODS (`Source`, `Table_Name`, `CBS_party_id`, `Taged_columns`, `Source_Hashtag_val`, `Target_Hashtag_val`, `MIG_Status`)
Select  Distinct 'CRM_ODS', 'relationship' as Table_Name, a.cbs_party_id, a.Taged_columns, a.Hashtag_val, b.Hashtag_val,
case when a.Hashtag_val=b.Hashtag_val Then 'Matched' else 'Not Macthed' End as MIG_Status
from chksum_ods_relationship a
inner join chksum_crm_relationship b on b.CBS_party_id=a.CBS_party_id and a.relationship_type=b.relationship_type and a.nominee_index=b.nominee_index and a.dob=b.dob;

-- Reconciliation starts for Unmacthed records
-- For Party table 

DROP TEMPORARY TABLE IF EXISTS crm_final_rcon_party_temp;
CREATE TEMPORARY TABLE crm_final_rcon_party_temp
select distinct a.* from(
select distinct 'Party'as CRM_TABLE,'CRM' as CRM,cbs_party_id,First_Name, Last_Name, Middle_Name, DOB, Gender, Salutation, Suffix, Civil_Status, Place_Of_Birth, Nationality, No_Of_Dependents, Arn_No, Idm_Arn_No, Party_Status, Is_FATCA, Party_Type, fatca_W9_IdType, fatca_W9_IdNumber, sssGsis, tinId, Card_Issuance_Status, My_Job, Approved_Date, Activation_Date from party where cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods  where mig_status ='Not Macthed')
union
select distinct 'Party' as CRM_TABLE,'ODS' as CRM, cbs_party_id,First_Name, Last_Name, Middle_Name, DOB, Gender, Salutation, Suffix, Civil_Status, Place_Of_Birth, Nationality, No_Of_Dependents, Arn_No, Idm_Arn_No, Party_Status, Is_FATCA, Party_Type, fatca_W9_IdType, fatca_W9_IdNumber, sssGsis, tinId, Card_Issuance_Status, My_Job, Approved_Date, Activation_Date from ods_party 
where  cbs_party_id in(select distinct cbs_party_id from checksum_crm_ods  where mig_status ='Not Macthed'))a
order by CRM_TABLE,a.cbs_party_id;

DROP  TABLE IF EXISTS crm_final_rcon_tab_temp;
CREATE  TABLE crm_final_rcon_tab_temp
(CRM_TABLE varchar(50),
 column_names varchar(50),
 cbs_party_id varchar(20), 
 crm_column_data varchar(100), 
 ods_column_date varchar(100));

-- For Party

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
WITH cte1 AS
(select distinct 'Party'as CRM_TABLE,'CRM' as CRM,cbs_party_id,First_Name, Last_Name, Middle_Name, DOB, Gender, Salutation, Suffix, Civil_Status, Place_Of_Birth, Nationality, No_Of_Dependents, Arn_No, Idm_Arn_No, Party_Status, Is_FATCA, Party_Type, fatca_W9_IdType, fatca_W9_IdNumber, sssGsis, tinId, Card_Issuance_Status, My_Job, Approved_Date, Activation_Date from party where cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'Party'as CRM_TABLE,'ODS' as CRM,cbs_party_id,First_Name, Last_Name, Middle_Name, DOB, Gender, Salutation, Suffix, Civil_Status, Place_Of_Birth, Nationality, No_Of_Dependents, Arn_No, Idm_Arn_No, Party_Status, Is_FATCA, Party_Type, fatca_W9_IdType, fatca_W9_IdNumber, sssGsis, tinId, Card_Issuance_Status, My_Job, Approved_Date, Activation_Date from ods_party where cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'First_Name',a.cbs_party_id,a.First_Name as 'CRM_First_Name',b.first_name as 'ODS_First_Name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.first_name))<>upper(trim(b.first_name))
union
select  a.CRM_TABLE,'Last_name',a.cbs_party_id,a.Last_name as 'CRM_Last_name',b.Last_name as 'ODS_Last_name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Last_name))<>upper(trim(b.Last_name))
union
select  a.CRM_TABLE,'Middle_Name',a.cbs_party_id,a.Middle_Name as 'CRM_Middle_Name',b.Middle_Name as 'ODS_Middle_Name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Middle_Name))<>upper(trim(b.Middle_Name))
union
select  a.CRM_TABLE,'DOB',a.cbs_party_id,a.DOB as 'CRM_DOB',b.DOB as 'ODS_DOB'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.DOB))<>upper(trim(b.DOB))
UNION
select  a.CRM_TABLE,'Gender',a.cbs_party_id,a.Gender as 'CRM_Gender',b.Gender as 'ODS_Gender'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Gender))<>upper(trim(b.Gender))
UNION
select  a.CRM_TABLE,'Salutation',a.cbs_party_id,a.Salutation as 'CRM_Salutation',b.Salutation as 'ODS_Salutation'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Salutation))<>upper(trim(b.Salutation))
UNION
select  a.CRM_TABLE,'Suffix',a.cbs_party_id,a.Suffix as 'CRM_Suffix',b.Suffix as 'ODS_Suffix'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Suffix))<>upper(trim(b.Suffix))
UNION
select  a.CRM_TABLE,'Civil_Status',a.cbs_party_id,a.Civil_Status as 'CRM_Civil_Status',b.Civil_Status as 'ODS_Civil_Status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Civil_Status))<>upper(trim(b.Civil_Status))
UNION
select  a.CRM_TABLE,'Place_Of_Birth',a.cbs_party_id,a.Place_Of_Birth as 'CRM_Place_Of_Birth',b.Place_Of_Birth as 'ODS_Place_Of_Birth'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Place_Of_Birth))<>upper(trim(b.Place_Of_Birth))
UNION
select  a.CRM_TABLE,'Nationality',a.cbs_party_id,a.Nationality as 'CRM_Nationality',b.Nationality as 'ODS_Nationality'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Nationality))<>upper(trim(b.Nationality))
UNION
select  a.CRM_TABLE,'No_Of_Dependents',a.cbs_party_id,a.No_Of_Dependents as 'CRM_No_Of_Dependents',b.No_Of_Dependents as 'ODS_No_Of_Dependents'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.No_Of_Dependents))<>upper(trim(b.No_Of_Dependents))
UNION
select  a.CRM_TABLE,'Arn_No',a.cbs_party_id,a.Arn_No as 'CRM_Arn_No',b.Arn_No as 'ODS_Arn_No'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Arn_No))<>upper(trim(b.Arn_No))
UNION
select  a.CRM_TABLE,'Idm_Arn_No',a.cbs_party_id,a.Idm_Arn_No as 'CRM_Idm_Arn_No',b.Idm_Arn_No as 'ODS_Idm_Arn_No'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Idm_Arn_No))<>upper(trim(b.Idm_Arn_No))
UNION
select  a.CRM_TABLE,'Party_Status',a.cbs_party_id,a.Party_Status as 'CRM_Party_Status',b.Party_Status as 'ODS_Party_Status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Party_Status))<>upper(trim(b.Party_Status))
UNION
select  a.CRM_TABLE,'Is_FATCA',a.cbs_party_id,a.Is_FATCA as 'CRM_Is_FATCA',b.Is_FATCA as 'ODS_Is_FATCA'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Is_FATCA))<>upper(trim(b.Is_FATCA))
UNION
select  a.CRM_TABLE,'Party_Type',a.cbs_party_id,a.Party_Type as 'CRM_Party_Type',b.Party_Type as 'ODS_Party_Type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Party_Type))<>upper(trim(b.Party_Type))
UNION
select  a.CRM_TABLE,'fatca_W9_IdType',a.cbs_party_id,a.fatca_W9_IdType as 'CRM_fatca_W9_IdType',b.fatca_W9_IdType as 'ODS_fatca_W9_IdType'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.fatca_W9_IdType))<>upper(trim(b.fatca_W9_IdType))
UNION
select  a.CRM_TABLE,'fatca_W9_IdNumber',a.cbs_party_id,a.fatca_W9_IdNumber as 'CRM_fatca_W9_IdNumber',b.fatca_W9_IdNumber as 'ODS_fatca_W9_IdNumber'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.fatca_W9_IdNumber))<>upper(trim(b.fatca_W9_IdNumber))
UNION
select  a.CRM_TABLE,'sssGsis',a.cbs_party_id,a.sssGsis as 'CRM_sssGsis',b.sssGsis as 'ODS_sssGsis'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.sssGsis))<>upper(trim(b.sssGsis))
union
select  a.CRM_TABLE,'tinId',a.cbs_party_id,a.tinId as 'CRM_tinId',b.tinId as 'ODS_tinId'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.tinId))<>upper(trim(b.tinId))
UNION
select  a.CRM_TABLE,'Card_Issuance_Status',a.cbs_party_id,a.Card_Issuance_Status as 'CRM_Card_Issuance_Status',b.Card_Issuance_Status as 'ODS_Card_Issuance_Status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Card_Issuance_Status))<>upper(trim(b.Card_Issuance_Status))
UNION
select  a.CRM_TABLE,'My_Job',a.cbs_party_id,a.My_Job as 'CRM_My_Job',b.My_Job as 'ODS_My_Job'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.My_Job))<>upper(trim(b.My_Job))
UNION
select  a.CRM_TABLE,'Approved_Date',a.cbs_party_id,a.Approved_Date as 'CRM_Approved_Date',b.Approved_Date as 'ODS_Approved_Date'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Approved_Date))<>upper(trim(b.Approved_Date))
UNION
select  a.CRM_TABLE,'Activation_Date',a.cbs_party_id,a.Activation_Date as 'CRM_Activation_Date',b.Activation_Date as 'ODS_Activation_Date'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.Activation_Date))<>upper(trim(b.Activation_Date)))a
order by cbs_party_id;

-- For Address

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'Address'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,address_type, number_and_street,barangay,landmark, comments,city,state,region,
country,country_code, zip_code,nom_index,date_since_residing,is_preferred_address,province 
from address a INNER JOIN party b ON a.party_id = b.party_id where b.cbs_party_id
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'Address'as CRM_TABLE,'ODS' as CRM, b.cbs_party_id,address_type, number_and_street,barangay,landmark, comments,city,state,region,
country,country_code, zip_code,nom_index,date_since_residing,is_preferred_address,province 
from ODS_address a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'address_type',a.cbs_party_id,a.address_type as 'CRM_address_type',b.address_type as 'ODS_address_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.address_type))<>upper(trim(b.address_type))
UNION
select  a.CRM_TABLE,'number_and_street',a.cbs_party_id,a.number_and_street as 'CRM_number_and_street',b.number_and_street as 'ODS_number_and_street'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.number_and_street))<>upper(trim(b.number_and_street))
UNION
select  a.CRM_TABLE,'barangay',a.cbs_party_id,a.barangay as 'CRM_barangay',b.barangay as 'ODS_barangay'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.barangay))<>upper(trim(b.barangay))
UNION
select  a.CRM_TABLE,'landmark',a.cbs_party_id,a.landmark as 'CRM_landmark',b.landmark as 'ODS_landmark'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.landmark))<>upper(trim(b.landmark))
UNION
select  a.CRM_TABLE,'comments',a.cbs_party_id,a.comments as 'CRM_comments',b.comments as 'ODS_comments'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.comments))<>upper(trim(b.comments))
UNION
select  a.CRM_TABLE,'city',a.cbs_party_id,a.city as 'CRM_city',b.city as 'ODS_city'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.city))<>upper(trim(b.city))
UNION
select  a.CRM_TABLE,'state',a.cbs_party_id,a.state as 'CRM_state',b.state as 'ODS_state'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.state))<>upper(trim(b.state))
UNION
select  a.CRM_TABLE,'region',a.cbs_party_id,a.region as 'CRM_region',b.region as 'ODS_region'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.region))<>upper(trim(b.region))
UNION
select  a.CRM_TABLE,'country',a.cbs_party_id,a.country as 'CRM_country',b.country as 'ODS_country'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.country))<>upper(trim(b.country))
UNION
select  a.CRM_TABLE,'country_code',a.cbs_party_id,a.country_code as 'CRM_country_code',b.country_code as 'ODS_country_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.country_code))<>upper(trim(b.country_code))
UNION
select  a.CRM_TABLE,'zip_code',a.cbs_party_id,a.zip_code as 'CRM_zip_code',b.zip_code as 'ODS_zip_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.zip_code))<>upper(trim(b.zip_code))
/*UNION
select  a.CRM_TABLE,'nom_index',a.cbs_party_id,a.nom_index as 'CRM_nom_index',b.nom_index as 'ODS_nom_index'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.nom_index))<>upper(trim(b.nom_index))*/
UNION
select  a.CRM_TABLE,'date_since_residing',a.cbs_party_id,a.date_since_residing as 'CRM_date_since_residing',b.date_since_residing as 'ODS_date_since_residing'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.date_since_residing))<>upper(trim(b.date_since_residing))
UNION
select  a.CRM_TABLE,'is_preferred_address',a.cbs_party_id,a.is_preferred_address as 'CRM_is_preferred_address',b.is_preferred_address as 'ODS_is_preferred_address'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.is_preferred_address))<>upper(trim(b.is_preferred_address))
UNION
select  a.CRM_TABLE,'province',a.cbs_party_id,a.province as 'CRM_province',b.province as 'ODS_province'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.address_type=b.address_type and upper(trim(a.province))<>upper(trim(b.province)))a
order by cbs_party_id;

-- For consent_details

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'consent_details'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,consent_type,consent_capture_source,consent_channel, status,comments,consent_details
from consent_details a INNER JOIN party b ON a.party_id = b.party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'consent_details'as CRM_TABLE,'ODS' as CRM, b.cbs_party_id,consent_type,
consent_capture_source,consent_channel, status,comments,consent_details from ODS_consent_details a INNER JOIN
party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'consent_type',a.cbs_party_id,a.consent_type as 'CRM_consent_type',b.consent_type as 'ODS_consent_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.consent_type))<>upper(trim(b.consent_type))
UNION
select  a.CRM_TABLE,'consent_capture_source',a.cbs_party_id,a.consent_capture_source as 'CRM_consent_capture_source',b.consent_capture_source as 'ODS_consent_capture_source'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.consent_capture_source))<>upper(trim(b.consent_capture_source))
UNION
select  a.CRM_TABLE,'consent_capture_source',a.cbs_party_id,a.consent_capture_source as 'CRM_consent_capture_source',b.consent_capture_source as 'ODS_consent_capture_source'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.consent_capture_source))<>upper(trim(b.consent_capture_source))
UNION
select  a.CRM_TABLE,'consent_channel',a.cbs_party_id,a.consent_channel as 'CRM_consent_channel',b.consent_channel as 'ODS_consent_channel'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.consent_channel))<>upper(trim(b.consent_channel))
UNION
select  a.CRM_TABLE,'status',a.cbs_party_id,a.status as 'CRM_status',b.status as 'ODS_status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.status))<>upper(trim(b.status))
UNION
select  a.CRM_TABLE,'comments',a.cbs_party_id,a.comments as 'CRM_comments',b.comments as 'ODS_comments'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.comments))<>upper(trim(b.comments))
UNION
select  a.CRM_TABLE,'consent_details',a.cbs_party_id,a.consent_details as 'CRM_consent_details',b.consent_details as 'ODS_consent_details'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.consent_details))<>upper(trim(b.consent_details))
)a order by cbs_party_id;

-- For contact

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'contact'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,contact_type ,contact_value ,contact_period ,is_preferred
from contact a INNER JOIN party b ON a.party_id = b.party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'contact'as CRM_TABLE,'ODS' as CRM, b.cbs_party_id,contact_type ,contact_value ,contact_period ,is_preferred
 from ODS_contact a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'contact_type',a.cbs_party_id,a.contact_type as 'CRM_contact_type',b.contact_type as 'ODS_contact_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.contact_type=b.contact_type and upper(trim(a.contact_type))<>upper(trim(b.contact_type))
UNION
select  a.CRM_TABLE,'contact_value',a.cbs_party_id,a.contact_value as 'CRM_contact_value',b.contact_value as 'ODS_contact_value'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.contact_type=b.contact_type and upper(trim(a.contact_value))<>upper(trim(b.contact_value))
UNION
select  a.CRM_TABLE,'contact_period',a.cbs_party_id,a.contact_period as 'CRM_contact_period',b.contact_period as 'ODS_contact_period'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.contact_type=b.contact_type and upper(trim(a.contact_period))<>upper(trim(b.contact_period))
UNION
select  a.CRM_TABLE,'is_preferred',a.cbs_party_id,a.is_preferred as 'CRM_is_preferred',b.is_preferred as 'ODS_is_preferred'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.contact_type=b.contact_type and upper(trim(a.is_preferred))<>upper(trim(b.is_preferred))
)a order by cbs_party_id;

-- For party_status

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'party_status'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,status_type, status_flag,a.is_latest_rec
from party_status a INNER JOIN party b ON a.party_id = b.party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'party_status'as CRM_TABLE,'ODS' as CRM, b.cbs_party_id,status_type, status_flag,a.is_latest_rec
 from ODS_party_status a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'status_type',a.cbs_party_id,a.status_type as 'CRM_status_type',b.status_type as 'ODS_status_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.status_type))<>upper(trim(b.status_type))
UNION
select  a.CRM_TABLE,'status_flag',a.cbs_party_id,a.status_flag as 'CRM_status_flag',b.status_flag as 'ODS_status_flag'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.status_flag))<>upper(trim(b.status_flag))
UNION
select  a.CRM_TABLE,'is_latest_rec',a.cbs_party_id,a.is_latest_rec as 'CRM_is_latest_rec',b.is_latest_rec as 'ODS_is_latest_rec'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.is_latest_rec))<>upper(trim(b.is_latest_rec))
)a order by cbs_party_id;

-- For relationship

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'relationship'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,relationship_type, name,a.dob,a.nationality, address, share_percentage, is_nominee,nominee_index
from relationship a INNER JOIN party b ON a.party_id = b.party_id where a.is_active= 1 AND a.is_latest_rec = 'Y' and b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'relationship'as CRM_TABLE,'ODS' as CRM, b.cbs_party_id,relationship_type, name,a.dob,a.nationality, address, share_percentage, is_nominee,nominee_index
 from ODS_relationship a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'relationship_type',a.cbs_party_id,a.relationship_type as 'CRM_relationship_type',b.relationship_type as 'ODS_relationship_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.name = b.name and a.dob=b.dob and 
a.nominee_index=b.nominee_index and upper(trim(a.relationship_type))<>upper(trim(b.relationship_type))
UNION
select  a.CRM_TABLE,'name',a.cbs_party_id,a.name as 'CRM_name',b.name as 'ODS_name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id and a.relationship_type=b.relationship_type 
and a.name=b.name and a.nominee_index=b.nominee_index where upper(trim(a.name))<>upper(trim(b.name))
union
select  a.CRM_TABLE,'dob',a.cbs_party_id,a.dob as 'CRM_dob',b.dob as 'ODS_dob'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id and a.relationship_type=b.relationship_type 
and a.name=b.name and a.dob=b.dob and a.nominee_index=b.nominee_index where upper(trim(a.dob))<>upper(trim(b.dob))
UNION
select  a.CRM_TABLE,'nationality',a.cbs_party_id,a.nationality as 'CRM_nationality',b.nationality as 'ODS_nationality'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id and a.relationship_type=b.relationship_type 
and a.name=b.name and a.nominee_index=b.nominee_index where upper(trim(a.nationality))<>upper(trim(b.nationality))
UNION
select  a.CRM_TABLE,'share_percentage',a.cbs_party_id,a.share_percentage as 'CRM_share_percentage',b.share_percentage as 'ODS_share_percentage'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id and a.relationship_type=b.relationship_type 
and a.name=b.name and a.nominee_index=b.nominee_index  where upper(trim(a.share_percentage))<>upper(trim(b.share_percentage))
UNION
select  a.CRM_TABLE,'is_nominee',a.cbs_party_id,a.is_nominee as 'CRM_is_nominee',b.is_nominee as 'ODS_is_nominee'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id and a.relationship_type=b.relationship_type 
and a.name=b.name and a.nominee_index=b.nominee_index where upper(trim(a.is_nominee))<>upper(trim(b.is_nominee))
UNION
select  a.CRM_TABLE,'nominee_index',a.cbs_party_id,a.nominee_index as 'CRM_nominee_index',b.nominee_index as 'ODS_nominee_index'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id and a.relationship_type=b.relationship_type 
and a.name=b.name and a.nominee_index=b.nominee_index where upper(trim(a.nominee_index))<>upper(trim(b.nominee_index))
)a order by cbs_party_id;

-- For system_integration_status

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'system_integration_status'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,system_name,enrollment_status
from system_integration_status a INNER JOIN party b ON a.party_id = b.party_id where a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'system_integration_status'as CRM_TABLE,'ODS' as CRM, cbs_party_id,system_name,enrollment_status
 from ODS_system_integration_status a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'system_name',a.cbs_party_id,a.system_name as 'CRM_system_name',b.system_name as 'ODS_system_name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.system_name=b.system_name and upper(trim(a.system_name))<>upper(trim(b.system_name))
UNION
select  a.CRM_TABLE,'enrollment_status',a.cbs_party_id,a.enrollment_status as 'CRM_enrollment_status',b.enrollment_status as 'ODS_enrollment_status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.system_name=b.system_name and upper(trim(a.enrollment_status))<>upper(trim(b.enrollment_status))
)a order by cbs_party_id;

-- For occupation

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'occupation'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,nature_of_occupation, nature_of_occupation_code, organization, industry_type, 
industry_type_code, occupation_type, occupation_type_code, occupation_status,
occupation_status_code, date_of_commencement, monthly_income, annual_income, 
fund_source_name, fund_source_code, source_of_wealth, proof_of_sow, 
party_linked_companies, party_banks, proof_of_address, proof_of_income,
salary_period, salary_dates, proof_of_billing, profession
from occupation a INNER JOIN party b ON a.party_id = b.party_id where a.is_active= 1 AND a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'occupation'as CRM_TABLE,'ODS' as CRM,cbs_party_id,nature_of_occupation, nature_of_occupation_code, organization, industry_type, 
industry_type_code, occupation_type, occupation_type_code, occupation_status,
occupation_status_code, date_of_commencement, monthly_income, annual_income, 
fund_source_name, fund_source_code, source_of_wealth, proof_of_sow, 
party_linked_companies, party_banks, proof_of_address, proof_of_income,
salary_period, salary_dates, proof_of_billing, profession
 from ODS_occupation a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'nature_of_occupation',a.cbs_party_id,a.nature_of_occupation as 'CRM_nature_of_occupation',b.nature_of_occupation as 'ODS_nature_of_occupation'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.nature_of_occupation))<>upper(trim(b.nature_of_occupation))
UNION
select  a.CRM_TABLE,'nature_of_occupation_code',a.cbs_party_id,a.nature_of_occupation_code as 'CRM_nature_of_occupation_code',b.nature_of_occupation_code as 'ODS_nature_of_occupation_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.nature_of_occupation_code))<>upper(trim(b.nature_of_occupation_code))
UNION
select  a.CRM_TABLE,'organization',a.cbs_party_id,a.organization as 'CRM_organization',b.organization as 'ODS_organization'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.organization))<>upper(trim(b.organization))
UNION
select  a.CRM_TABLE,'industry_type',a.cbs_party_id,a.industry_type as 'CRM_industry_type',b.industry_type as 'ODS_industry_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.industry_type))<>upper(trim(b.industry_type))
UNION
select  a.CRM_TABLE,'industry_type_code',a.cbs_party_id,a.industry_type_code as 'CRM_industry_type_code',b.industry_type_code as 'ODS_industry_type_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.industry_type_code))<>upper(trim(b.industry_type_code))
UNION
select  a.CRM_TABLE,'occupation_type',a.cbs_party_id,a.occupation_type as 'CRM_occupation_type',b.occupation_type as 'ODS_occupation_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.occupation_type))<>upper(trim(b.occupation_type))
UNION
select  a.CRM_TABLE,'occupation_type_code',a.cbs_party_id,a.occupation_type_code as 'CRM_occupation_type_code',b.occupation_type_code as 'ODS_occupation_type_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.occupation_type_code))<>upper(trim(b.occupation_type_code))
UNION
select  a.CRM_TABLE,'occupation_status',a.cbs_party_id,a.occupation_status as 'CRM_occupation_status',b.occupation_status as 'ODS_occupation_status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.occupation_status))<>upper(trim(b.occupation_status))
UNION
select  a.CRM_TABLE,'occupation_status_code',a.cbs_party_id,a.occupation_status_code as 'CRM_occupation_status_code',b.occupation_status_code as 'ODS_occupation_status_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.occupation_status_code))<>upper(trim(b.occupation_status_code))
UNION
select  a.CRM_TABLE,'date_of_commencement',a.cbs_party_id,a.date_of_commencement as 'CRM_date_of_commencement',b.date_of_commencement as 'ODS_date_of_commencement'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.date_of_commencement))<>upper(trim(b.date_of_commencement))
UNION
select  a.CRM_TABLE,'monthly_income',a.cbs_party_id,a.monthly_income as 'CRM_monthly_income',b.monthly_income as 'ODS_monthly_income'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.monthly_income))<>upper(trim(b.monthly_income))
UNION
select  a.CRM_TABLE,'annual_income',a.cbs_party_id,a.annual_income as 'CRM_annual_income',b.annual_income as 'ODS_annual_income'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.annual_income))<>upper(trim(b.annual_income))
UNION
select  a.CRM_TABLE,'fund_source_name',a.cbs_party_id,a.fund_source_name as 'CRM_fund_source_name',b.fund_source_name as 'ODS_fund_source_name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.fund_source_name))<>upper(trim(b.fund_source_name))
UNION
select  a.CRM_TABLE,'fund_source_code',a.cbs_party_id,a.fund_source_code as 'CRM_fund_source_code',b.fund_source_code as 'ODS_fund_source_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.fund_source_code))<>upper(trim(b.fund_source_code))
UNION
select  a.CRM_TABLE,'source_of_wealth',a.cbs_party_id,a.source_of_wealth as 'CRM_source_of_wealth',b.source_of_wealth as 'ODS_source_of_wealth'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.source_of_wealth))<>upper(trim(b.source_of_wealth))
UNION
select  a.CRM_TABLE,'proof_of_sow',a.cbs_party_id,a.proof_of_sow as 'CRM_proof_of_sow',b.proof_of_sow as 'ODS_proof_of_sow'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.proof_of_sow))<>upper(trim(b.proof_of_sow))
UNION
select  a.CRM_TABLE,'party_linked_companies',a.cbs_party_id,a.party_linked_companies as 'CRM_party_linked_companies',b.party_linked_companies as 'ODS_party_linked_companies'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.party_linked_companies))<>upper(trim(b.party_linked_companies))
UNION
select  a.CRM_TABLE,'party_banks',a.cbs_party_id,a.party_banks as 'CRM_party_banks',b.party_banks as 'ODS_party_banks'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.party_banks))<>upper(trim(b.party_banks))
UNION
select  a.CRM_TABLE,'proof_of_address',a.cbs_party_id,a.proof_of_address as 'CRM_proof_of_address',b.proof_of_address as 'ODS_proof_of_address'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.proof_of_address))<>upper(trim(b.proof_of_address))
UNION
select  a.CRM_TABLE,'proof_of_income',a.cbs_party_id,a.proof_of_income as 'CRM_proof_of_income',b.proof_of_income as 'ODS_proof_of_income'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.proof_of_income))<>upper(trim(b.proof_of_income))
UNION
select  a.CRM_TABLE,'salary_period',a.cbs_party_id,a.salary_period as 'CRM_salary_period',b.salary_period as 'ODS_salary_period'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.salary_period))<>upper(trim(b.salary_period))
UNION
select  a.CRM_TABLE,'salary_dates',a.cbs_party_id,a.salary_dates as 'CRM_salary_dates',b.salary_dates as 'ODS_salary_dates'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.salary_dates))<>upper(trim(b.salary_dates))
UNION
select  a.CRM_TABLE,'proof_of_billing',a.cbs_party_id,a.proof_of_billing as 'CRM_proof_of_billing',b.proof_of_billing as 'ODS_proof_of_billing'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.proof_of_billing))<>upper(trim(b.proof_of_billing))
UNION
select  a.CRM_TABLE,'profession',a.cbs_party_id,a.profession as 'CRM_profession',b.profession as 'ODS_profession'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.occupation_type=b.occupation_type and upper(trim(a.profession))<>upper(trim(b.profession))
)a order by cbs_party_id;

-- For kyc_details

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'kyc_details'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id, document_id,
		document_type, issuing_authority, valid_until, national_id
from kyc_details a INNER JOIN party b ON a.party_id = b.party_id
where a.is_active= 1 AND a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'kyc_details'as CRM_TABLE,'ODS' as CRM,cbs_party_id, document_id,
		document_type, issuing_authority, valid_until, national_id
 from ODS_kyc_details a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'document_id',a.cbs_party_id,a.document_id as 'CRM_document_id',b.document_id as 'ODS_document_id'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.document_type=b.document_type and upper(trim(a.document_id))<>upper(trim(b.document_id))
UNION
select  a.CRM_TABLE,'document_type',a.cbs_party_id,a.document_type as 'CRM_document_type',b.document_type as 'ODS_document_type'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.document_id=b.document_id and upper(trim(a.document_type))<>upper(trim(b.document_type))
UNION
select  a.CRM_TABLE,'issuing_authority',a.cbs_party_id,a.issuing_authority as 'CRM_issuing_authority',b.issuing_authority as 'ODS_issuing_authority'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.document_type=b.document_type and upper(trim(a.issuing_authority))<>upper(trim(b.issuing_authority))
UNION
select  a.CRM_TABLE,'valid_until',a.cbs_party_id,a.valid_until as 'CRM_valid_until',b.valid_until as 'ODS_valid_until'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.document_type=b.document_type and a.document_id=b.document_id and upper(trim(a.valid_until))<>upper(trim(b.valid_until))
UNION
select  a.CRM_TABLE,'national_id',a.cbs_party_id,a.national_id as 'CRM_national_id',b.national_id as 'ODS_national_id'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.document_type=b.document_type and upper(trim(a.national_id))<>upper(trim(b.national_id))
)a order by cbs_party_id;

-- For asset_details

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'asset_details'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id, asset_number,
	asset_description, product_id, purchase_date, status, quantity, price,valid_upto
from asset_details a INNER JOIN party b ON a.party_id = b.party_id
where a.is_active= 1 AND a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'asset_details'as CRM_TABLE,'ODS' as CRM,cbs_party_id, asset_number,
	asset_description, product_id, purchase_date, status, quantity, price,valid_upto
 from ODS_asset_details a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'asset_number',a.cbs_party_id,a.asset_number as 'CRM_asset_number',b.asset_number as 'ODS_asset_number'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.asset_number))<>upper(trim(b.asset_number))
UNION
select  a.CRM_TABLE,'asset_description',a.cbs_party_id,a.asset_description as 'CRM_asset_description',b.asset_description as 'ODS_asset_description'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.asset_description))<>upper(trim(b.asset_description))
UNION
select  a.CRM_TABLE,'product_id',a.cbs_party_id,a.product_id as 'CRM_product_id',b.product_id as 'ODS_product_id'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.product_id))<>upper(trim(b.product_id))
UNION
select  a.CRM_TABLE,'purchase_date',a.cbs_party_id,a.purchase_date as 'CRM_purchase_date',b.purchase_date as 'ODS_purchase_date'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.purchase_date))<>upper(trim(b.purchase_date))
UNION
select  a.CRM_TABLE,'status',a.cbs_party_id,a.status as 'CRM_status',b.status as 'ODS_status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.status))<>upper(trim(b.status))
UNION
select  a.CRM_TABLE,'quantity',a.cbs_party_id,a.quantity as 'CRM_quantity',b.quantity as 'ODS_quantity'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.quantity))<>upper(trim(b.quantity))
UNION
select  a.CRM_TABLE,'price',a.cbs_party_id,a.price as 'CRM_price',b.price as 'ODS_price'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.price))<>upper(trim(b.price))
UNION
select  a.CRM_TABLE,'valid_upto',a.cbs_party_id,a.valid_upto as 'CRM_valid_upto',b.valid_upto as 'ODS_valid_upto'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.asset_number=b.asset_number and upper(trim(a.valid_upto))<>upper(trim(b.valid_upto))
)a order by cbs_party_id;

-- For device_details

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'device_details'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,device_ip, latitude,longitude
from device_details a INNER JOIN party b ON a.party_id = b.party_id
where a.is_active= 1 AND a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'device_details'as CRM_TABLE,'ODS' as CRM,cbs_party_id, device_ip, latitude,longitude
 from ODS_device_details a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'device_ip',a.cbs_party_id,a.device_ip as 'CRM_device_ip',b.device_ip as 'ODS_device_ip'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.device_ip=b.device_ip and upper(trim(a.device_ip))<>upper(trim(b.device_ip))
UNION
select  a.CRM_TABLE,'latitude',a.cbs_party_id,a.latitude as 'CRM_latitude',b.latitude as 'ODS_latitude'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.device_ip=b.device_ip and upper(trim(a.latitude))<>upper(trim(b.latitude))
UNION
select  a.CRM_TABLE,'longitude',a.cbs_party_id,a.longitude as 'CRM_longitude',b.longitude as 'ODS_longitude'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.device_ip=b.device_ip and upper(trim(a.longitude))<>upper(trim(b.longitude))
)a order by cbs_party_id;

-- For external_system_response

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'external_system_response'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,external_system_name,
external_response_details, overall_status, case_id
from external_system_response a INNER JOIN party b ON a.party_id = b.party_id
where a.is_active= 1 AND a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'external_system_response'as CRM_TABLE,'ODS' as CRM,cbs_party_id,external_system_name,
external_response_details, overall_status, case_id
 from ODS_external_system_response a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'external_system_name',a.cbs_party_id,a.external_system_name as 'CRM_external_system_name',b.external_system_name as 'ODS_external_system_name'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.external_system_name=b.external_system_name and upper(trim(a.external_system_name))<>upper(trim(b.external_system_name))
UNION
select  a.CRM_TABLE,'external_response_details',a.cbs_party_id,a.external_response_details as 'CRM_external_response_details',b.external_response_details as 'ODS_external_response_details'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.external_system_name=b.external_system_name and upper(trim(a.external_response_details))<>upper(trim(b.external_response_details))
UNION
select  a.CRM_TABLE,'overall_status',a.cbs_party_id,a.overall_status as 'CRM_overall_status',b.overall_status as 'ODS_overall_status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.external_system_name=b.external_system_name and upper(trim(a.external_response_details))<>upper(trim(b.external_response_details))
UNION
select  a.CRM_TABLE,'overall_status',a.cbs_party_id,a.overall_status as 'CRM_overall_status',b.overall_status as 'ODS_overall_status'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.external_system_name=b.external_system_name and upper(trim(a.overall_status))<>upper(trim(b.overall_status))
UNION
select  a.CRM_TABLE,'case_id',a.cbs_party_id,a.case_id as 'CRM_case_id',b.case_id as 'ODS_case_id'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where a.external_system_name=b.external_system_name and upper(trim(a.case_id))<>upper(trim(b.case_id))
)a order by cbs_party_id;

-- For Referral_promotion

INSERT INTO crm_final_rcon_tab_temp(CRM_TABLE, column_names, cbs_party_id, crm_column_data, ods_column_date)
with cte1 as
(select distinct 'referral_promotion'as CRM_TABLE,'CRM' as CRM, b.cbs_party_id,referral_code, promo_code, company_code, agent_code, ref_promo_flag
from referral_promotion a INNER JOIN party b ON a.party_id = b.party_id
where a.is_active= 1 AND a.is_latest_rec = 'Y' and  b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods)),
cte2 as (select distinct 'referral_promotion'as CRM_TABLE,'ODS' as CRM,cbs_party_id,referral_code, promo_code, company_code, agent_code, ref_promo_flag
 from ODS_referral_promotion a INNER JOIN party b ON a.party_id = b.cbs_party_id where b.cbs_party_id 
in(select distinct cbs_party_id from checksum_crm_ods))
select * from(
select  a.CRM_TABLE,'referral_code',a.cbs_party_id,a.referral_code as 'CRM_referral_code',b.referral_code as 'ODS_referral_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.referral_code))<>upper(trim(b.referral_code))
UNION
select  a.CRM_TABLE,'promo_code',a.cbs_party_id,a.promo_code as 'CRM_promo_code',b.promo_code as 'ODS_promo_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.promo_code))<>upper(trim(b.promo_code))
UNION
select  a.CRM_TABLE,'company_code',a.cbs_party_id,a.company_code as 'CRM_company_code',b.company_code as 'ODS_company_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.company_code))<>upper(trim(b.company_code))
UNION
select  a.CRM_TABLE,'agent_code',a.cbs_party_id,a.agent_code as 'CRM_agent_code',b.agent_code as 'ODS_agent_code'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.agent_code))<>upper(trim(b.agent_code))
UNION
select  a.CRM_TABLE,'ref_promo_flag',a.cbs_party_id,a.ref_promo_flag as 'CRM_ref_promo_flag',b.ref_promo_flag as 'ODS_ref_promo_flag'
from cte1  a inner join cte2 b on a.cbs_party_id=b.cbs_party_id where upper(trim(a.ref_promo_flag))<>upper(trim(b.ref_promo_flag))
)a order by cbs_party_id;

DROP TABLE IF EXISTS ods_recon_count;
CREATE TABLE ods_recon_count
SELECT 
CURRENT_TIMESTAMP AS Reconciliation_Date,
(SELECT count(distinct(Party_Id)) FROM ods_mig_clients) AS ods_mig_clients,
(SELECT count(distinct(Party_Id)) FROM ods_party) AS ods_party,
(SELECT count(distinct(Party_Id)) FROM ods_party_status) AS ods_party_status,
(SELECT count(distinct(Party_Id)) FROM ods_address) AS ods_address,
(SELECT count(distinct(Party_Id)) FROM ods_Consent_Details) AS ods_Consent_Details,
(SELECT count(distinct(Party_Id)) FROM ods_contact) AS ods_contact,
(SELECT count(distinct(Party_Id)) FROM ods_relationship) AS ods_relationship,
(SELECT count(distinct(Party_Id)) FROM ods_system_integration_status) AS ods_system_integration_status,
(SELECT count(distinct(Party_Id)) FROM ods_occupation) AS ods_occupation,
(SELECT count(distinct(Party_Id)) FROM ods_kyc_details) AS ods_kyc_details,
(SELECT count(distinct(Party_Id)) FROM ods_asset_details) AS ods_asset_details,
(SELECT count(distinct(Party_Id)) FROM ods_device_details) AS ods_device_details,
(SELECT count(distinct(Party_Id)) FROM ods_external_system_response) AS ods_external_system_response,
(SELECT count(distinct(Party_Id)) FROM ods_referral_promotion) AS ods_referral_promotion;

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

/*SET @CDATE := (SELECT CURRENT_DATE);
SET @OUTPATH := 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/';
SET @FILENAME := CONCAT(@OUTPATH, @CDATE, '.csv');
SET @`qry` := CONCAT('SELECT "CRM_TABLE", "COLUMN_NAMES", "CBS_PARTY_ID", "CRM_COLUMN_DATA", "ODS_COLUMN_DATA"
						UNION ALL SELECT * 
                        INTO OUTFILE \'', @`FILENAME`, '\' 
                        FIELDS TERMINATED BY \',\' 
                        OPTIONALLY ENCLOSED BY \'"\' 
                        LINES TERMINATED BY \'\n\' 
                      FROM `crm_final_rcon_tab_temp`');    
PREPARE `stmt` FROM @`qry`;
SET @`qry` := NULL;
EXECUTE `stmt`;
DEALLOCATE PREPARE `stmt`;

SET @CDATE := (SELECT CURRENT_DATE);
SET @OUTPATH := 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/';
SET @FILENAME := CONCAT(@OUTPATH, @CDATE, '.csv');
SET @`qry` := CONCAT('SELECT "CBS_PARTY_ID", "REC_TYPE", "STATUS", "REC_DATE"
						UNION ALL SELECT cbs_party_id, Flag, "VERIFIED", CURRENT_TIMESTAMP
                        INTO OUTFILE \'', @`FILENAME`, '\' 
                        FIELDS TERMINATED BY \',\' 
                        OPTIONALLY ENCLOSED BY \'"\' 
                        LINES TERMINATED BY \'\n\' 
                      FROM `temp_clients_count`');    
PREPARE `stmt` FROM @`qry`;
SET @`qry` := NULL;
EXECUTE `stmt`;
DEALLOCATE PREPARE `stmt`;*/

END $$
DELIMITER ;