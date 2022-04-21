# NAKIA SOLUTION

This is the solution for the `NAKIA` Implementation Lab.

## Instructions

### Disabled app
_Issue: Inputs app is disabled_
1. On UF, navigate to `etc/apps` to determine which inputs are being monitored
    ```
    cd /opt/splunkforwarder/etc/apps/spe_linux_maillog_inputs/local/
    ```
1. In the `inputs.conf` file the app is disabled. Enable app.
    ```
    disabled=0
    ```

### Update permissions on monitored input
_Issue: Splunk doesn't own the directories being monitored_
1. Check the permissions on **/var/log/maillog** and **/var/data/appserver**
    ```
    getfacl /var/log/maillog
    getfacl /var/data/appserver
    getfacl /var/data/syslog
    ```
1. Using **sccStudent**, update recursive folder permissions on only these logs: **/var/log/maillog and /var/data/appserver**
    ```
    sudo setfacl -m u:splunk:r-x /var/log/maillog
    sudo setfacl -Rm u:splunk:r-x /var/data/appserver
    ```
1. Restart UF
    ```
    /opt/splunkforwarder/bin/splunk restart
    ```
### Fix sourcetypes 
_Issue: Customer specifically requested specific sourcetypes for their data, however, everything is coming in as maillog._
> Note: You don't want to delete all customer data; could potentially incur additional ingestion fees for them

### _Remove maillog sourcetype from non-maillog data_

1. On SH, search for 
    ```
    index=linux sourcetype=maillog source!="/var/log/maillog"
    ```
1. Take note of the number of entries (1455)
1. Add `can delete` to **admin**
- Delete entries
    ```
    index=linux sourcetype=maillog source!="/var/log/maillog" | delete
    ```

### _Ingest data properly_
1. On the HF, update `props.conf`
    > Note: pay attention to the number of dots
    ```
    [source::.../maillog*]
    sourcetype = maillog

    [source::.../cloud-init*]
    sourcetype = cloud-init
    ```
1. Move `props.conf` from HF to UF
    ```
    cd /opt/splunk/etc/apps/
    rsync -a spe_linux_maillog_props splunk@<IP of UF>:/opt/splunkforwarder/etc/apps/
    ```
1. Delete props from HF
    ```
    rm -r spe_linux_maillog_props
    ```
1. On the UF, update `inputs.conf`
    > Note: Remove the sourcetype line
    ```
    [monitor:///var/log/]
    whitelist = (maillog.*|cloud-init.*)$
    index = linux
    disabled = 0
    ```
1. Stop splunk on HF and UF
    ```
    /opt/splunk/bin/splunk stop
    /opt/splunkforwarder/bin/splunk stop
    ```

1. Reingest log files on UF
    ```
    /opt/splunkforwarder/bin/splunk cmd btprobe -d /opt/splunkforwarder/var/lib/splunk/fishbucket/splunk_private_db --file /var/log/cloud-init.log --reset

    /opt/splunkforwarder/bin/splunk cmd btprobe -d /opt/splunkforwarder/var/lib/splunk/fishbucket/splunk_private_db --file /var/log/cloud-init.log.0 --reset
    ```
1. Start HF & UF
    ```
    /opt/splunk/bin/splunk start
    /opt/splunkforwarder/bin/splunk start
    ```

### Onboard appserver logs
_Issue: Customer wants to onboard appserver logs_
1. Create an app with `inputs.conf` to ingest appserver logs
    ```
    [monitor:///var/data/appserver]
    whitelist = (appserver.*)$
    index = linux
    disabled = 0
    ```
1. Create app with `props.conf` to set sourcetype for appserver logs
    ```
    [source::...appserver*]
    sourcetype = appserver
    ```
1. 1. Upload apps to UF
    ```
   rsync -a spe_linux_appserver_inputs spe_linux_appserver_props --exclude 'Icon*' --exclude '.DS_Store' splunk@<IP of UF>:/opt/splunkforwarder/etc/apps/
    ``
1. Restart UF
    ```
    /opt/splunk/bin/splunk restart
    ```

### Fix crcSalt error
_Issue: All logs aren't ingesting because it thinks its already ingested. CrcLength needs to be extended._
1. Compare the appserver file lengths to find the length to add
    ```
    cmp /var/data/appserver/appserver.log /var/data/appserver/appserver.log.0
    ```
1. Add length to 256 to get initCrcLength
    - initCrcLength = 256 + `<bytes>` 
        - initCrcLength = 256 + 1882 = 2138
1. Update `props.conf` to include `initCrcLength`
    ```
    [monitor:///var/data/appserver]
    whitelist = (appserver.*)$
    initCrcLength = 2138
    index = linux
    disabled = 0
    ```
1. Restart UF