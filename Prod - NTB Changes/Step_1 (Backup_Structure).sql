/*------------applicationdb_bkp------------*/

CREATE SCHEMA `applicationdb_bkp` ;

CREATE TABLE `applicationdb_bkp`.`app_party`
SELECT * FROM `applicationdb`.`app_party`;

CREATE TABLE `applicationdb_bkp`.`app_party_status`
SELECT * FROM `applicationdb`.`app_party_status`;

CREATE TABLE `applicationdb_bkp`.`app_address`
SELECT * FROM `applicationdb`.`app_address`;

CREATE TABLE `applicationdb_bkp`.`app_consent_details`
SELECT * FROM `applicationdb`.`app_consent_details`;

CREATE TABLE `applicationdb_bkp`.`app_contact`
SELECT * FROM `applicationdb`.`app_contact`;

CREATE TABLE `applicationdb_bkp`.`app_kyc_details`
SELECT * FROM `applicationdb`.`app_kyc_details`;

CREATE TABLE `applicationdb_bkp`.`app_occupation`
SELECT * FROM `applicationdb`.`app_occupation`;

CREATE TABLE `applicationdb_bkp`.`app_relationship`
SELECT * FROM `applicationdb`.`app_relationship`;

COMMIT;