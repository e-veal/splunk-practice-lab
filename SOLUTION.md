# SHURI SOLUTION

This is the solution for the `SHURI` Implementation Lab.

## Instructions

 ### Recreate serverclass.conf
 1. On each type of server (IDXs, SHs, etc) navigate to `/opt/splunk/var/run/serverclass.xml`
    
    Here the names and attributes of the classes are listed.

    Recreate all classes with this format:
    ```
    [serverClass:all_deploymentclients:app:spe_all_deploymentclient]
    restartSplunkd = 0
    restartSplunkWeb=0
    stateOnClient=enabled
    ```

    Ensure all_deploymentclients serverclass has restartSplunkd enabled.

1. Upload serverclass.conf to DS1 and DS2 manually
    - `rsync -a serverclass.conf --exclude 'Icon*' --exclude '.DS_Store' splunk@<Public IP of DS1 & DS2>:/opt/splunk/etc/system/local/`
    - either run same command for DS2 or copy from DS1 to DS2

### Create deploymentclient.conf & serverclass.conf for DS2
1. Create a copy of the deploymentclient app on DS2
    - From DS1, run this command:
    `rsync -a /opt/splunk/etc/deployment-apps/spe_all_deploymentclient splunk@<Internal IP of DS2>:/opt/splunk/etc/apps/`
1. Update `deploymentclient.conf` on DS2 to include the following stanza
    ```
    [deployment-client]
    repositoryLocation = $SPLUNK_HOME/etc/deployment-apps
    serverRepositoryLocationPolicy = rejectAlways
    ```
1. Update `serverclass.conf` on DS1 to include the following stanza then copy to DS2:
    ```
    [global]
    crossServerChecksum = true
    ```
    - `rsync -a /opt/splunk/etc/system/local/serverclass.conf splunk@<Internal IP of DS2>:/opt/splunk/etc/system/local/`
    
1. Restart Splunk on DS2
    - Since a new app was added, requires a [restart](https://docs.splunk.com/Documentation/Splunk/8.2.6/Updating/Configuredeploymentclients#View_clients_from_the_deployment_server) 
    - **Wait a few minutes for server to phone home**

1. Reload DS1
    - To rebuild serverclasses
        `/opt/splunk/bin/splunk reload deploy-server -auth admin:splunk3du

### Configure
1. Once DS2 phone's home to DS1, create a new serverclass for DS2 where it holds all the apps (or you can include when creating serverclass.conf)
### Verify manual app deployment

1. Log onto DS2 to ensure **Forwarder Management** console loads

1. Confirm that all apps deployed to `deployment-apps`
    - Way 1: Check if apps exist on Forwarder Management console.
    - Way 2: Check `/opt/splunk/etc/deployment-apps/`

### Test DS2

1. On DS1 & DS2, open **Search & Reporting**
1. Execute the following command

    `| rest /services/deployment/server/applications`

1. On DS1, manually, update `deploymentclient.conf` to point to DS2
    ```
    targetUri = <IP of DS2>
    ```
1. 