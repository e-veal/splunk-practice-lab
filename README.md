# T'challa
This is the configuration for Core Implementation Lab 6
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
1. Upgrade to the **_latest_** version of Splunk
1. All data must be readable during upgrade
1. Ensure Monitoring Console is monitoring active servers
1. Ensure deployment server is configured properly

## Instructions
Upgrade to the latest release.

| Host Name| Role |
|------|------|
| SH | Search Head |
| MC | Monitoring Console |
| IDX1 | Indexer |
| IDX2 | Indexer |
| CM | Cluster Master |
| HF | Heavy Forwarder |
| UF | Universal Forwarder |

You've just received notice of a new release of Splunk, and your customer is extremely excited to get on the latest and greatest version, huzzah!

For this lab you are to upgrade your environment, in the correct order, to the latest version of Splunk Enterprise. You are required to upgrade the MC, CM, SH and indexers. The rest of the systems may be upgraded at your leisure for (no) bonus credit. Since your systems are all 64bit, please use the correct version of the download.

As a hint, it may be a good idea to locate the wget url for the download and use that to stream the install to your systems, also the tarball version is the preferred method. "wget" might not be available, so you may need to install it using your sudo privileges. Your systems are running a Redhat variant, so the command to install wget would be `yum install wget`