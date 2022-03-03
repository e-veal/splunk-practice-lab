
# Prepare the files
- Update config files

# Install Splunk 
    - install on enterprise 
    - install on fwdrs

# Add license
    - Download license
    - Go to licensing, upload license

# Configure Forwarders
    - Check splunkd port
        ./splunk show splunkd-port
    - Make sure archStudent has permission to /var/log & /opt/log 
        - chown -R splunk:splunk /opt/log /var/log

# Configure Hostnames
    - Upload hostnames

# Upload apps
    - Upload to etc/apps on SH, FWDRs
        - deploymentclient

    - Upload to etc/system/local
        - sh-global-banner.conf

    - Upload to etc/apps on CM
        - cluster_master_base
        - cluster_forwarder_outputs
        - master_deploymentclient

    - Upload to etc/system/local
        - cm-global-banner.conf

    - Upload to etc/apps MC
        - cluster_search_base

    - Upload to etc/system/local
        - mc-global-banner.conf
        - serverclass.conf

    - Upload to etc/deployment-apps on MC
        - all_indexes
        - search_volume
        - all deploymentclients
        - indexer_base
        - all inputs-prop
        - indexer_volume

    - Upload to etc/apps on IDXs
        - cluster_indexer_base

    - Restart splunk on all servers

# Add search peers
    - Add CM, SH on MC
     for src_ip in 10.0.3.8 10.0.3.1; do ./splunk add search-server $src_ip:8089 -remoteUsername admin -remotePassword ExpertInsight; done

# Add to Monitoring Console
    - Check if IDXs are listening 
        - ./splunk display listen
    - Make server roles are updated for MC Setup
        - LICENSE
            - DS, LC, SH
        - CM
            - SH, CM
        - SH
            - SH
        - IDX
            - IDX, KV
    - Add to MC
        - Settings, Forwarder Monitoring Setup
        - Enable Forwarder Monitoring
        - restart fwdrs

# Create serverclasses
    ** Add apps to serverclass first, configure restart, update serverclass.conf then add clients **

    - Name: cluster_manager
      Clients: CM
      Apps:
        - all_indexes           | yes
        - cluster_indexer_base  | yes
        - search_volume_indexes
        - cisco_mail_idx_props  | yes
        - cisco_mail_props
        - dcrusher_idx_props    | yes
        - dcrusher_props
        - cisco_web_props
        - os_props

    - Name: forwarder
        Clients: fwdrs
        - all_deploymentclients | yes
        - forwarder_outputs     | yes
        - access_inputs
        - cisco_mail_inputs
        - cisco_web_inputs
        - dcrusher_inputs
        - Splunk_TA

    - Name: search_head
      Clients: sh
      Apps:
        - all_deploymentclients | yes
        - cluster_search_base 
        - all_indexes           | yes
        - search_volume_indexes
        - forwarder_outputs     | yes
        - cisco_mail_idx_props  | yes
        - cisco_mail_props
        - dcrusher_idx_props    | yes
        - dcrusher_props
        - cisco_web_props
        - os_props
  
# Update CM classes 
- Go to /opt/splunk/etc/system/local on MC
- update serverclass.conf to cluster_manager classes
    - `stateOnClient=noop`
    - `restartSplunkd=0`      
- Restart splunk on MC/SH/CM
- Push bundle on CM 

# Reingest data
*****If gamelog isn't ingesting******
- Stop splunk
- Run this script
    - ./splunk cmd btprobe -d /opt/splunkforwarder/var/lib/splunk/fishbucket/splunk_private_db --file /opt/log/crashlog/dreamcrusher.xml --reset
- Start Splunk
*****If that doesn't work delete the index******
- Update inputs.conf
- Restart deploy server
- put CM in maintenance mode
- stop forwarders
- stop indexers
- clear data in a single index on indexers
    - ./splunk clean eventdata -index gamelog os network -f
- clear fishbucket on forwarders
    cd /opt/splunkforwarder/var/lib/splunk/ && rm -r fishbucket && cd /opt/splunkforwarder/bin/
- start everything

# Enable non-root user boot start
**stop splunk**
    - upload `splunk` file
        - sh 4-enable-boot.sh
    - Run as non-root user
        - useradd splunk
        - passwd splunk
        - chown -R splunk:splunk /opt/splunk/
        - su - splunk
        - /opt/splunk/bin/splunk start
    - Configure boot-start
        - /opt/splunk/bin/splunk enable boot-start -user splunk
        - chown -R splunk:splunk /opt/splunk/
        - mv ~/nrb.tmp /etc/init.d/splunk
