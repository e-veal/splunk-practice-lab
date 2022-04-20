# GAMORA

This is the configuration for Core Implementation Lab 1
> Note: Different OS version than actual

## Build Instructions
- Build 7 EC2s with `1-basic-splunk-image.sh`
    - must have public IPs
    - at least 20GB for storage
- Wait for all to state Running
    - May need to refresh
- Build Ansible instance with `2-ansible-image.sh`
    - Wait for Ansible instance to be named **AnsibleServer** in AWS Mgmt Console (this will take a few minutes)
- Using a terminal, log into ANSIBLE box with sccStudent
    `ssh sccStudent@ANSIBLE_SERVER_PUBLIC_IP`
- Switch to ansible user (ansible doesn't [and shouldn't] have pwd)
    `sudo su - ansible`
- A script was created to copy ssh keys to other instances
    `bash ~/copy_key.sh`
- Build splunk
    `ansible-playbook ~/build/tasks/main.yml -i inventory -K`
    - Respond to password prompt
    - grab a cup of coffee; takes ~7 mins to complete (00:36-00:43)
---
## Lab Goals
1. Join Monitoring Console to Cluster Manager with same pass4Symm key
1. MC should be used as the license master
1. Ensure data is ingested properly (should be 3 indexes: os, mail, network)
1. Ensure Monitoring Console is monitoring all servers in the environment
1. Ensure deployment server is configured properly

## Instructions

This Lab will take you through discovering the clustering key for an existing cluster so you can add a new monitoring console node to it. This method will allow you to recover an encrypted password from an existing server and join a cluster without resetting all of the Pass4SymmKey values or making any other live changes in an existing indexer cluster.

| Host Name| Role |
|------|------|
| CM | Cluster Manager |
| MC | Monitoring Console |

## Install Splunk on your Monitoring Console Node

### Install Splunk - Do Not Start.

1. Install Splunk on your Monitoring Console node. Make sure not to start it.
2. Use the same steps to install splunk as in the first practice lab. (Splunk PS Architect Practice Lab 1 - Instructions)
3. Copy the splunk.secret file from `$SPLUNK_HOME/etc/auth/` on your cluster master node and place it in the same location on your new Monitoring Console node.
4. Once copied, start your new instance.
Take the hashed Pass4SymmKey value from the existing cluster master. Remember, btool is your friend.
5. Create a Splunk app `ci1_unhash_app` with an `passwords.conf` file containing a credential stanza with your reclaimed Pass4SymmKey.
6. Add the following to `$SPLUNK_HOME/etc/apps/ci1_unhash_app/local/passwords.conf`.
For example:

    ```
    [credential::test:]
    password = $pass4symmkeyvalue
    ```

7. Make sure you check the spec file in splunk or docs to understand the config you've added.
8. Use the following command to retrieve your credentials.
`$SPLUNK_HOME/bin/splunk _internal call /storage/passwords/test`
9. You can now use that value to join your new Monitoring Console node to your cluster.
10. The command above may not work in it's current form. Make sure you check your app permissions or adjust the command to match the namespace of your app.
11. Remember to use base configuration templates to complete the configuration of your Monitoring Console. You'll find all of the apps you'll need are already deployed to your clustered environment.
12. Once successfully joined to the cluster with a fully configure Monitoring Console, make sure that you delete the `ci1_unhash_app`.

### Configure the Monitoring Console
To monitor your configured environment, you will need to configure your Monitoring Console in distributed mode.

Further information on the Monitoring Console can be found here: http://docs.splunk.com/Documentation/Splunk/latest/DMC/DMCoverview

Instructions on configuring the Monitoring Console in distributed mode can be found here: http://docs.splunk.com/Documentation/Splunk/latest/DMC/Configureindistributedmode
