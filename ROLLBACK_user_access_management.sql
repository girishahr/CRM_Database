SET SQL_SAFE_UPDATES=0;

--
-- ROLLBACK ALTER Table for `app_user_roles`
--

ALTER TABLE `user_access_management`.`app_user_roles` 
DROP COLUMN `Is_Active`;

--
-- ROLLBACK ALTER Table for `app_roles_permission`
--

ALTER TABLE `user_access_management`.`app_roles_permission` 
DROP COLUMN `Updated_On`,
DROP COLUMN `Updated_By`;

