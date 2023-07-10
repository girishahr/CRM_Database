SET SQL_SAFE_UPDATES=0;

--
-- ALTER Table for `app_user_roles`
--

ALTER TABLE `user_access_management`.`app_user_roles` 
ADD COLUMN `Is_Active` VARCHAR(1) NULL DEFAULT 'Y' AFTER `Reporting_Manager_User_Id`;

--
-- INSERT Table data for `app_user_roles`
--

INSERT INTO `user_access_management`.`app_user_roles` (`User_Id`,`User_Name`,`Role`,`Department`,`Email_Address`,`Reporting_Manager_User_Id`,`Is_Active`)
values ('shruthi.rao@uno.bank','shruthi rao','IT_Support_Officer','Tech','shruthi.rao@uno.bank','abhik.dalal@uno.bank','Y');

INSERT INTO `user_access_management`.`app_user_roles` (`User_Id`,`User_Name`,`Role`,`Department`,`Email_Address`,`Is_Active`)
values ('abhik.dalal@uno.bank','abhik.dalal','IT_Manager','Tech','abhik.dalal@uno.bank','Y');

--
-- ALTER Table for `app_roles_permission`
--

ALTER TABLE `user_access_management`.`app_roles_permission` 
ADD COLUMN `Updated_By` VARCHAR(50) NULL AFTER `Created_On`,
ADD COLUMN `Updated_On` DATETIME NULL AFTER `Updated_By`;

--
-- DELETE Table data for `app_roles_permission`
--

DELETE FROM `user_access_management`.`app_roles_permission` WHERE ID IN (1, 15, 16, 17, 25, 34, 35, 36, 50, 51, 52, 68, 69, 70, 84, 85, 86, 98, 99, 100, 113, 114, 115, 248, 249);

--
-- UPDATE Table data for `app_roles_permission`
--

UPDATE `user_access_management`.`app_roles_permission` SET `Allow_Create` = 'Y' WHERE ID IN (38);
UPDATE `user_access_management`.`app_roles_permission` SET `Allow_Create` = 'N' WHERE ID IN (44);
UPDATE `user_access_management`.`app_roles_permission` SET `Allow_Close` = 'Y' WHERE ID IN (22, 41);
UPDATE `user_access_management`.`app_roles_permission` SET `Is_Active` = 'Y' WHERE ID IN (253);

--
-- INSERT Table data for `app_roles_permission`
--

