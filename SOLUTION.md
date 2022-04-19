# ZURI SOLUTION

This is the solution for the `ZURI` Implementation Lab.

## Instructions

### Set up the Deployer
1. Create an app with the following stanza:
    ```
    [shclustering]
    pass4SymmKey = <key of your choosing>
    shcluster_label=lab8_shc
    ```
1. Upload to MC/Deployer 
    ```
    rsync -a spe_search_deployer_server --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of Deployer>:/opt/splunk/etc/apps/
    ```
1. Restart splunk on MC/Deployer
    ```
    /opt/splunk/bin/splunk restart
    ```

### Install Splunk Instances
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
1. Copy secret file from CM to SHs
    ```
    cd /opt/splunk/etc/auth

    scp splunk.secret splunk@{{IP_of_SH}}:/opt/splunk/etc/auth
    ```

### Complete install

1. Start splunk on SH1 & SH2
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

1. Update according to [this](https://docs.splunk.com/Documentation/Splunk/8.2.5/Admin/ConfigureSplunktostartatboottime#Enable_boot-start_as_a_non-root_user)

### Ensure replication and kv store ports are open on SH1, SH2, MC
1. Under **sccStudent**, install firewall-cmd
    ```
    sudo yum install firewalld -y
    ```
1. Start service as **root**
    ```
    systemctl start firewalld

    systemctl enable firewalld
    ```
1. Open ports as **sccStudent**
    ```
    sudo firewall-cmd --add-port=8191/tcp --add-port=8000/tcp --add-port=8080/tcp --add-port=8089/tcp --add-port=8191/tcp --add-port=9887/tcp --add-port=9997/tcp --permanent

    sudo firewall-cmd --reload
    ```
### Initialize cluster members
> Can not create an app because API calls are triggered with CLI command

1. On each SH run the following command:

    ```
    /opt/splunk/bin/splunk init shcluster-config -auth admin:<adminPwd> -mgmt_uri https://<IP of current SH>:8089 -replication_port 9887 -replication_factor 2 -conf_deploy_fetch_url https://<IP of deployer>:8089 -secret <key you choose in step 1> -shcluster_label lab8_shc
    ```
1. Restart splunk on each member
    ```
    /opt/splunk/bin/splunk restart
    ```

### Bring up the cluster captain
1. Select either instance (SH1 or SH2) to be the captain, run the following command

    ```
    /opt/splunk/bin/splunk bootstrap shcluster-captain -servers_list "https://<IP of SH1>:8089,https://<IP of SH2>:8089" -auth admin:<adminPwd>
    ```

### Decrypt CM password 
1. On CM, search for pass4SymmKey
    ```
    /opt/splunk/bin/splunk btool server list cluster --debug | grep -v default
    ```
1. Grab pass4SymmKey and add to this command:
    ```
    /opt/splunk/bin/splunk show-decrypted --value '<pass4SymmKey>'
    ```
    > Note: It should be the same on SH1, SH2, and CM

### Connect SHC to IDX cluster
1. Use the `org_cluster_search_base` base config:
    ```
    [clustering]
    mode = searchhead
    manager_uri = https://<IP of CM>:8089
    pass4SymmKey = <decrypted key>
    multisite = false
1. Upload app to /etc/shcluster/apps app on the SHC Deployer
    ```
    rsync -a spe_cluster_search_base --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of Deployer>:/opt/splunk/etc/shcluster/apps/
    ```
1. On SHC Deployer, push apps using the following command:
    ```
    /opt/splunk/bin/splunk apply shcluster-bundle --answer-yes -target https://<IP of captain>:8089 -auth admin:<adminPwd>
    ```
> Note: Only need to run on one SH in SHC.

> Note: If `splunk.secret` wasn't moved then each node must individual encrypt the password. Run the following command on each node:
>
>    `splunk edit cluster-config -mode searchhead -manager_uri https://<IP of CM>:8089 -secret <decrypted pass4SymmKey> -auth admin:<adminPwd>`
>
>    `splunk restart`

### Check the status of SHC
1. Check SHC on captain
    ```
    /opt/splunk/bin/splunk show shcluster-status -auth admin:<adminPwd>
    ```
1. Check KV store
    ```
    /opt/splunk/bin/splunk show kvstore-status -auth admin:<adminPwd>  
    ```
### Install TA Fire Brigade app on IDXs
1. According to the **Details** section, you also need to download [Technology Add-on for Fire Brigade](https://splunkbase.splunk.com/app/1564/)
1. Unzip/untar app
1. Upload to /etc/master-apps/ on CM
    ```
    rsync -a TA-fire_brigade --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of CM>:/opt/splunk/etc/master-apps/
    ```
1. On CM, push apps using GUI or the following command:
    ```
    /opt/splunk/bin/splunk apply cluster-bundle --answer-yes -auth admin:<adminPwd>
    ```
### Install Fire Brigade app
1. Download [Fire Brigade](https://splunkbase.splunk.com/app/1581/)
1. Unzip/untar app
1. Upload to /etc/shcluster/apps
    ```
    rsync -a fire_brigade --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of Deployer>:/opt/splunk/etc/shcluster/apps/
    ```
1. On SHC Deployer, push apps using the following command:
    ```
    /opt/splunk/bin/splunk apply shcluster-bundle --answer-yes -target https://<IP of captain>:8089 -auth admin:<adminPwd>
    ```

### Configure app permissions
1. Create `local.meta` file in /fire_brigade/metadata
1. Add the following stanzas:
    ```
    []
    access = read : [ * ], write : [ admin ]
    export = system
    ```

### Update LDAP app
1. From Lab 2, update `authentication.conf` in the LDAP app:
    ```
    host = <new LDAP IP>
    bindDN = <new DNS>
    ```
