# Wkabi Solution

1. Install new indexers
    - Using sccStudent, install Splunk on NEWIDX1 & NEWIDX2
        - Get package
            - wget -O splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz 'https://download.splunk.com/products/splunk/releases/8.2.4/linux/splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz'
        - Install pkg
            - sudo tar -xzvf splunk-8.2.4-87e2dda940d1-Linux-x86_64.tgz -C /opt

1. Bootstrap indexers to join the cluster as peers
    - Get secret key from CM to NEWIDX1 & NEWIDX2
        - splunk doesn't own splunk directory on NEWIDX1 & NEWIDX2
            - sudo chown -R splunk:splunk /opt/splunk

        - Copy file from CM to NEWIDX1 & NEWIDX2
        - cd /opt/splunk/etc/auth
        - scp splunk.secret splunk@<IP of NEXIDX>:/opt/splunk/etc/auth

    - Decrypt pass4Sym
        
        **Search for pass4Sym key on CM**
        - /opt/splunk/bin/splunk btool server list cluster --debug | grep -v default

        **Decrypt pass4Sym key**
        /opt/splunk/bin/splunk show-decrypted --value 'xxxx'
        
        **Create base app**
        - Create base app called `ci1_unhash_app` with a file called `passwords.conf`
        
            >[credential::test:]<br/>
            >password = (pass4Symmkey)
            
        **Add app to NEWIDX1 & NEWIDX2 (in local terminal)**
        - cd <LOCATION ON LOCAL MACHINE>
        - rsync -r ci1_unhash_app --exclude 'Icon*' --exclude '.DS_Store' splunk<PUBLIC IP of NEWIDX>:/opt/splunk/etc/apps/
        - rsync -r ci1_unhash_app --exclude 'Icon*' --exclude '.DS_Store' splunk@<PUBLIC IP of NEWIDX>:/opt/splunk/etc/apps/

    - Start Splunk on NEWIDX1 & NEWIDX2
        - /opt/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt --seed-passwd splunk3du
        
    - Remove hash app
        - rm -r /opt/splunk/etc/apps/ci1_unhash_app
       
    - Add indexer_base app to NEWIDX1 & NEWIDX2 (in local terminal)
        - Log into IDX1
        - Move indexer_base app to NEWIDX1 & NEWIDX2
        - scp -r /opt/splunk/etc/slave-apps/spe_cluster_indexer_base/ splunk@<IP of NEXIDX>:/opt/splunk/etc/apps/spe_cluster_indexer_base 
        - scp -r /opt/splunk/etc/slave-apps/spe_cluster_indexer_base/ splunk@<IP of NEXIDX>:/opt/splunk/etc/apps/spe_cluster_indexer_base 
        - Restart NEWIDXers
            - /opt/splunk/bin/splunk restart

        - Push bundle to cluster

 - Enable non-root boot start
        - Using sccStudent, enable boot start:
            - sudo /opt/splunk/bin/splunk enable boot-start -user splunk
            - sudo chown -R splunk /opt/splunk/
            - sudo vim /etc/init.d/splunk
            - update according to https://docs.splunk.com/Documentation/Splunk/8.2.5/Admin/ConfigureSplunktostartatboottime#Enable_boot-start_as_a_non-root_user

1. Prepare for decommissioning

    - Point forwarders to new indexers
        - Update outputs.conf on HFx, SHx, MCx, CM
            - vim /opt/splunk/etc/apps/spe_cluster_forwarder_outputs/local/outputs.conf
        - Restart servers
            - /opt/splunk/bin/splunk restart
    - Put old indexers in detention
        - On IDX1 & IDX2 
            - /opt/splunk/bin/splunk edit cluster-config -auth admin:splunk3du -manual_detention on
        
1. Decommission old indexers (one at a time)

    - Run command `/opt/splunk/bin/splunk offline --enforce-counts`

1. Remove the old peers

    - Restart CM
        - /opt/splunk/bin/splunk restart

1. Update Monitoring Console
    
    - Disable the old indexers under General Setup