-- The use of `CREATE USER IF NOT EXISTS` is necessary since the
-- mysql80_data volume may already contain these users due to previous
-- provisioning https://github.com/openedx/devstack/issues/1113

CREATE DATABASE IF NOT EXISTS credentials;
CREATE USER IF NOT EXISTS 'credentials001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON credentials.* TO 'credentials001'@'%';

CREATE DATABASE IF NOT EXISTS enterprise_catalog;
CREATE USER IF NOT EXISTS 'catalog001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON enterprise_catalog.* TO 'catalog001'@'%';

CREATE DATABASE IF NOT EXISTS discovery;
CREATE USER IF NOT EXISTS 'discov001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON discovery.* TO 'discov001'@'%';

CREATE DATABASE IF NOT EXISTS designer;
CREATE USER IF NOT EXISTS 'designer001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON designer.* TO 'designer001'@'%';

CREATE DATABASE IF NOT EXISTS ecommerce;
CREATE USER IF NOT EXISTS 'ecomm001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON ecommerce.* TO 'ecomm001'@'%';

CREATE DATABASE IF NOT EXISTS enterprise_access;
CREATE USER IF NOT EXISTS 'enterprise_access001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON enterprise_access.* TO 'enterprise_access001'@'%';

CREATE DATABASE IF NOT EXISTS notes;
CREATE USER IF NOT EXISTS 'notes001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON notes.* TO 'notes001'@'%';

CREATE DATABASE IF NOT EXISTS registrar;
CREATE USER IF NOT EXISTS 'registrar001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON registrar.* TO 'registrar001'@'%';

CREATE DATABASE IF NOT EXISTS xqueue;
CREATE USER IF NOT EXISTS 'xqueue001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON xqueue.* TO 'xqueue001'@'%';

CREATE DATABASE IF NOT EXISTS `dashboard`;
CREATE USER IF NOT EXISTS 'analytics001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON `dashboard`.* TO 'analytics001'@'%';

CREATE DATABASE IF NOT EXISTS `analytics-api`;
GRANT ALL ON `analytics-api`.* TO 'analytics001'@'%';

CREATE DATABASE IF NOT EXISTS `reports`;
GRANT ALL ON `reports`.* TO 'analytics001'@'%';

CREATE DATABASE IF NOT EXISTS `reports_v1`;
GRANT ALL ON `reports_v1`.* TO 'analytics001'@'%';

CREATE DATABASE IF NOT EXISTS license_manager;
CREATE USER IF NOT EXISTS 'license_manager001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON license_manager.* TO 'license_manager001'@'%';

CREATE DATABASE IF NOT EXISTS edxapp;
CREATE DATABASE IF NOT EXISTS edxapp_csmh;
CREATE USER IF NOT EXISTS 'edxapp001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON edxapp.* TO 'edxapp001'@'%';
GRANT ALL ON edxapp_csmh.* TO 'edxapp001'@'%';

CREATE DATABASE IF NOT EXISTS enterprise_subsidy;
CREATE USER IF NOT EXISTS 'subsidy001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON enterprise_subsidy.* TO 'subsidy001'@'%';

CREATE DATABASE IF NOT EXISTS `edx_exams`;
CREATE USER IF NOT EXISTS 'exams001'@'%' IDENTIFIED BY 'password';
GRANT ALL ON `edx_exams`.* TO 'exams001'@'%';

FLUSH PRIVILEGES;
