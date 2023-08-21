/*-----------------------*/
/*-----CUSTOMER-1145-----*/
/*-----------------------*/

UPDATE `casedb`.`uno_one_master` SET Module_Description='Agent' WHERE Module='Customer' AND Module_Type IN ('Note_Category','Note_Sub_Category', 'Note_Channel') and Module_Code IN ('Note_Onboarding', 'Note_Inbound_Call_Channel', 'Note_Email_Channel', 'Note_Social_Media_Channel', 'Note_Outbound_Call_Channel', 'Note_Fraud_Related_GE', 'Note_Life_Insurance_GE', 'Note_Loans_GE', 'Note_Others_GE', 'Note_Time_Deposit_Query_Gsave', 'Note_Promos_and_Offers', 'Note_SMS_Opt_out', 'Note_App Download', 'Note_Function_Not_Working', 'Note_Journey_Related', 'Note_Mobile_App_Design', 'Note_Account_Status', 'Note_KYC_Activations', 'Note_Registration', 'Note_Unable_to_Onboard');

INSERT IGNORE INTO `casedb`.`uno_one_master` (`Module`,`Module_Type`,`Module_Value`,`Module_Code`,`Module_Description`,`Module_Parent_Code`,`Is_Active`,`Order_Num`) VALUES ('Case','Update_Validity','Contact_Center_Officer','Contact_Center_Officer_Com_Validity','','Complaints','Y',1);
INSERT IGNORE INTO `uno_one_master` (`Module`,`Module_Type`,`Module_Value`,`Module_Code`,`Module_Description`,`Module_Parent_Code`,`Is_Active`,`Order_Num`) VALUES ('Case','Update_Validity','Contact_Center_Manager','Contact_Center_Manager_Com_Validity','','Complaints','Y',2);

/*------------------*/
/*-----CASE-922-----*/
/*------------------*/

INSERT IGNORE INTO `casedb`.`uno_one_master` (`Module`,`Module_Type`,`Module_Value`,`Module_Code`,`Module_Description`,`Module_Parent_Code`,`Is_Active`,`Order_Num`) VALUES ('Case','Validate_Complaints','Valid','Validate_Complaints_Valid','','','Y',1);
INSERT IGNORE INTO `casedb`.`uno_one_master` (`Module`,`Module_Type`,`Module_Value`,`Module_Code`,`Module_Description`,`Module_Parent_Code`,`Is_Active`,`Order_Num`) VALUES ('Case','Validate_Complaints','Invalid','Validate_Complaints_Invalid','','','Y',2);
INSERT IGNORE INTO `casedb`.`uno_one_master` (`Module`,`Module_Type`,`Module_Value`,`Module_Code`,`Module_Description`,`Module_Parent_Code`,`Is_Active`,`Order_Num`) VALUES ('Case','Validate_Complaints','Positive Feedback','Validate_Complaints_Positive','','','Y',3);
INSERT IGNORE INTO `casedb`.`uno_one_master` (`Module`,`Module_Type`,`Module_Value`,`Module_Code`,`Module_Description`,`Module_Parent_Code`,`Is_Active`,`Order_Num`) VALUES ('Case','Validate_Complaints','Negative Feedback','Validate_Complaints_Negative','','','Y',4);

/*------------------*/
/*-----CASE-948-----*/
/*------------------*/

DELETE FROM `casedb`.`uno_one_master` where Module = 'Case' and Module_Type='Category' and Module_Value IN ('#Unoready@GCash(Savings)', '#Unoearn@GCash(Time Deposit)', '#Unoboost@GCash(Time Deposit)', 'Deposit Money', 'Withdraw Money', 'Other Reason');