INSERT INTO `user_access_management`.`app_roles_permission` (`Role`,`Module`,`SubModule`,`SubSubModule`,`Allow_Create`,`Allow_Read`,`Allow_Update`,`Allow_Close`,`Allow_Approve`,`Allow_Reassign`,`Created_By`,`Created_On`,`Updated_By`,`Updated_On`,`Is_Active`) VALUES 
('Contact_Center_Officer','Case','Inbox_General',NULL,'N','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Case','Inbox_General',NULL,'Y','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Customer','','','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Inbox','Onboarding','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Inbox','FATCA','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Internal','QA','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','eKYC_Pending','','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Complaints','','Y','Y','Y','N','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Disputes','','Y','Y','Y','N','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Service_Request','','Y','Y','Y','N','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Inbox_General','','N','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Task','','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Make_Deposit_Withdrawal','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Apply_Account_Fees_Cases','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Apply_Accured_Interest_Cases','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE','Y','Y','N','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_REJECT','Y','Y','N','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_WITHDRAW','Y','Y','N','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Update_Customer','Demography','','N','Y','N','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Update_Customer','Occupation_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Update_Customer','Contact_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Update_Customer','AML_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Update_Customer','Address_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Case','eKYC_Pending','','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Update_Customer','Demography','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Update_Customer','Occupation_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Update_Customer','Contact_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Update_Customer','AML_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Update_Customer','Address_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Update_Customer','Demography','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Update_Customer','Occupation_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Update_Customer','Contact_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Update_Customer','AML_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Update_Customer','Address_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Case','eKYC_Pending','','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Case','eKYC_Pending','','Y','Y','Y','N','N','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','Demography','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','Occupation_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','Contact_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','AML_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','Address_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','Demography','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','Occupation_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','Contact_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','AML_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','Address_Details','','N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Case','eKYC_Pending','','Y','Y','Y','N','N','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Case','Inbox_General','','Y','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Update_Customer','Demography','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Update_Customer','Occupation_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Update_Customer','Contact_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Update_Customer','AML_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Update_Customer','Address_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Case','eKYC_Pending','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Case','Inbox_General','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Update_Customer','Demography','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Update_Customer','Occupation_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Update_Customer','Contact_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Update_Customer','AML_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Update_Customer','Address_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Case','eKYC_Pending','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Case','Inbox_General','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Update_Customer','Demography','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Update_Customer','Occupation_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Update_Customer','Contact_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Update_Customer','AML_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Update_Customer','Address_Details','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Case','eKYC_Pending','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Case','Inbox_General','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Customer','',NULL,'N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNLOCK','Y','Y','N','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Update_Customer_Cases',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Update_Customer_Cases',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Ops','Update_Customer_Cases',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Ops','Update_Customer_Cases',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Update_Customer','Consent','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Update_Customer','Consent',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Update_Customer','Consent',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','Consent',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','Consent',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Update_Customer','Consent',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Update_Customer','Consent',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Update_Customer','Consent',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Update_Customer','Client_Status',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Update_Customer','Client_Status',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Agent','Document','','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','KYC','ID Document','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','KYC','Proof of Address Document','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','KYC','Source of Wealth Document','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','KYC','Supporting Documents','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','KYC','Bank CDD Documents','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','Customer Lifecycle','Bank Certifications','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','Customer Lifecycle','Customer Letter','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','Savings','Savings Account Certificate','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','Time Deposit','Time Deposit Certificate','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Officer','Document','Savings','Statement of Account','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','KYC','ID Document','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','KYC','Proof of Address Document','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','KYC','Source of Wealth Document','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','KYC','Supporting Documents','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','KYC','Bank CDD Documents','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','Customer Lifecycle','Bank Certifications','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','Customer Lifecycle','Customer Letter','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','Savings','Savings Account Certificate','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','Time Deposit','Time Deposit Certificate','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Document','Savings','Statement of Account','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','KYC','ID Document','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','KYC','Proof of Address Document','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','KYC','Source of Wealth Document','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','KYC','Supporting Documents','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','KYC','Bank CDD Documents','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Customer Lifecycle','Bank Certifications','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Customer Lifecycle','Customer Letter','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Savings','Savings Account Certificate','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Time Deposit','Time Deposit Certificate','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Time Deposit','Statement of Account','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Savings','Statement of Account','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Dispute and Chargeback','Transaction Receipt','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Dispute and Chargeback','Sales slip','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Operations_Manager','Document','Cards','Transaction Certification','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Document','KYC','ID Document','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Document','KYC','Proof of Address Document','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Document','KYC','Source of Wealth Document','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Document','KYC','Supporting Documents','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('KYC_Officer','Document','KYC','Bank CDD Documents','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Savings','Savings Account Certificate','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Time Deposit','Time Deposit Certificate','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Time Deposit','Statement of Account','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Savings','Statement of Account','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Dispute and Chargeback','Transaction Receipt','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Dispute and Chargeback','Sales slip','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Settlement_Officer','Document','Cards','Transaction Certification','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Document','Dispute and Chargeback','Transaction Receipt','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Document','Dispute and Chargeback','Sales slip','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Reconciliation_Officer','Document','Cards','Transaction Certification','N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Savings','Savings Account Certificate','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Time Deposit','Time Deposit Certificate','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Time Deposit','Statement of Account','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Savings','Statement of Account','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Dispute and Chargeback','Transaction Receipt','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Dispute and Chargeback','Sales slip','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Chargeback_Officer','Document','Cards','Transaction Certification','Y','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Ops','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Case','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Task','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Update_Customer','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Document','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Roles_Access','User_Profile',NULL,'N','Y','N','Y','Y','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Roles_Access','User_Role',NULL,'N','Y','N','Y','Y','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Roles_Access','Roles_and_Permission',NULL,'N','Y','N','Y','Y','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Customer','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Case','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Ops','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Task','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Update_Customer','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Document','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Roles_Access','User_Profile',NULL,'N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Roles_Access','User_Role',NULL,'N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Security_Manager','Roles_Access','Roles_and_Permission',NULL,'N','Y','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Customer','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Case','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Ops','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Task','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Update_Customer','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Document','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Roles_Access','User_Profile',NULL,'Y','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Roles_Access','User_Role',NULL,'Y','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Support_Officer','Roles_Access','Roles_and_Permission',NULL,'Y','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('IT_Manager','Customer','',NULL,'N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Ops','Update_Customer_Cases',NULL,'N','Y','Y','Y','Y','Y','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Inbox_General',NULL,'N','Y','Y','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y'),
('Contact_Center_Manager','Task','','','N','N','N','N','N','N','Admin',CURRENT_TIMESTAMP,NULL,NULL,'Y');

--
-- DELETE Table data for `app_roles_queues`
--

DELETE FROM `user_access_management`.`app_roles_queues` WHERE `Role` IN ('Admin', 'Admin 01');

--
-- INSERT Table structure for `app_roles_queues`
--

INSERT INTO `user_access_management`.`app_roles_queues` (`Role`,`QueueName`,`Module`,`SubModule`,`Created_By`,`Is_Active`) 
VALUES ('Contact_Center_Agent','Contact Centre','','','Admin','Y');

--
-- DROP Table structure for `uam_list_of_value`
--

DROP TABLE `user_access_management`.`uam_list_of_value`;

--
-- CREATE Table structure for `uam_list_of_value`
--

CREATE TABLE `user_access_management`.`uam_list_of_value` (
  `Id` bigint NOT NULL AUTO_INCREMENT COMMENT 'Unique serial number',
  `Role_Name` varchar(255) NOT NULL COMMENT 'Role Name',
  `Module` varchar(75) NOT NULL,
  `Sub_Module` varchar(75) DEFAULT NULL,
  `LOV` varchar(45) DEFAULT NULL,
  `Created_On` datetime DEFAULT CURRENT_TIMESTAMP,
  `Created_By` varchar(50) DEFAULT NULL,
  `Updated_Date` datetime DEFAULT NULL,
  `Updated_By` varchar(50) DEFAULT NULL,
  `Is_Active` varchar(1) DEFAULT 'Y',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='UAM_LIST_OF_VALUE';

--
-- INSERT Table structure for `uam_list_of_value`
--

INSERT INTO `user_access_management`.`uam_list_of_value` (`Role_Name`,`Module`,`Sub_Module`,`LOV`,`Created_On`,`Created_By`,`Updated_Date`,`Updated_By`,`Is_Active`) VALUES 
('Contact_Center_Officer','Case','Type','Complaints','2022-12-21 21:03:23','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Case','Type','Disputes','2022-12-21 21:03:24','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Case','Type','Service_Request','2022-12-21 21:03:24','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Case','Type','Inbox','2022-12-21 21:03:25','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Case','Category','FATCA','2022-12-21 21:03:25','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE','2022-12-21 21:03:26','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_REJECT','2022-12-21 21:03:26','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_WITHDRAW','2022-12-21 21:03:27','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Type','Complaints','2022-12-21 21:03:27','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Type','Disputes','2022-12-21 21:03:28','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Type','Service_Request','2022-12-21 21:03:28','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Type','Inbox','2022-12-21 21:03:29','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Category','FATCA','2022-12-21 21:03:29','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE','2022-12-21 21:03:30','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_REJECT','2022-12-21 21:03:30','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_WITHDRAW','2022-12-21 21:03:31','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','LOCK','2022-12-21 21:03:31','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNLOCK','2022-12-21 21:03:32','Admin',NULL,NULL,'Y'),
('KYC_Officer','Case','Type','Inbox','2022-12-21 21:03:32','Admin',NULL,NULL,'Y'),
('KYC_Officer','Case','Category','FATCA','2022-12-21 21:03:33','Admin',NULL,NULL,'Y'),
('KYC_Officer','Case','Category','Onboarding','2022-12-21 21:03:33','Admin',NULL,NULL,'Y'),
('KYC_Officer','Case','Type','Service_Request','2022-12-21 21:03:34','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE','2022-12-21 21:03:34','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_REJECT','2022-12-21 21:03:35','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_WITHDRAW','2022-12-21 21:03:35','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','APPROVE','2022-12-21 21:03:36','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNDO_APPROVE','2022-12-21 21:03:36','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Case','Type','Service_Request','2022-12-21 21:03:37','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Ops','Make_Deposit_Withdrawal','Make_Deposit','2022-12-21 21:03:37','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Ops','Make_Deposit_Withdrawal','Make_Withdrawal','2022-12-21 21:03:38','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','LOCK','2022-12-21 21:03:38','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNLOCK','2022-12-21 21:03:39','Admin',NULL,NULL,'Y'),
('Reconciliation_Officer','Case','Type','Service_Request','2022-12-21 21:03:39','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Case','Type','Service_Request','2022-12-21 21:03:40','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Ops','Make_Deposit_Withdrawal','Make_Deposit','2022-12-21 21:03:40','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Ops','Make_Deposit_Withdrawal','Make_Withdrawal','2022-12-21 21:03:41','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Type','Inbox','2022-12-21 21:03:41','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Category','FATCA','2022-12-21 21:03:42','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Category','Onboarding','2022-12-21 21:03:42','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Type','Service_Request','2022-12-21 21:03:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Make_Deposit_Withdrawal','Make_Deposit','2022-12-21 21:03:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Make_Deposit_Withdrawal','Make_Withdrawal','2022-12-21 21:03:44','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE','2022-12-21 21:03:44','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_REJECT','2022-12-21 21:03:45','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_WITHDRAW','2022-12-21 21:03:45','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','APPROVE','2022-12-21 21:03:46','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNDO_APPROVE','2022-12-21 21:03:46','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','LOCK','2022-12-21 21:03:47','Admin',NULL,NULL,'Y'),
('Operations_Manager','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNLOCK','2022-12-21 21:03:47','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Case_Assignment','All_Cases','2023-01-05 21:03:47','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Case_Assignment','Team_Cases','2023-01-05 21:03:48','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Case','Case_Assignment','Team_Cases','2023-01-05 21:03:49','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNLOCK','2022-02-06 21:03:34','Admin',NULL,NULL,'Y'),
('KYC_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','LOCK','2022-02-06 21:03:34','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','LOCK','2023-03-02 16:52:39','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Ops','Approve_Close_Lock_Unlock_Account_Cases','UNLOCK','2023-03-02 16:52:39','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Type','Complaints','2023-03-02 16:52:40','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Type','Disputes','2023-03-02 16:52:40','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Type','Service_Request','2023-03-02 16:52:41','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Type','Inbox','2023-03-02 16:52:41','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Case','Category','FATCA','2023-03-02 16:52:42','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE','2023-03-02 16:52:42','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_REJECT','2023-03-02 16:52:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Ops','Approve_Close_Lock_Unlock_Account_Cases','CLOSE_WITHDRAW','2023-03-02 16:52:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','First Name','2023-03-02 16:52:52','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Middle Name','2023-03-02 16:52:56','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Last Name','2023-03-02 16:52:57','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Date of Birth','2023-03-02 16:52:57','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Gender','2023-03-02 16:52:58','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Civil Status','2023-03-02 16:52:58','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Place of Birth','2023-03-02 16:52:59','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','Nationality','2023-03-02 16:52:59','Admin',NULL,NULL,'Y'),
('Contact_Center_Agent','Update Customer','Demography','FATCA STATUS','2023-03-02 16:53:01','Admin',NULL,NULL,'Y'),
('KYC_Officer','Case','Type','eKYC_Pending','2023-03-02 16:53:01','Admin',NULL,NULL,'Y'),
('KYC_Officer','Case','Type','Inbox_General','2023-03-02 16:53:02','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Type','eKYC_Pending','2023-03-02 16:53:02','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Type','Inbox_General','2023-03-02 16:53:03','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Type','Complaints','2023-03-02 16:53:03','Admin',NULL,NULL,'Y'),
('Operations_Manager','Case','Type','Disputes','2023-03-02 16:53:04','Admin',NULL,NULL,'Y'),
('Settlement Officer','Role','Everyday Banking','Settlement_Officer','2023-04-20 18:02:48','Admin','2023-05-08 14:49:15','shruthi.rao@uno.bank','Y'),
('Contact Center Agent','Role','Human Channels','Contact_Center_Agent','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Contact Center Officer','Role','Human Channels','Contact_Center_Officer','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Contact Center Manager','Role','Human Channels','Contact_Center_Manager','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Operations Manager','Role','COO','Operations_Manager','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('KYC Officer','Role','KYC','KYC_Officer','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Reconciliation Officer','Role','Everyday Banking','Reconciliation_Officer','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Chargeback Officer','Role','Everyday Banking','Chargeback_Officer','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Human Channels','Department','Name','Human Channels','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Everyday Banking','Department','Name','Everyday Banking','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('COO','Department','Name','COO','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Tech','Department','Name','Tech','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('KYC','Department','Name','KYC','2023-04-20 18:02:48','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Folder Name','','KYC','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Folder Name','','Customer Lifecycle','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Folder Name','','KYC','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Folder Name','','Customer Lifecycle','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Folder Name','','KYC','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Folder Name','','Customer Lifecycle','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Folder Name','','Savings','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Folder Name','','Time Deposit','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Folder Name','','Dispute and Chargeback','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Folder Name','','Cards','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('KYC_Officer','Folder Name','','KYC','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Folder Name','','Savings','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Folder Name','','Time Deposit','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Folder Name','','Dispute and Chargeback','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Folder Name','','Cards','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Folder Name','','Savings','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Folder Name','','Time Deposit','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Folder Name','','Dispute and Chargeback','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Folder Name','','Cards','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Document Type','KYC','Supporting Documents','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Document Type','Customer Lifecycle','Bank Certifications','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Officer','Document Type','Customer Lifecycle','Customer Letter','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Document Type','KYC','Supporting Documents','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Document Type','Customer Lifecycle','Bank Certifications','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Contact_Center_Manager','Document Type','Customer Lifecycle','Customer Letter','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','KYC','ID Document','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','KYC','Proof of Address Document','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','KYC','Source of Wealth Document','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','KYC','Supporting Documents','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','KYC','Bank CDD Documents','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Customer Lifecycle','Bank Certifications','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Customer Lifecycle','Customer Letter','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Savings','Savings Account Certificate','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Time Deposit','Time Deposit Certificate','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Time Deposit','Statement of Account','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Savings','Statement of Account','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Dispute and Chargeback','Transaction Receipt','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Dispute and Chargeback','Sales slip','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Operations_Manager','Document Type','Cards','Transaction Certification','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('KYC_Officer','Document Type','KYC','ID Document','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('KYC_Officer','Document Type','KYC','Proof of Address Document','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('KYC_Officer','Document Type','KYC','Source of Wealth Document','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('KYC_Officer','Document Type','KYC','Supporting Documents','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('KYC_Officer','Document Type','KYC','Bank CDD Documents','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Savings','Savings Account Certificate','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Time Deposit','Time Deposit Certificate','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Time Deposit','Statement of Account','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Savings','Statement of Account','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Dispute and Chargeback','Transaction Receipt','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Dispute and Chargeback','Sales slip','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Settlement_Officer','Document Type','Cards','Transaction Certification','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Savings','Savings Account Certificate','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Time Deposit','Time Deposit Certificate','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Time Deposit','Statement of Account','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Savings','Statement of Account','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Dispute and Chargeback','Transaction Receipt','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Dispute and Chargeback','Sales slip','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('Chargeback_Officer','Document Type','Cards','Transaction Certification','2023-05-02 10:15:43','Admin',NULL,NULL,'Y'),
('IT Manager','Role','Tech','IT_Manager','2023-05-11 17:34:42','Admin',NULL,NULL,'Y'),
('IT Security Manager','Role','Tech','IT_Security_Manager','2023-05-11 17:34:42','Admin',NULL,NULL,'Y'),
('IT Support Officer','Role','Tech','IT_Support_Officer','2023-05-11 17:34:42','Admin',NULL,NULL,'Y');

COMMIT;