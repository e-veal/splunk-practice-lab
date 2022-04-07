# Lab 3 Solution

1. Missing data
    - Check IDX to see where log files are going. On UF, look for what directories are being monitored in inputs.conf
        - `cd /opt/splunkforwarder/etc/apps/`
        - all inputs folder
    - Notice that **spe_linux_maillog_inputs/local/inputs.conf** is set to **disabled=1**
        - Update to `disabled=0`
    - Check the permissions on **/var/log/maillog** and **/var/data/appserver**
        - `sudo getfacl /var/log/maillog`
        - `sudo getfacl /var/data/appserver`
        - `sudo getfacl /var/data/syslog`
    - Update recursive folder permissions on only these logs: **/var/log/maillog and /var/data/appserver**
        - `sudo setfacl -m u:splunk:r-x /var/log/maillog`
        - `sudo setfacl -Rm u:splunk:r-x /var/data/appserver`
    - Restart UF
        - `/opt/splunkforwarder/bin/splunk restart`

1. All sourcetypes are maillog 

    - You don't want to delete all customer data; could potentially incur additional ingestion fees for them
    - Delete all data of sourcetype=maillog that isn't maillog
        - Search for `index=linux sourcetype=maillog source!="/var/log/maillog"`
        - Take note of the number of entries
    - Turn on `can delete` under user
    - Update props.conf on HF
    - Delete entries
        - `index=linux source="/var/log/cloud-init*" | delete`
    - Stop splunk on HF and UF
        - `/opt/splunk/bin/splunk stop`
        - `/opt/splunkforwarder/bin/splunk stop`
    - Move props off HF; put on UF
        - `cd /opt/splunk/etc/apps/`
        - `rsync -a spe_linux_maillog_props splunk@10.0.4.27:/opt/splunkforwarder/etc/apps/`
    - Delete props from HF
        - `rm -r spe_linux_maillog_props`
    - Ensure the syntax of the inputs.conf file is:
        ```
        [monitor:///var/log/]
        whitelist = (maillog.*|cloud-init.*)$
        index = linux
        disabled = 0
        ```
    - Ensure the syntax of the props.conf is 
        ```
        [source::.../maillog*]
        sourcetype = maillog

        [source::.../cloud-init*]
        sourcetype = cloud-init
        ```
    - Reingest log files on UF
        ```
        /opt/splunkforwarder/bin/splunk cmd btprobe -d /opt/splunkforwarder/var/lib/splunk/fishbucket/splunk_private_db --file /var/log/cloud-init.log --reset

        /opt/splunkforwarder/bin/splunk cmd btprobe -d /opt/splunkforwarder/var/lib/splunk/fishbucket/splunk_private_db --file /var/log/cloud-init.log.0 --reset

        /opt/splunkforwarder/bin/splunk cmd btprobe -d /opt/splunkforwarder/var/lib/splunk/fishbucket/splunk_private_db --file /var/log/cloud-init-output.log --reset
        ```

1. Onboard appserver logs

    - Create inputs.conf & upload to UF
        ```
        [monitor:///var/data/appserver]
        whitelist = (appserver.*)$
        index = linux
        disabled = 0
        ```
    - Create props.conf & upload to UF
        ```
        [source::...appserver*]
        sourcetype = appserver
        ```

1. crcSalt error

    - Compare the appserver file lengths to find the length to add
        - `cmp /var/data/appserver/appserver.log /var/data/appserver/appserver.log.0`
    - Add length to 256 to get initCrcLength
        - initCrcLength = 256 + `<bytes>` 
            - initCrcLength = 256 + 1882 = 2138