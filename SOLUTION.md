# OKOYE SOLUTION

This is the solution for the `OKOYE` Implementation Lab.
## Instructions

### Fix props
_Issue: Props are on the IDXs instead of the HF._

1. From CM, move props app to HF
    ```
    cd /opt/splunk/etc/master-apps
    rsync -a spe_indexer_orig_fwd_props --exclude 'Icon*' --exclude '.DS_Store' splunk@<IP of HF>:/opt/splunk/etc/apps/
    ```
1. Remove props app from CM
    ```
    rm -R spe_indexer_orig_fwd_props
    ```
1. Push new bundle
    ```
    /opt/splunk/bin/splunk apply cluster-bundle --answer-yes -auth admin:<adminPwd>
    ```
1. Restart HF
    ```
    /opt/splunk/bin/splunk restart
    ```
### Fix inputs
_Issue: Data isn't set to ingest_
1. Verify which directories should be ingesting data
    ```
    cat /opt/splunkforwarder/etc/apps/spe_linux_syslog_inputs/local/inputs.conf 
    ```
1. Here we see that we should ingest from `/var/log` and `var/data` but the first stanza is disabled. Update `spe_linux_syslog_inputs/local/inputs.conf` to enable.
    ```
    [monitor:///var/log/]
    index = linux
    disabled = 0

    [monitor://var/data/syslog]
    index = linux
    ```
1. Verify the permissions on the monitored inputs
    ```
    getfacl /var/log
    getfacl /var/data/syslog
    ```
1. Using **sccStudent**, grant access for splunk user
    ```
    sudo setfacl -Rm u:splunk:rwx /var/log
    sudo setfacl -Rm u:splunk:rwx /var/data/syslog
    ```

1. Update props.conf on HF
    ```
    [syslog]
    #TRANSFORMS-save_orig_host = save_orig_host
    TRANSFORMS = save_orig_host,syslog-host
    ```
### Reingest data
_Issue: Since the inputs weren't applied, data was ingested incorrectly. Therefore, it needs to be reingested._

1. Put CM in maintenance mode

    ```
    /opt/splunk/bin/splunk enable maintenance-mode --answer-yes -auth admin:<adminPwd>
    ```
1. Stop UF and HF

    `/opt/splunkforwarder/bin/splunk stop`
1. Stop IDXs

    `/opt/splunk/bin/splunk stop`
1. Clear data in a single index on indexers
    
    `/opt/splunk/bin/splunk clean eventdata -index os -f`
1. clear fishbucket on forwarders 

    `rm -r /opt/splunkforwarder/var/lib/splunk fishbucket && cd /opt/splunkforwarder/bin/`
1. Start IDXs, HF, then UF

    ```
    /opt/splunk/bin/splunk start
    then
    /opt/splunkforwarder/bin/splunk start
    ```
1. Take CM out of maintenance mode
    
    `/opt/splunk/bin/splunk disable maintenance-mode`

1. Verify data ingested correctly
    - Should have a new index `linux`
    - Should have host `combo`
    - When using the search query `index=linux host=combo`, should have a field called `splunk_orig_fwd` that has the UF hostname

### Create custom indexed field
_Issue: Customer requested a field they can search on called `splunk_orig_fwd`_
1. Create app **spe_splunk_orig_fwd_fields**
    ```
    [splunk_orig_fwd]
    INDEXED = true
    ```
1. Upload to SH & MC 
    ```
    rsync -a spe_splunk_orig_fwd_fields --exclude 'Icon*' --exclude '.DS_Store' splunk@<IP of SH & MC>:/opt/splunk/etc/apps/
    ```
1. Verify the field shows iin the Search console