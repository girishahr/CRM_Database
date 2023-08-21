/*-----------------------------------------*/
/*--------------applicationdb--------------*/
/*-----------------------------------------*/

/*--------------app_lead---------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_lead` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) NOT NULL,
  `CW_Transaction_Id` varchar(255) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
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
  `No_Of_Dependents` varchar(32) DEFAULT NULL,
  `Arn_No` varchar(32) DEFAULT NULL,
  `Idm_Arn_No` varchar(32) DEFAULT NULL,
  `Party_Status` varchar(75) DEFAULT NULL,
  `Is_DOSRI` tinyint DEFAULT NULL,
  `Is_RPT` tinyint DEFAULT NULL,
  `Is_FATCA` varchar(10) DEFAULT NULL,
  `Party_Type` varchar(30) DEFAULT NULL,
  `Preferred_Address_Id` varchar(50) DEFAULT NULL,
  `fatca_W9_IdType` varchar(100) DEFAULT NULL,
  `fatca_W9_IdNumber` varchar(100) DEFAULT NULL,
  `App_Product_Type` varchar(50) DEFAULT NULL,
  `App_Party_Type` varchar(50) DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Channel_Type` varchar(50) DEFAULT NULL,
  `Product_Type` varchar(50) DEFAULT NULL,
  `sssGsis` varchar(75) DEFAULT NULL,
  `tinId` varchar(75) DEFAULT NULL,
  `ReferralCode` varchar(50) DEFAULT NULL,
  `PromotionalCode` varchar(50) DEFAULT NULL,
  `application_stage` varchar(75) DEFAULT NULL,
  `application_status` varchar(75) DEFAULT NULL,
  `application_status_code` varchar(10) DEFAULT NULL,
  `External_Application_Number` varchar(75) DEFAULT NULL,
  `External_Application_Name` varchar(75) DEFAULT NULL,
  `Product_applied` varchar(75) DEFAULT NULL,
  `agentName` varchar(255) DEFAULT NULL,
  `agentCode` varchar(255) DEFAULT NULL,
  `Designation` varchar(100) DEFAULT NULL,
  `Is_Record_Edited` varchar(255) DEFAULT NULL,
  `my_Job` varchar(255) DEFAULT NULL,
  `my_Job_Code` varchar(255) DEFAULT NULL,
  `partner_score` varchar(1000) DEFAULT NULL,
  `partner_screening_ekyc` varchar(1000) DEFAULT NULL,
  `Is_Active` tinyint DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Updated_Date` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Id`),
  KEY `FK_Person_User_CivilStatus_idx` (`Civil_Status`),
  KEY `FK_Person_User_CustomerIdType_idx` (`Party_Type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_lead_status--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_lead_status` (
  `Status_Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Status_Type` varchar(100) NOT NULL,
  `Status_Flag` tinyint DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Status_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_address--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_address` (
  `Address_Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Address_Type` varchar(50) NOT NULL,
  `Number_And_Street` varchar(256) DEFAULT NULL,
  `Barangay` varchar(100) DEFAULT NULL,
  `LandMark` varchar(100) DEFAULT NULL,
  `Comments` varchar(100) DEFAULT NULL,
  `City` varchar(100) DEFAULT NULL,
  `State` varchar(100) DEFAULT NULL,
  `Region` varchar(100) DEFAULT NULL,
  `Country` varchar(100) DEFAULT NULL,
  `Country_Code` varchar(10) DEFAULT NULL,
  `Zip_Code` varchar(10) DEFAULT NULL,
  `Date_Since_Residing` varchar(20) DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Is_Preferred_Address` tinyint DEFAULT NULL,
  `Is_Active` tinyint DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_Rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Address_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_asset_details--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_asset_details` (
  `Asset_Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Asset_Number` varchar(30) DEFAULT NULL,
  `Asset_Description` varchar(100) DEFAULT NULL,
  `Product_Id` bigint DEFAULT NULL,
  `Status` varchar(50) DEFAULT NULL,
  `Quantity` int DEFAULT NULL,
  `Price` float DEFAULT NULL,
  `Purchase_Date` datetime DEFAULT NULL,
  `Valid_Upto` datetime DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Asset_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_consent_details--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_consent_details` (
  `Consent_Details_Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Consent_Type` varchar(50) DEFAULT NULL,
  `Consent_Capture_Source` varchar(50) DEFAULT NULL,
  `Consent_Channel` varchar(50) DEFAULT NULL,
  `Status` tinyint DEFAULT NULL,
  `Comments` varchar(100) DEFAULT NULL,
  `Consent_Details` json DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Consent_Details_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_contact--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_contact` (
  `Contact_Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Contact_Type` varchar(50) DEFAULT NULL,
  `Contact_Value` varchar(150) DEFAULT NULL,
  `Contact_Period` varchar(20) DEFAULT NULL,
  `Is_Preferred` tinyint DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(50) DEFAULT 'APP',
  `Is_Active` tinyint DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_Rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Contact_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_device_details--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_device_details` (
  `Device_id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Device_IP` varchar(15) DEFAULT NULL,
  `Latitude` varchar(50) DEFAULT NULL,
  `Longitude` varchar(50) DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Device_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_document_details--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_document_details` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `url` varchar(255) DEFAULT NULL,
  `doctype` varchar(255) DEFAULT NULL,
  `Created_Date` datetime DEFAULT NULL,
  `Created_By` varchar(50) DEFAULT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_kyc_details--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_kyc_details` (
  `KYC_Details_Id` int NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Document_Id` varchar(50) DEFAULT NULL,
  `Document_Type` varchar(50) DEFAULT NULL,
  `Issuing_Authority` varchar(100) DEFAULT NULL,
  `Valid_Until` varchar(20) DEFAULT NULL,
  `National_Id` varchar(75) DEFAULT NULL,
  /*`Zoloz_Details` json DEFAULT NULL,*/
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Is_Active` tinyint DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`KYC_Details_Id`),
  KEY `FK_KYCHighRisk_Person_idx` (`Lead_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_occupation--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_occupation` (
  `Occupation_Id` bigint NOT NULL AUTO_INCREMENT,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Application_Id` varchar(36) DEFAULT NULL,
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
  `Proof_Of_Billing` varchar(100) DEFAULT NULL,
  `Proof_Of_Income` varchar(50) DEFAULT NULL,
  `Salary_Period` varchar(50) DEFAULT NULL,
  `Salary_Dates` varchar(50) DEFAULT NULL,
  `Profession` varchar(100) DEFAULT NULL,
  `Company_Category_Segment` varchar(50) DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Is_Active` tinyint DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Occupation_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_referral_promotion--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_referral_promotion` (
  `Id` bigint NOT NULL AUTO_INCREMENT,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Code` varchar(50) DEFAULT NULL,
  `Code_Type` varchar(50) DEFAULT NULL,
  `Source_Type` varchar(200) DEFAULT NULL,
  `Source_Code` varchar(50) DEFAULT NULL,
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*--------------app_relationship--------------*/

CREATE TABLE IF NOT EXISTS `applicationdb`.`app_relationship` (
  `Relationship_Id` int NOT NULL AUTO_INCREMENT,
  `Application_Id` varchar(36) DEFAULT NULL,
  `Lead_Id` bigint(16) unsigned zerofill NOT NULL,
  `Relationship_Type` varchar(30) DEFAULT NULL,
  `Name` varchar(152) DEFAULT NULL,
  `Nationality` varchar(100) DEFAULT NULL,
  `DOB` date DEFAULT NULL,
  `Share_Percentage` varchar(10) DEFAULT NULL,
  `Is_Nominee` varchar(1) DEFAULT NULL,
  `Nominee_Index` varchar(1) DEFAULT NULL,
  `Address` json DEFAULT NULL,
  `Source` varchar(50) DEFAULT 'IEXCEED',
  `Channel` varchar(100) DEFAULT 'APP',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Is_Latest_rec` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Relationship_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/*-----------------------------------------*/
/*-----------------loandb------------------*/
/*-----------------------------------------*/

/*--------------loan_application_details_new--------------*/

CREATE TABLE `loandb`.`loan_application_details_new` (
  `Application_Id` varchar(36) NOT NULL,
  `WorkFlow_Id` varchar(36) NOT NULL,
  `External_Application_Number` varchar(255) DEFAULT NULL,
  `Source` varchar(50) NOT NULL DEFAULT 'IEXCEED',
  `Channel` varchar(50) DEFAULT 'APP',
  `Party_Id` bigint(10) unsigned zerofill NOT NULL,
  `Product_Id` varchar(30) DEFAULT NULL,
  `Status` varchar(50) NOT NULL COMMENT 'Underwiitng status',
  `CW_Transaction_Id` varchar(255) NOT NULL,
  `Mobile_Phone` varchar(255) DEFAULT NULL,
  `Loan_Tenor` bigint DEFAULT NULL,
  `Monthly_Rate` double DEFAULT NULL,
  `Contractual_Interest_Rate` double DEFAULT NULL,
  `Installment` double DEFAULT NULL,
  `Offer_Expiry` varchar(30) DEFAULT NULL,
  `Loan_Amount` double DEFAULT NULL,
  `Effective_Interest_Rate` double DEFAULT NULL,
  `Loan_Product_Key` varchar(50) DEFAULT NULL,
  `Residual_EMI` double DEFAULT NULL,
  `Notes` varchar(255) DEFAULT NULL,
  `Action_By` varchar(30) DEFAULT NULL,
  `Partnership` varchar(100) DEFAULT NULL,
  `PromotionalCode` varchar(100) DEFAULT NULL,
  `ReferralCode` varchar(50) DEFAULT NULL,
  `Loan_Status` varchar(30) DEFAULT NULL COMMENT 'Loan status(DPD)',
  `Created_Date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) NOT NULL,
  `Updated_Date` datetime DEFAULT NULL,
  PRIMARY KEY (`Application_Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

COMMIT;