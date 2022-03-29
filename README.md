# WKABI
This is the configuration for Core Implementation Lab 7
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
1. Add new indexers to cluster
1. Remove old peers
1. Ensure data is forwarding to new peers
1. Ensure Monitoring Console is monitoring active servers
1. Ensure deployment server is configured properly

## Instructions
For this lab, you will be performing a hardware replacement of your indexing tier by first expanding your indexing cluster, then migrating the data to new hardware, and then finally decommissioning the older gear.

| Host Name| Role |
|------|------|
| SH | Search Head |
| MC | Monitoring Console |
| IDX1 | Indexer |
| IDX2 | Indexer |
| NEW1 | Indexer |
| NEW2 | Indexer |
| CM | Cluster Master |
| HF | Heavy Forwarder |
| UF | Universal Forwarder |

**Customer**: *Our indexing tier is having performance problems. Let's replace the indexers with new faster ones.*

The first step is to add the new indexers NEW1 and NEW2 (listed above) to your environment **mimicking exactly** the configuration of the existing indexers. This is **not solely** the cluster-bundle, you should look for existing apps that aren’t part of the base Splunk package. It's unclear if you're receiving brand new servers, or if you're re-using systems, so make sure to check.

Next, you will place your old indexers in detention (link to Da Xu’s talk below). Then, you will direct your legacy (IDX1, IDX2) indexers to `offline --enforce-counts` to shut them down gracefully, which will trigger the CM to *fix* these buckets over to the new hardware.

Read the PDF carefully, as well as look in docs. This is a live production system, so exercise prudence and caution. It is in your best interests to not rush the steps, and ensure each node is fully dealt with before calling the lab complete. Finally, docs provides detailed instruction for post-offline steps as well. Consider performing these steps as well.

- [Da Xu’s talk](http://conf.splunk.com/files/2016/slides/indexer-clustering-internals-scaling-andperformance.pdf)
- [Putting an indexer into detention](http://docs.splunk.com/Documentation/Splunk/latest/RESTREF/RESTcluster#cluster.2Fslave.2Fcontrol.2Fcontrol.2Fset_detention_override)
