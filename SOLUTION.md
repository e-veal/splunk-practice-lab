# WKABI SOLUTION

This is the solution for the `WKABI` Implementation Lab.
## Instructions

### Install new indexers
1. Download latest Splunk
    ```
    wget -O splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz 'https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz'
    ```
1. Untar file
    ```
    tar -xzvf splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz -C /opt
    ```
<font size="4" color="red">**DO NOT START SPLUNK!!**</font>

### Bootstrap indexers to join the cluster as peers

1. Copy secret file from CM to NEW1 & NEW2
    ```
    cd /opt/splunk/etc/auth

    rsync -a splunk.secret sccStudent@<Internal IP of MC>:/opt/splunk/etc/auth
    ```
1. Start Splunk service on NEWIDX1 & NEWIDX2
    ```
    /opt/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt --seed-passwd <adminPwd>
    ```
1. Delete installation file
    ```
    rm splunk-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz
    ```
1. Enable boot start
       
    ```
    su - sccStudent

    sudo /opt/splunk/bin/splunk enable boot-start -user splunk
    
    sudo chown -R splunk /opt/splunk/

    sudo su - root

    vi /etc/init.d/splunk
    ```
1. Update according to https://docs.splunk.com/Documentation/Splunk/8.2.5/Admin/ConfigureSplunktostartatboottime#Enable_boot-start_as_a_non-root_user

### Ensure new indexers receive common configuration
    
1. On CM, copy indexer_base app to new indexers
    ```
    - scp -r /opt/splunk/etc/master-apps/spe_cluster_indexer_base/ splunk@<IP of NEXIDX1>:/opt/splunk/etc/apps/spe_cluster_indexer_base 
    - scp -r /opt/splunk/etc/master-apps/spe_cluster_indexer_base/ splunk@<IP of NEXIDX2>:/opt/splunk/etc/apps/spe_cluster_indexer_base 
    ```
1. Restart new indexers
    ```
    /opt/splunk/bin/splunk restart
    ```
1. Wait for them to join the cluster
1. Remove indexer app from apps on NEW indexers
    ```
    rm -R /opt/splunk/etc/apps/spe_cluster_indexer_base 
    ```

### Prepare to decommission old indexers

1. Point forwarders to new indexers on HF, SH, MC, CM
    ```
    vi /opt/splunk/etc/apps/spe_cluster_forwarder_outputs/local/outputs.conf
    ```
1. Restart instances
    ```
    /opt/splunk/bin/splunk restart
    ```
1. Put old indexers in detention
    ```
    /opt/splunk/bin/splunk edit cluster-config -auth admin:<adminPwd> -manual_detention on
    ```

> Note: If you want to test the offline function before completely removing, execute `/opt/splunk/bin/splunk offline` and restart within 60 seconds.

> Note: Also run a server and look at the Interesting Field `splunk_server`. Should only be the new indexers.

### Decommission old indexers (one at a time)

1. Take old indexers offline
    ```
    /opt/splunk/bin/splunk offline --enforce-counts
    ```
1. Wait for status to show `GracefulShutdown` on CM

### Remove the old peers

1. Get the GUID of the old peers from the CM
    ```
    /opt/splunk/bin/splunk list cluster-peers -auth admin:<adminPwd>
    ```
1. Remove peer for manager node list (check the label)
    ```
    /opt/splunk/bin/splunk remove cluster-peers -peers <guidofOldIDX1>, <guidofOldIDX2>
    ```
1. Verify upgrade was sucessful by running a search and checking the `splunk_server` field
1. Update Monitoring Console
    
    - Disable the old indexers under General Setup