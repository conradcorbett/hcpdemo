
vault read sys/license/status
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=hvs.B64McxRmKD2WnVJG1WiTIA0e
export VAULT_NAMESPACE=dev
export MYSQL_ENDPOINT=<INSERT_MYSQL_IP>:3306
vault status

vault write data_protection/database/config/flaskapp \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(${MYSQL_ENDPOINT})/" \
    allowed_roles="demo-app" \
    username="root" \
    password="aaBB**cc1122"

vault write data_protection/database/roles/demo-app \
    db_name=flaskapp \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED WITH mysql_native_password BY '{{password}}';GRANT ALL PRIVILEGES ON *.* TO '{{name}}'@'%';" \
    default_ttl="2m" \
    max_ttl="2m"

vault write -force data_protection/database/rotate-root/flaskapp
#Attempt to add entry to database through the app, this should fail because the root password has been rotated

vault read data_protection/database/creds/demo-app
#Update db.yaml with username and password from above

