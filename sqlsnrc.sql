--set sqlsn modules path
define g_sqlsn_modules_path = 'oradb_modules/sqlsn/sqlsn_modules'

--init sqlsn-core module
set verify off
@&&g_sqlsn_modules_path/sqlsn-core/module.sql "&&g_sqlsn_modules_path/sqlsn-core" 
