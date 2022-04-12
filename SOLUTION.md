# OKOYE SOLUTION

This is the solution for the `OKOYE` Implementation Lab.
## Instructions

1. Move props off indexers

    - On CM, copy props app to HF

        `cd /opt/splunk/etc/apps`
        `rsync -a spe_indexer_orig_fwd_props --exclude 'Icon*' --exclude '.DS_Store' splunk@10.0.4.23:/opt/splunk/etc/apps/`
    - remove props app from CM

        `rm -R spe_indexer_orig_fwd_props`
    - push new bundle

        `/opt/splunk/bin/splunk apply cluster-bundle --answer-yes`
    - restart HF

        `/opt/splunk/bin/splunk restart`

1. Grant /var/data access

    - `setfacl -Rm u:splunk:rwx /var/data`

1. Update inputs.conf on UF
    ```
    [monitor:///var/log/]
    index = linux
    disabled = 0

    [monitor://var/data/syslog]
    index = linux
    ```

1. Update props.conf on HF
    ```
    [syslog]
    #TRANSFORMS-save_orig_host = save_orig_host
    TRANSFORMS = save_orig_host,syslog-host
    ```

1. Reingest data
    - Clear index

1. Update fields.conf on SH & MC
    - create app **spe_splunk_orig_fwd_fields**
    ```
    [splunk_orig_fwd]
    INDEXED = true
    ```
    - upload to SH & MC
    
    ```
    rsync -a spe_linux_appserver_inputs --exclude 'Icon*' --exclude '.DS_Store' splunk@44.192.89.62:/opt/splunkforwarder/etc/apps/
    ```
