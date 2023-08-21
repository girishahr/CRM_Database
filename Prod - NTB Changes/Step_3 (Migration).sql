/*--------------app_lead---------------*/

INSERT INTO `applicationdb`.`app_lead` (`Application_Id`, `Lead_Id`, `First_Name`, `Last_Name`, `Middle_Name`, `DOB`, `Gender`, `Salutation`, `Suffix`, `Civil_Status`, `Place_Of_Birth`, `Nationality`, `No_Of_Dependents`, `Arn_No`, `Idm_Arn_No`, `Party_Status`, `Is_DOSRI`, `Is_RPT`, `Is_FATCA`, `Party_Type`, `fatca_W9_IdType`, `fatca_W9_IdNumber`, `sssGsis`, `tinId`, `Is_Active`, `Created_Date`, `Created_By`) 
SELECT DISTINCT a.Application_Id, a.Existing_Party_Id, a.First_Name, a.Last_Name, a.Middle_Name, a.DOB, a.Gender, a.Salutation, a.Suffix, a.Civil_Status, a.Place_Of_Birth, a.Nationality, a.No_Of_Dependents, a.Arn_No, a.Idm_Arn_No, a.Party_Status, c.Is_DOSRI, c.Is_RPT, b.Is_FATCA, a.Party_Type, REPLACE(JSON_EXTRACT(b.`FATCA_Details`, "$.personalW9FormIDType"), '"', '') as fatca_W9_IdType, REPLACE(JSON_EXTRACT(b.`FATCA_Details`, "$.personalFATCAW9FormId"), '"', '') as fatca_W9_IdNumber, b.sssGsis, b.Tin_Id, a.Is_Active, a.Created_Date, a.Created_By 
FROM applicationdb_bkp.app_party a
INNER JOIN applicationdb_bkp.app_kyc_details b
INNER JOIN applicationdb_bkp.app_relationship c
ON a.Existing_Party_Id = b.Existing_Party_Id AND a.Existing_Party_Id = c.Existing_Party_Id;

/*------------app_lead_status------------*/

