SET SQL_SAFE_UPDATES=0;

--
-- CREATE Table structure for `address`
--

DROP TABLE IF EXISTS `address`;
CREATE TABLE `address` (
  `Address_Id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Reference to the Address ID for which this entry is logged.\\n',
  `Party_Id` bigint(10) unsigned zerofill NOT NULL COMMENT 'Reference to the party ID for which this entry is logged.',
  `Address_Type` varchar(50) NOT NULL COMMENT 'Type of address',
  `Number_And_Street` varchar(100) DEFAULT NULL COMMENT 'The street and house number of the acceptor.',
  `Barangay` varchar(100) DEFAULT NULL COMMENT 'Administrative district forming the most local level of government.',
  `LandMark` varchar(100) DEFAULT NULL COMMENT 'LandMark',
  `Comments` varchar(100) DEFAULT NULL COMMENT 'Comments',
  `City` varchar(100) DEFAULT NULL COMMENT 'City',
  `State` varchar(100) DEFAULT NULL COMMENT 'State',
  `Region` varchar(100) DEFAULT NULL COMMENT 'Region',
  `Country` varchar(100) DEFAULT NULL COMMENT 'Country',
  `Country_Code` varchar(20) DEFAULT NULL COMMENT 'Code for Country',
  `Zip_Code` varchar(10) DEFAULT '0' COMMENT 'zip code',
  `Nom_Index` varchar(30) DEFAULT NULL,
  `Date_Since_Residing` varchar(20) DEFAULT NULL COMMENT 'Date Since Residing in current Address',
  `Is_Preferred_Address` tinyint DEFAULT NULL COMMENT 'Is prefereable address',
  `Province` varchar(100) DEFAULT NULL,
  `Is_Active` tinyint NOT NULL DEFAULT '1' COMMENT 'Active status',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Record Created Date',
  `Created_By` varchar(50) NOT NULL COMMENT 'User created By',
  `Is_Latest_Rec` varchar(1) DEFAULT 'N' COMMENT 'Latest Record ',
  PRIMARY KEY (`Address_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `card_details`
--

DROP TABLE IF EXISTS `card_details`;
CREATE TABLE `card_details` (
  `Card_Details_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Product_Type` varchar(50) NOT NULL,
  `Card_type` varchar(50) NOT NULL,
  `Issue_Date` date NOT NULL,
  `Status` varchar(50) NOT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`Card_Details_Id`),
  UNIQUE KEY `Card_Details_Id_UNIQUE` (`Card_Details_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `consent_details`
--

DROP TABLE IF EXISTS `consent_details`;
CREATE TABLE `consent_details` (
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
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`Consent_Details_Id`),
  UNIQUE KEY `Consent_Details_Id_UNIQUE` (`Consent_Details_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `contact`
--

DROP TABLE IF EXISTS `contact`;
CREATE TABLE `contact` (
  `Contact_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `Contact_Type` varchar(50) NOT NULL,
  `Contact_Value` varchar(150) NOT NULL,
  `Contact_Period` varchar(20) DEFAULT NULL,
  `Is_Preferred` tinyint DEFAULT NULL,
  `Is_Active` tinyint NOT NULL DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`Contact_Id`),
  UNIQUE KEY `ContactId_UNIQUE` (`Contact_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `customer_audit_details`
--

DROP TABLE IF EXISTS `customer_audit_details`;
CREATE TABLE `customer_audit_details` (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Unique ID',
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `CBS_party_id` varchar(10) DEFAULT NULL,
  `Details` longtext COMMENT '''This is the action that gets displayed on screen',
  `Change_log` json NOT NULL COMMENT 'Store change informations:first_name old_value:XYZ New Value:ABCD ,Table_name:Party',
  `Actions` varchar(25) NOT NULL COMMENT 'Customer_Audit should hold the changes happened to the customer. We should update old audit history with new audit of the Case to Case_Audit.(WHO,WHAT and When) ',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='Audit Table ';

--
-- CREATE Table structure for `device_details`
--

DROP TABLE IF EXISTS `device_details`;
CREATE TABLE `device_details` (
  `Device_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Device_IP` varchar(35) NOT NULL,
  `Latitude` decimal(10,0) DEFAULT NULL,
  `Longitude` decimal(10,0) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`Device_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `external_system_response`
--

DROP TABLE IF EXISTS `external_system_response`;
CREATE TABLE `external_system_response` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `External_System_Name` varchar(50) NOT NULL,
  `External_Response_Details` json DEFAULT NULL,
  `Overall_Status` varchar(100) DEFAULT NULL,
  `Case_Id` varchar(100) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `Consent_Details_Id_UNIQUE` (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `kyc_details`
--

DROP TABLE IF EXISTS `kyc_details`;
CREATE TABLE `kyc_details` (
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
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`KYC_Details_Id`),
  KEY `FK_KYCHighRisk_Person_idx` (`Party_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `occupation`
--

DROP TABLE IF EXISTS `occupation`;
CREATE TABLE `occupation` (
  `Occupation_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `Nature_Of_Occupation` varchar(100) DEFAULT NULL,
  `Nature_Of_Occupation_Code` varchar(32) DEFAULT NULL,
  `Designation` varchar(200) DEFAULT NULL COMMENT 'To store the designation of the customer',
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
  `Is_Active` tinyint NOT NULL DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`Occupation_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `party`
--

DROP TABLE IF EXISTS `party`;
CREATE TABLE `party` (
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
  `No_Of_Dependents` varchar(75) DEFAULT NULL,
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
  `Card_Issuance_Status` varchar(10) DEFAULT NULL,
  `Is_Active` tinyint NOT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Approved_Date` datetime DEFAULT NULL,
  `Activation_Date` datetime DEFAULT NULL,
  `Updated_Date` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`Row_Id`),
  KEY `FK_Person_User_CivilStatus_idx` (`Civil_Status`),
  KEY `FK_Person_User_CustomerIdType_idx` (`Party_Type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `party_status`
--

DROP TABLE IF EXISTS `party_status`;
CREATE TABLE `party_status` (
  `Status_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `CBS_party_id` varchar(10) DEFAULT NULL,
  `Status_Type` varchar(100) NOT NULL,
  `Status_Flag` tinyint DEFAULT '0',
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`Status_Id`),
  UNIQUE KEY `Status_Id_UNIQUE` (`Status_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `referral_promotion`
--

DROP TABLE IF EXISTS `referral_promotion`;
CREATE TABLE `referral_promotion` (
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
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`Id`,`Party_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `referral_promotion_master`
--

DROP TABLE IF EXISTS `referral_promotion_master`;
CREATE TABLE `referral_promotion_master` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Onboarding_Code` varchar(50) DEFAULT NULL,
  `Code_Type` varchar(50) DEFAULT NULL,
  `Partner_Name` varchar(200) DEFAULT NULL,
  `Valid_Untill` varchar(50) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT '1',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `relationship`
--

DROP TABLE IF EXISTS `relationship`;
CREATE TABLE `relationship` (
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
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`Relationship_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `system_integration_status`
--

DROP TABLE IF EXISTS `system_integration_status`;
CREATE TABLE `system_integration_status` (
  `SIS_Id` bigint NOT NULL AUTO_INCREMENT,
  `Party_Id` bigint(10) unsigned zerofill DEFAULT NULL,
  `System_Name` varchar(100) NOT NULL,
  `Enrollment_Status` varchar(10) NOT NULL DEFAULT 'P',
  `Is_Active` tinyint DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`SIS_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `agent_notes`
--

DROP TABLE IF EXISTS `agent_notes`;
CREATE TABLE `agent_notes` (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT 'It is a serial number auto matically generated.',
  `Party_Id` varchar(50) DEFAULT NULL COMMENT 'Notes are created for a specific customer. This points to row_id of the customer',
  `Parent_Note_Id` varchar(50) DEFAULT NULL COMMENT 'Child notes can be created for a parent note.',
  `Category` varchar(200) DEFAULT NULL COMMENT 'Category of the note',
  `Sub_Category` varchar(200) DEFAULT NULL COMMENT 'Sub Category of the note',
  `Channel` varchar(200) DEFAULT NULL COMMENT 'Channel through which the customer contacts the agent',
  `Note` varchar(4000) NOT NULL COMMENT 'Comment added by the agent',
  `Created_Date` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Created Date',
  `Created_By` varchar(50) DEFAULT NULL COMMENT 'Name of the agent',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `asset_details`
--

DROP TABLE IF EXISTS `asset_details`;
CREATE TABLE `asset_details` (
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
  `Is_Latest_rec` varchar(1) NOT NULL DEFAULT 'N',
  PRIMARY KEY (`Asset_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `average_daily_balance`
--

DROP TABLE IF EXISTS `average_daily_balance`;
CREATE TABLE `average_daily_balance` (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Unique Id generation',
  `Client_Id` varchar(30) DEFAULT NULL COMMENT 'Customer ID',
  `As_On_Date` date DEFAULT NULL COMMENT 'As on Date',
  `Avg_Daily_Balance` decimal(15,2) DEFAULT NULL COMMENT 'Average Daily Balance',
  `Created_By` varchar(50) DEFAULT NULL COMMENT 'Created By',
  `Created_On` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Created Date',
  PRIMARY KEY (`Id`),
  KEY `idx_average_daily_balance_Client_Id` (`Client_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `average_daily_balance_history`
--

DROP TABLE IF EXISTS `average_daily_balance_history`;
CREATE TABLE `average_daily_balance_history` (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Unique Id generation',
  `Client_Id` varchar(30) DEFAULT NULL COMMENT 'Customer ID',
  `As_On_Date` date DEFAULT NULL COMMENT 'As on Date',
  `Avg_Daily_Balance` decimal(15,2) DEFAULT NULL COMMENT 'Average Daily Balance',
  `Created_By` varchar(50) DEFAULT NULL COMMENT 'Created By',
  `Created_On` datetime DEFAULT CURRENT_TIMESTAMP COMMENT 'Created Date',
  PRIMARY KEY (`Id`),
  KEY `idx_average_daily_balance_history_Client_Id` (`Client_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `customer_one_master`
--

DROP TABLE IF EXISTS `customer_one_master`;
CREATE TABLE `customer_one_master` (
  `Module` varchar(50) NOT NULL,
  `Module_Type` varchar(50) NOT NULL,
  `Module_Value` varchar(100) DEFAULT NULL,
  `Module_Code` varchar(100) DEFAULT NULL,
  `Module_Description` varchar(500) DEFAULT '',
  `Module_Parent_Code` varchar(100) DEFAULT NULL,
  `Is_Active` varchar(1) NOT NULL,
  `Order_Num` int NOT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`Module_Type`,`Order_Num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `customer_party_status`
--

DROP TABLE IF EXISTS `customer_party_status`;
CREATE TABLE `customer_party_status` (
  `Status_Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) NOT NULL,
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Status_Type` varchar(45) DEFAULT NULL,
  `Status_Flag` tinyint DEFAULT NULL,
  `Status_Details` json DEFAULT NULL,
  `Created_Date` datetime NOT NULL,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'N',
  PRIMARY KEY (`Status_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `party_matrix`
--

DROP TABLE IF EXISTS `party_matrix`;
CREATE TABLE `party_matrix` (
  `hdr_id` bigint NOT NULL COMMENT 'Format:time in milliseconds:1675928701578',
  `party_id` bigint(10) unsigned zerofill NOT NULL,
  `previous_hdr_id` bigint DEFAULT NULL,
  `Created_By` varchar(50) NOT NULL DEFAULT 'Admin',
  `Created_Date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`hdr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `party_matrix_details`
--

DROP TABLE IF EXISTS `party_matrix_details`;
CREATE TABLE `party_matrix_details` (
  `hdr_detail_id` bigint(20) unsigned zerofill NOT NULL AUTO_INCREMENT,
  `hdr_id` bigint NOT NULL COMMENT 'party_matrix_header',
  `table_name` varchar(50) NOT NULL COMMENT 'value such as occupation, kyc_details, etc',
  `old_id` bigint DEFAULT NULL COMMENT 'value from id field of corresponding table\n',
  `new_id` bigint NOT NULL COMMENT 'value from id field of corresponding table',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) DEFAULT 'Admin',
  PRIMARY KEY (`hdr_detail_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- CREATE Table structure for `product_details`
--

DROP TABLE IF EXISTS `product_details`;
CREATE TABLE `product_details` (
  `Product_Id` bigint NOT NULL AUTO_INCREMENT,
  `Product_Code` varchar(30) NOT NULL,
  `Product_Name` varchar(50) NOT NULL,
  `Product_Description` varchar(200) NOT NULL,
  `Product_Start_Date` datetime NOT NULL,
  `Product_End_Date` datetime NOT NULL,
  `Created_Date` datetime NOT NULL,
  `Created_By` varchar(45) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`Product_Id`),
  UNIQUE KEY `Product_Code_UNIQUE` (`Product_Code`),
  UNIQUE KEY `Product_Name_UNIQUE` (`Product_Name`),
  UNIQUE KEY `Product_Description_UNIQUE` (`Product_Description`),
  UNIQUE KEY `Product_Id_UNIQUE` (`Product_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

