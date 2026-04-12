# Step 01 - Password and admin policy

:local adminUser "admin"
:local routerPassword "{{ .ROUTER_PASSWORD }}"

:put "Step 01: password policy start"
/user set [find where name=$adminUser] password=$routerPassword
:put "Step 01: password policy complete"