INSERT INTO `applicationdb`.`app_lead_status` (`Application_Id`, `Lead_Id`, `Status_Type`, `Status_Flag`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Status_Type, Status_Flag, Created_Date, Created_By FROM applicationdb_bkp.app_party_status;

/*------------app_address------------*/

INSERT INTO `applicationdb`.`app_address` (`Application_Id`, `Lead_Id`, `Address_Type`, `Number_And_Street`, `Barangay`, `City`, `State`, `Region`, `Country`, `Country_Code`, `Zip_Code`, `Is_Preferred_Address`, `Is_Active`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Address_Type, Number_And_Street, Barangay, City, State, Region, Country, Country_Code, Zip_Code, Is_Preferred_Address, Is_Active, Created_Date, Created_By FROM applicationdb_bkp.app_address;

/*------------app_consent_details------------*/

INSERT INTO `applicationdb`.`app_consent_details` (`Application_Id`, `Lead_Id`, `Consent_Type`, `Consent_Channel`, `Status`, `Consent_Details`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Consent_Type, Consent_Channel, Consent_Flag, Consent_Details, Created_Date, Created_By FROM applicationdb_bkp.app_consent_details;

/*------------app_contact------------*/

INSERT INTO `applicationdb`.`app_contact` (`Application_Id`, `Lead_Id`, `Contact_Type`, `Contact_Value`, `Is_Preferred`, `Is_Active`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Contact_Type, Contact_Value, Is_Preferred, Is_Active, Created_Date, Created_By FROM applicationdb_bkp.app_contact;

/*------------app_device_details------------*/

INSERT INTO `applicationdb`.`app_device_details` (`Application_Id`, `Lead_Id`, `Device_IP`, `Latitude`, `Longitude`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Device_IP, Latitude, Longitude, Created_Date, Created_By FROM applicationdb_bkp.app_party;

/*------------app_kyc_details------------*/

INSERT INTO `applicationdb`.`app_kyc_details` (`Application_Id`, `Lead_Id`, `Document_Id`, `Document_Type`, `National_Id`, `Zoloz_Details`, `Is_Active`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Document_Id, Document_Type, National_Id, IdMission_Details, Is_Active, CreatedDate, CreatedBy FROM applicationdb_bkp.app_kyc_details;

/*------------app_occupation------------*/

INSERT INTO `applicationdb`.`app_occupation` (`Lead_Id`, `Application_Id`, `Nature_Of_Occupation`, `Nature_Of_Occupation_Code`, `Organization`, `Industry_Type`, `Industry_Type_Code`, `Occupation_Type`, `Occupation_Type_Code`, `Occupation_Status`, `Occupation_Status_Code`, `Date_Of_Commencement`, `Monthly_Income`, `Annual_Income`, `Fund_Source_Name`, `Fund_Source_Code`, `Source_Of_Wealth`, `Proof_Of_SOW`, `Party_Linked_Companies`, `Party_Banks`, `Salary_Period`, `Salary_Dates`, `Profession`, `Company_Category_Segment`, `Is_Active`, `Created_Date`, `Created_By`)
SELECT Existing_Party_Id, Application_Id, Nature_Of_Occupation, Nature_Of_Occupation_Code, Organization, Industry_Type, Industry_Type_Code, Occupation_Type, Occupation_Type_Code, Occupation_Status, Occupation_Status_Code, IF(CASE WHEN Years THEN IFNULL(Years, NULL) END > CASE WHEN Months THEN IFNULL(Months, NULL) END, CASE WHEN Years THEN CASE WHEN IFNULL(Years, NULL) <> 0 THEN DATE_SUB((str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d') - INTERVAL IFNULL(Years, NULL) YEAR), INTERVAL DAYOFMONTH(str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d'))-1 DAY) END END, CASE WHEN Months THEN CASE WHEN IFNULL(Months, NULL) <> 0 THEN DATE_SUB((str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d') - INTERVAL IFNULL(Months, NULL) MONTH), INTERVAL DAYOFMONTH(str_to_date(LEFT(CURRENT_TIMESTAMP, 10), '%Y-%m-%d'))-1 DAY) END END) AS Date_Of_Commencement, Monthly_Income, Annual_Income, Fund_Source_Name, Fund_Source_Code, Source_Of_Wealth, Proof_Of_SOW, Party_Linked_Companies, Party_Banks,  Salary_Period, Salary_Dates, Profession, Company_Category_Segment, Is_Active, Created_Date, Created_By FROM applicationdb_bkp.app_occupation;

/*------------app_relationship------------*/

INSERT INTO `applicationdb`.`app_relationship` (`Application_Id`, `Lead_Id`, `Relationship_Type`, `Name`, `Nationality`, `DOB`, `Share_Percentage`, `Is_Nominee`, `Address`, `Created_Date`, `Created_By`)
SELECT Application_Id, Existing_Party_Id, Relationship_Type, Name, Nationality, DOB, Share_Percentage, Is_Nominee, Address, Created_Date, Created_By FROM applicationdb_bkp.app_relationship;

/*------------loan_application_details_new------------*/

INSERT INTO `loandb`.`loan_application_details_new` (`Application_Id`, `WorkFlow_Id`, `Party_Id`, `Product_Id`, `Status`, `CW_Transaction_Id`, `Mobile_Phone`, `Loan_Tenor`, `Monthly_Rate`, `Contractual_Interest_Rate`, `Installment`, `Offer_Expiry`, `Loan_Amount`, `Effective_Interest_Rate`, `Loan_Product_Key`, `Residual_EMI`, `Notes`, `Action_By`, `Loan_Status`, `Created_Date`, `Created_By`, `Updated_Date`)
SELECT Application_Id, WorkFlow_Id, Existing_Party_Id, Product_Id, Status, CW_Transaction_Id, Mobile_Phone, Loan_Tenor, Monthly_Rate, Contractual_Interest_Rate, Installment, Offer_Expiry, Loan_Amount, Effective_Interest_Rate, Loan_Product_Key, Residual_EMI, Notes, Action_By, Loan_Status, Created_Date, Created_By, Updated_Date FROM loandb.loan_application_details;

COMMIT;