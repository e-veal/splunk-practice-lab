#!/bin/bash
# use password instead of pem file
# enable Password Authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
 
# create password for ec2-user
echo splunk3du | passwd ec2-user --stdin

# create sccStudent & ansible user
adduser sccStudent
adduser ansible
adduser splunk
echo splunk3du | passwd sccStudent --stdin
echo splunk3du | passwd ansible --stdin
echo splunk3du | passwd splunk --stdin
echo "sccStudent  ALL=(ALL)  ALL" | sudo tee /etc/sudoers.d/splunk
echo "ansible  ALL=(ALL)  ALL" | sudo tee -a /etc/sudoers.d/splunk

#create user, splunk
adduser splunk
 
# restart service for Password Auth to take effect
service sshd restart

# update package
yum update -y