# Lab 1 Solution

Using sccStudent, install MC
    Get package
    - wget -O splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz 'https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz'
    
    Install pkg
    - sudo tar -xzvf splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz -C /opt

    Enable boot start
    - /opt/splunk/bin/splunk enable boot-start -user splunk
    - chown -R splunk /opt/splunk/
    - sudo su - root
    - vim /etc/init.d/splunk
    - update according to https://docs.splunk.com/Documentation/Splunk/8.2.5/Admin/ConfigureSplunktostartatboottime#Enable_boot-start_as_a_non-root_user

Get secret key from CM to MC
    - splunk doesn't own splunk directory on CM

    Copy file from CM to MC
    - scp splunk.secret splunk@10.0.4.48:/opt/splunk/etc/auth

Decrypt pass4Sym
    Search for pass4Sym key
    - /opt/splunk/bin/splunk btool server list cluster --debug | grep -v default

    - Create base app called `ci1_unhash_app` with a file called `passwords.conf`
    [credential::test:]
    password = (pass4Symmkey)

    Add app to MC (in new terminal)
    - cd "/Users/eveal/Downloads/Splunk/Practice Ansible Environment/labs/Lab 1"

    - rsync -r ci1_unhash_app --exclude 'Icon*' --exclude '.DS_Store' splunk@44.200.228.121:/opt/splunk/etc/apps/
    
    Restart Splunk
        or refresh http://44.200.228.121:8000/en-US/debug/refresh 

    - /opt/splunk/bin/splunk _internal call /storage/passwords/test | grep clear
    
Join MC to CM

    Update spe_cluster_search_base
    Copy search_output
    - rsync -r spe_cluster_search_base --exclude 'Icon*' --exclude '.DS_Store' splunk@44.200.228.121:/opt/splunk/etc/apps/

Remove hash app
    sudo rm -r /opt/splunk/etc/apps/ci1_unhash_app

Fix DISABLED-DUE-TO-GRACE-PERIOD issues
    Remove spe_cluster_indexer_base from /etc/apps
    Update license server on /etc/apps/master-apps/server.conf on CM
    Push update to IDXs
    Upload license to MC

Fix data ingest issue
    Update path in indexes_volume on CM
        /opt/splunk/var/lib/splunk
    Push update to IDXs
    Inputs are on IDX instead of UFs
        - download input (including Splunk_TA_nix) apps from CM
        - delete inputs from IDXs
        - upload to UFs
        - push update
    Clear indexed data
    - put CM in maintenance mode
        /opt/splunk/bin/splunk enable maintenance-mode --answer-yes
    - stop forwarders
        /opt/splunkforwarder/bin/splunk stop
    - stop indexers
        /opt/splunk/bin/splunk stop
    - clear data in a single index on indexers
        /opt/splunk/bin/splunk clean eventdata -index os -f  
    - clear fishbucket on forwarders
        rm -r /opt/splunkforwarder/var/lib/splunk/fishbucket && cd /opt/splunkforwarder/bin/
    - start everything
        /opt/splunkforwarder/bin/splunk start
        /opt/splunk/bin/splunk start
    - take CM out of maintenance mode
        /opt/splunk/bin/splunk disable maintenance-mode
