# M'BAKU

This is the configuration for Core Implementation Lab 2
> Note: Different OS version and LDAP server

## Build Instructions
- <font size=3 color=blue>**Add LDAP port 389 to security group**</font>
- Build 1 EC2s with `1-basic-splunk-image.sh`
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
---
## Lab Goals
1. Configure Splunk to pull in users from LDAP server
1. Create a new role 

## Instructions
For our final lab, you will be setting up a search head cluster using the systems listed below.

| Host Name| Role |
|------|------|
| AIO | All In One Splunk Instance|
| LDAP | LDAP Server|

| LDAP Server ||
|---|---|
| **Server** | ipa.demo1.freeipa.org  |

## Configure LDAP Authentication
Listed below are the important bits of LDAP specific information you will need to complete this lab:
- The **bindDN** is `uid=admin,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org`
- For your user to be able to log in, you will need to assign either the **mail** or the **uid** as the login credentials.
- Assign the **_employee_** the admin role by creating a new role **Student**
- Users are in the `ou=users` container under the domain.
- Finally, the **list of groups** (which you will match to roles) is within the `ou=groups` under that container.
- The full domain is `cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org`.
- All LDAP passwords is `Secret123` 
- Once your lab is complete make sure you have downloaded your LDAP base configuration app for use in a future lab

**Convenient links**
- [Base Configs](https://drive.google.com/drive/folders/107qWrfsv17j5bLxc21ymTagjtHG0AobF)
- [Index Replication Configs](https://drive.google.com/drive/folders/10aVQXjbgQC99b9InTvncrLFWUrXci3gz)