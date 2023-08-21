/*------------applicationdb------------*/

DROP SCHEMA `applicationdb`;

CREATE SCHEMA `applicationdb`;

CREATE TABLE `applicationdb`.`app_party`
SELECT * FROM `applicationdb_bkp`.`app_party`;

CREATE TABLE `applicationdb`.`app_party_status`
SELECT * FROM `applicationdb_bkp`.`app_party_status`;

CREATE TABLE `applicationdb`.`app_address`
SELECT * FROM `applicationdb_bkp`.`app_address`;

CREATE TABLE `applicationdb`.`app_consent_details`
SELECT * FROM `applicationdb_bkp`.`app_consent_details`;

CREATE TABLE `applicationdb`.`app_contact`
SELECT * FROM `applicationdb_bkp`.`app_contact`;

CREATE TABLE `applicationdb`.`app_kyc_details`
SELECT * FROM `applicationdb_bkp`.`app_kyc_details`;

CREATE TABLE `applicationdb`.`app_occupation`
SELECT * FROM `applicationdb_bkp`.`app_occupation`;

CREATE TABLE `applicationdb`.`app_relationship`
SELECT * FROM `applicationdb_bkp`.`app_relationship`;

COMMIT;