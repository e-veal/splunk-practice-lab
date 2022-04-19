# Zuri
This is the configuration for Core Implementation Lab 8
> Note: Different OS version than actual
## Build Instructions
- <font size=3 color=blue>**Add LDAP port 389 to security group**</font>
- Build 8 EC2s with `1-basic-splunk-image.sh`
    - must have public IPs
    - at least 10GB for storage
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
    - grab a cup of coffee; takes ~7 mins to complete

---
## Lab Goals
1. Create Search Head cluster with 2 nodes
1. Add Fire Brigade app
1. Add user to app according to customer request
1. Ensure Monitoring Console is monitoring all servers in the environment
1. Ensure deployment server is configured properly

## Instructions
For our final lab, you will be setting up a search head cluster using the systems listed below.

| Host Name| Role |
|------|------|
| SH1 | Search Head 1 |
| SH2 | Search Head 2 |
| MC | Monitoring Console & SHC Deployer |
| IDX1 | Indexer |
| IDX2 | Indexer |
| CM | Cluster Master |
| HF | Heavy Forwarder |
| UF | Universal Forwarder |
| LDAP | LDAP Server |

| LDAP Server ||
|---|---|
| **Server** | ldap.forumsys.com  |

## Who wants to be captain?
In addition to the SHC provisioning, the customer has requested the following: 

> _"Our Splunk admins are very concerned about managing our data retention policies and ensuring we have adequate storage space to accommodate our needs. We have a requirement to maintain indexed data for a certain amount of time. The admins have requested that you deploy the Fire Brigade app on the search head cluster, and to set it up according to the docs."_
>   
> _"However, we don't want them to have **admin** privileges on our cluster, so please make it so that they can access everything they need for the Fire Brigade app to function (including access to the Search app), but nothing else. They mentioned needing "admin" but I don't believe them. They'll be allowed to access the SHC via LDAP and should belong to the "Instructors" group and mapped to an "instructor" role._

You will need to build out a new search head cluster by following the procedure documented [here](http://docs.splunk.com/Documentation/Splunk/latest/DistSearch/SHCdeploymentoverview). From the instances listed above, you will use **SH1** and **SH2** as your SHC nodes, and your **MC** instance will take the deployer role. The documentation will mention that three nodes are the minimum for a healthy SHC, but for the purposes of the lab, you will only have two. You will need to consider what this means with respect to the stated procedure. You do NOT need to use static captain.

The firewall port 9887 has been opened for SHC replication.

While base configs for setting up an SHC do not exist (for good reasons), there are base configs elements that should be used. You will need to discover which ones are appropriate and deploy to the SHC. Employ PS sanctioned practices here.

You will need to use the LDAP configuration base app you configured and downloaded in Lab 2.

Note that your new LDAP server has a new DNS name and IP, so your app will need to be updated accordingly.

As an added note, the customer's added requirement is important, read carefully and make sure you have covered all bases before turning in your work. Some convenience links for you:
- [Fire Brigade](https://splunkbase.splunk.com/app/1581/)
- [Technology Add-on for Fire Brigade](https://splunkbase.splunk.com/app/1564/)

Finally, in order for your self check to work, you will need to make sure all related roles are correctly applied in the MC's settings. (hint: there are three instances that need to be checked)