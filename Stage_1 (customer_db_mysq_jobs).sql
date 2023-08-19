DELIMITER $$
CREATE EVENT mig_rec_batch
ON SCHEDULE EVERY 1 DAY STARTS '2023-08-18 05:00:00' ON COMPLETION NOT PRESERVE ENABLE 
DO
BEGIN
    DECLARE FDate DATE;
    DECLARE TDate DATE;
	DECLARE Recon_Count BIGINT;
	DECLARE data_Count BIGINT;
	DECLARE Max_Id BIGINT;
	DECLARE clients_count BIGINT;
	
	CREATE TABLE IF NOT EXISTS Batch_Duration (
	`Id` bigint NOT NULL AUTO_INCREMENT,
	`Batch_Name` VARCHAR(50) DEFAULT NULL,
	`Batch_Start` DATETIME DEFAULT NULL,
	`Batch_End` DATETIME DEFAULT NULL,
	`Batch_Duration` VARCHAR(100) DEFAULT NULL,
	PRIMARY KEY (`Id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
    
    SET Max_Id = (SELECT IFNULL(MAX(Id), 0) FROM ods_crm_mig_status WHERE CAST(mig_date as date)=CAST(current_date as date));
	SET clients_count = (SELECT count(1) as clients_count FROM ods_crm_mig_status WHERE status='success' and Id = Max_Id);

	IF clients_count = 1 THEN
	CALL SP_Migration();
	CALL SP_Party_Matrix();
	
	SET Recon_Count = (SELECT IFNULL(COUNT(Batch_Name), 0) AS Recon_Count FROM batch_duration WHERE Batch_Name='Reconciliation of Data');
	IF Recon_Count = 0 THEN
      SET FDate = DATE_SUB(str_to_date(LEFT(CURRENT_DATE, 10), '%Y-%m-%d'), INTERVAL 9127 DAY);
	  SET TDate = str_to_date(LEFT(CURRENT_DATE, 10), '%Y-%m-%d');
	  CALL SP_Reconciliation(FDate,TDate);
	ELSE  
	  SET data_Count = (SELECT IFNULL(COUNT(*), 0) AS data_Count FROM temp_clients_count);
	  IF data_Count <> 0 THEN
		  CALL SP_Reconciliation(NULL,NULL);
      ELSE
		  INSERT INTO audit_details (migration_date, batch_id, table_name, message)
		  SELECT CURRENT_TIMESTAMP AS migration_date, Max_Id, 'temp_clients_count' AS table_name, 'The Reconciliation effort failed' AS message;
	  END IF;
    END IF;
	ELSE
		INSERT INTO audit_details (migration_date, batch_id, table_name, message)
		SELECT CURRENT_TIMESTAMP AS migration_date, Max_Id, 'ods_crm_mig_status' AS table_name, 'Failed' AS message;
    END IF;
END;