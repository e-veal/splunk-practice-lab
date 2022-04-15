# Shuri
This is the configuration for Core Implementation Lab 5
> Note: Different OS version than actual
## Build Instructions
- Build 9 EC2s with `1-basic-splunk-image.sh`
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
    - grab a cup of coffee; takes ~7 mins to complete (00:36-00:43)

---
## Lab Goals
1. Recreate the serverclass.conf file
1. Copy apps to DS2 without doing it manually
1. Switch deployment clients to DS2
1. Ensure Monitoring Console is monitoring active servers
1. Ensure deployment server is configured properly

## Instructions
Deployment Server scaling in practice.

| Host Name| Role |
|------|------|
| SH | Search Head |
| MC | Monitoring Console |
| IDX1 | Indexer |
| IDX2 | Indexer |
| CM | Cluster Master |
| HF | Heavy Forwarder |
| UF | Universal Forwarder |
| DS1 | Deployment Server 1 |
| DS2 | Deployment Server 2 |

## Configure your DS for scaling/failover

The DS1 instance shown above is your "original" DS instance. It's got a bunch of apps on it, ready for deployment. Unfortunately the serverclass.conf was accidentally deleted, so class mappings to apps are gone. You'll need to recreate one in addition to whatever else you may need to do.

You'll want to synchronize the deployment apps to the DS2 instance, **without manually copying** them over. This needs to be an automated process, where the "master copy" remains on DS1. Your goal is to make sure that a DS client phoning home to either DS would get the **same** content, and has the **same** checksum. We will be checking for the existence of certain apps on your DS instances, and that they return the same checksum.

In a real production environment, you would additionally need to solve the load balancer layer, but for this lab we will skip that step. We have also purposefully ignored the synchronization of the serverclass.conf (once you rebuild it) and left that as a take home exercise. For the lab, this is the one element you are allowed to manually copy.
Finally, this REST endpoint (when run against each DS) may help you verify if the synchronization was done correctly

[deployment/server/application](https://docs.splunk.com/Documentation/Splunk/latest/RESTREF/RESTdeploy#deployment.2Fserver.2Fapplications)