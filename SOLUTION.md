# GAMORA SOLUTION

This is the solution for the `GAMORA` Implementation Lab.

## Instructions

### Install Splunk on MC
1. Change to sccStudent to install
    ```
    su - sccStudent
    ```    
1. Get package
    
    ```
    wget -O splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz 'https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz'
    ```
1. Install pkg

    ```
    sudo tar -xzvf splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz -C /opt
    ```
1. Change owner to splunk
    ```
    sudo chown -R splunk:splunk /opt/splunk
    ```

<font size="4" color="red">**DO NOT START SPLUNK!!**</font>
### Match secret keys
1. Copy secret file from CM to MC
    ```
    cd /opt/splunk/etc/auth

    rsync -a splunk.secret splunk@<IP of MC>:/opt/splunk/etc/auth
    ```

### Complete install

1. Start splunk on MC
    ```
    /opt/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt --seed-passwd <adminPwd>
    ```
1. Enable boot start
       
    ```
    su - sccStudent

    sudo /opt/splunk/bin/splunk enable boot-start -user splunk
    
    sudo chown -R splunk /opt/splunk/

    sudo su - root

    vim /etc/init.d/splunk
    ```

1. Update file according to https://docs.splunk.com/Documentation/Splunk/8.2.5/Admin/ConfigureSplunktostartatboottime#Enable_boot-start_as_a_non-root_user

### Decrypt pass4SymmKey

1. On CM, search for pass4SymmKey
    ```
    /opt/splunk/bin/splunk btool server list cluster --debug | grep -v default
    ```
1. Create base app called `ci1_unhash_app` with a file called `passwords.conf`
    ```
    [credential::test:]
    password = (pass4Symmkey)
    ```
1. Add test app to MC 
    ```
    rsync -r ci1_unhash_app --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of MC>:/opt/splunk/etc/apps/
    ```
1. Restart Splunk on MC
    ```
    /opt/splunk/bin/splunk restart
    ```
1. Get decrypted password  
    ```
    /opt/splunk/bin/splunk _internal call /storage/passwords/test | grep clear
    ```
1. Copy decrypted pass4SymmKey to use later
1. Remove hash app on MC
    ```
    rm -r /opt/splunk/etc/apps/ci1_unhash_app
    ```
### Connect MC to IDX
1. Update `spe_cluster_search_base` to point to CM
    ```
    [clustering]
    mode = searchhead
    manager_uri = https://<IP of CM>:8089
    pass4SymmKey = <decrypted pass4SymmKey>
    ```
1. Upload to MC
    ```
    rsync -r spe_cluster_search_base --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of MC>:/opt/splunk/etc/apps/
    ```
1. Restart Splunk on MC
    ```
    /opt/splunk/bin/splunk restart
    ```
1. Check that CM recognizes MC on dashboard

### Fix UNABLE TO CONNECT TO LICENSE MASTER 
_Issue: IDXs are pointing to the wrong IP for the license manager_
1. On CM, update `/etc/apps/master-apps/spe_cluster_indexer_base/local/server.conf`
    ```
    [license]
    master_uri = https://<IP of MC>:8089
    ```

1. Push update to IDXs

1. Upload license to MC

### Fix data ingest issue
_Issue: Inputs are on indexers instead of forwarders_

1. Download input (including Splunk_TA_nix) apps from CM
    ```
    rsync -a splunk@<Public IP of CM>:/opt/splunk/etc/master-apps/ /path/to/local/storage
    ```
    >Hint: Downloading all the folders is easier, than going one by one. Just delete what you don't want.
1. Delete inputs from IDXs
    ```
    rm -R spe_mail_inputs spe_os_inputs spe_network_inputs Splunk_TA_nix
    ```
1. Upload to UFs
    ```
    rsync -a spe_mail_inputs spe_os_inputs spe_network_inputs Splunk_TA_nix --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of UFs>:/opt/splunkforwarder/etc/apps/
    ```
### Reingest data
_Issue: Since the inputs weren't applied, data was ingested incorrectly. Therefore, it needs to be reingested._

1. Put CM in maintenance mode

    ```
    /opt/splunk/bin/splunk enable maintenance-mode --answer-yes -auth admin:<adminPwd>
    ```
1. Stop UFs

    `/opt/splunkforwarder/bin/splunk stop`
1. Stop IDXs

    `/opt/splunk/bin/splunk stop`
1. Clear data in a single index on indexers
    
    `/opt/splunk/bin/splunk clean eventdata -index os -f`
1. clear fishbucket on forwarders 

    `rm -r /opt/splunkforwarder/var/lib/splunk fishbucket && cd /opt/splunkforwarder/bin/`
1. Start IDXs, then UFs

    ```
    /opt/splunk/bin/splunk start
    then
    /opt/splunkforwarder/bin/splunk start
    ```
1. Take CM out of maintenance mode
    
    `/opt/splunk/bin/splunk disable maintenance-mode`

1. Verify that all indexes show
