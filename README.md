# Keepalived

## Overview

Template and script below checks the status of Keepalived Processes

<p>
This template consist of a Zabbix template and a simple monitoring script. The Keepalived VRRP instance notifys the script when a change happens. The Script writes the Status of the VRRP instance into a temporary file. The Zabbix agent then reads the content of the file with vfs.file.regmatch and reports it to the Zabbix server.
Unfortunately I am only able to test and provide a template for Zabbix Version 5.0.
</p>


 

## Usage 
1. Copy the Script to the keepalived Node into ```/usr/local/bin/keepalived_notify.sh```


2. Make it executable and owned by root
    ```
    chmod 751 /usr/local/bin/keepalived_notify.sh
    chown root:root /usr/local/bin/keepalived_notify.sh
    ```

3. Add the notify Parameter to the Keepalived config
    ```
    vrrp_instance VRRP_1 {
        [...]
        notify "/usr/local/bin/keepalived_notify.sh"
    }
    ```

4. Import the Zabbix template to your Zabbix instance.
5. Add the template to the hosts in Zabbix

<br>

## **keepalived_notify.sh Script:**
```
#!/bin/bash

#Write status to temporaray file.
touch /var/run/keepalived_status
chmod 0644 /var/run/keepalived_status
echo "$1 $2 has transitioned to the $3 state with a priority of $4" > /var/run/keepalived_status
```

## Author

DerHerscher

## Macros used

There are no macros links in this template.

## Template links

There are no template links in this template.

## Discovery rules

There are no discovery rules in this template.

## Items collected

|Name|Description|Type|Key and additional info|
|----|-----------|----|----|
|Keepalived: is BACKUP|<p>-</p>|`Zabbix agent`|vfs.file.regmatch[/var/run/keepalived_status,^.*(BACKUP).*$]<p>Update: 2m</p>|
|Keepalived: is MASTER|<p>-</p>|`Zabbix agent`|vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$]<p>Update: 2m</p>|
|Keepalived: process count|<p>-</p>|`Zabbix agent`|proc.num[keepalived]]<p>Update: 2m</p>|


## Triggers

|Name|Description|Expression|Priority|
|----|-----------|----------|--------|
|Keepalived: state change from BACKUP to MASTER|<p>-</p>|<p>**Expression**: {Template App Keepalived:vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$].prev()}=0 and {Template App Keepalived:vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$].last()}=1</p><p>**Recovery expression**: </p>|average|
|Keepalived: state change from MASTER to BACKUP|<p>-</p>|<p>**Expression**: {Template App Keepalived:vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$].prev()}=1 and {Template App Keepalived:vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$].last()}=0</p><p>**Recovery expression**: </p>|average|
|Keepalived: state is BACKUP but it's stopped|<p>-</p>|<p>**Expression**: {Template App Keepalived:vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$].last()}=0 and {Template App Keepalived:proc.num[keepalived].last()}<2</p><p>**Recovery expression**: </p>|high|
|Keepalived: state is MASTER but it's stopped|<p>-</p>|<p>**Expression**: {Template App Keepalived:vfs.file.regmatch[/var/run/keepalived_status,^.*(MASTER).*$].last()}=1 and {Template App Keepalived:proc.num[keepalived].last()}<2</p><p>**Recovery expression**: </p>|disaster|