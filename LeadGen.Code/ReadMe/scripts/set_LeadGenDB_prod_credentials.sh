#!/bin/bash

# set permissions  | chmod +x set_LeadGenDB_prod_credentials.sh |  chmod +x /opt/scripts/set_LeadGenDB_prod_credentials.sh
# run once         | . set_LeadGenDB_prod_credentials.sh

echo "Setting LeadGenDB_prod credentials"
export LeadGenDB_prod_dbName='LeadGenDB_prod'
export LeadGenDB_prod_sqlUser='LeadGenDB_PROD_SQL_USER_VALUE'
export LeadGenDB_prod_sqlPassword='LeadGenDB_PROD_SQL_PASSWORD_VALUE'
