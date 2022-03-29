# NAKIA
This is the configuration for Core Implementation Lab 3
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
1. Fix data ingestion issues
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

You will need to ingest logs (contained within /var/log) and assign their sourcetypes as appropriate. The files in question are the maillog file(s) and the cloud-init.log. We would like them to be assigned as the maillog and cloud-init sourcetypes respectively.

They would also like you to onboard appserver logs from /var/data/appserver into Splunk. They should show up as the sourcetype **appserver**. Please make sure your configuration continues to work when the logs are rolled on a daily basis.

The document here ([Fishbucket_Use_Cases.pdf](https://pslearning.splunkoxygen.com/en-US/static/app/overlord/lab_docs/Fishbucket_Use_Cases.pdf)) may help you with troubleshooting any issues that may arise. This REST document [Foundational_Concepts_FDC0004_REST.pdf](https://pslearning.splunkoxygen.com/en-US/static/app/overlord/lab_docs/Foundational_Concepts_FDC0004_REST.pdf) may also help here (in particular the TailingProcessor). The built-in command **splunk list inputstatus** may also provide some clues.
As an added note, the files might not be readable by the splunk user, so you will need to address this appropriately.
