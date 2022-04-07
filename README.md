# OKOYE
This is the configuration for Core Implementation Lab 4
> Note: Different OS version than actual

## Build Instructions
- Build 7 EC2s with `1-basic-splunk-image.sh`
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
1. Fix data ingestion issues
1. Ability to search on original forwarder
1. Ensure Monitoring Console is monitoring active servers
1. Ensure deployment server is configured properly

## Instructions
This lab simulates a customer problem with data on-boarding.

| Host Name| Role |
|------|------|
| SH | Search Head |
| MC | Monitoring Console |
| IDX1 | Indexer |
| IDX2 | Indexer |
| CM | Cluster Master |
| HF | Heavy Forwarder |
| UF | Universal Forwarder |

For this lab, the problem statement is as follows:
We used to have an input to read in data from `/var/data/syslog`. We want the default **syslog** sourcetype behavior to fire, where the ‘host’ field in Splunk is set to the hostname represented in the events themselves. For this customer, the event data shows the device name is **combo**, so if you see this as your host, your events are correct.

In addition, we want a custom indexed field to be created called `splunk_orig_fwd` to indicate the hostname of the forwarder that passed us the data. We set up the TRANSFORMS on the indexer, but couldn’t get it working. We've disabled the input.

Here success will be measured by your ability to meet the customer's request. The information contained here (docs:[indexed field extractions](https://docs.splunk.com/Documentation/Splunk/latest/Data/Aboutindexedfieldextraction)) may help you with meeting the customer request