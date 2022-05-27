#!/bin/bash
# use password instead of pem file
# enable Password Authentication
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
 
# create password for ec2-user
echo splunk3du | passwd ec2-user --stdin

# create sccStudent & ansible user
adduser sccStudent
adduser ansible
echo splunk3du | passwd sccStudent --stdin
echo "sccStudent  ALL=(ALL)  ALL" | sudo tee /etc/sudoers.d/splunk
echo "ansible  ALL=(ALL)  ALL" | sudo tee -a /etc/sudoers.d/splunk

#create user, splunk
adduser splunk
 
# restart service for Password Auth to take effect
service sshd restart

#install services
amazon-linux-extras install epel -y
yum install ansible -y

# update package
yum update -y

# get the list of AWS private IPs
#!/bin/bash
AWS_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//'`
SG_NAME=`curl -s http://169.254.169.254/latest/meta-data/security-groups`
CURRENT_INSTANCE=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
SUBNET_ID=`aws ec2 describe-instances --filter Name=instance-id,Values=$CURRENT_INSTANCE --query Reservations[*].Instances[*].SubnetId --output=text --region=$AWS_REGION`
INSTANCE_IDS=($(aws ec2 describe-instances --filter "Name=network-interface.subnet-id,Values="$SUBNET_ID --query "Reservations[*][].Instances[*][].{Instance: InstanceId}" --output=text --region=$AWS_REGION))

for x in "${INSTANCE_IDS[@]}"; do aws ec2 create-tags --resources $x --tags Key=createdBy,Value=ansible --region=$AWS_REGION; done

# create the inventory list
aws ec2 describe-instances --filter "Name=network-interface.subnet-id,Values="$SUBNET_ID --query Reservations[*].Instances[*].PrivateIpAddress --output=text --region=$AWS_REGION > /home/ansible/tmp.list
sed -e "s/\t/\n/g" < /home/ansible/tmp.list > /home/ansible/sort.list
sort -t . -g -k4,4 /home/ansible/sort.list > /home/ansible/ip.list
rm /home/ansible/tmp.list /home/ansible/sort.list

IP_LIST=/home/ansible/ip.list
INVENTORY_FILE=/home/ansible/inventory
setfacl -m u:root:rwx /home/ansible/
mapfile -t ips < $IP_LIST
CURRENT_SERVER=`hostname -I`
NUMBER_OF_IPS=${#ips[@]}
i=0
j=1
k=0
#!/bin/bash
AWS_REGION=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed s'/.$//'`
SG_NAME=`curl -s http://169.254.169.254/latest/meta-data/security-groups`
CURRENT_INSTANCE=`curl -s http://169.254.169.254/latest/meta-data/instance-id`
SUBNET_ID=`aws ec2 describe-instances --filter Name=instance-id,Values=$CURRENT_INSTANCE --query Reservations[*].Instances[*].SubnetId --output=text --region=$AWS_REGION`
INSTANCE_IDS=($(aws ec2 describe-instances --filter "Name=network-interface.subnet-id,Values="$SUBNET_ID --query "Reservations[*][].Instances[*][].{Instance: InstanceId}" --output=text --region=$AWS_REGION))

# for x in "${INSTANCE_IDS[@]}"; do aws ec2 create-tags --resources $x --tags Key=createdBy,Value=ansible --region=$AWS_REGION; done

# create the inventory list
aws ec2 describe-instances --filter "Name=network-interface.subnet-id,Values="$SUBNET_ID --query Reservations[*].Instances[*].PrivateIpAddress --output=text --region=$AWS_REGION > /home/ansible/tmp.list
sed -e "s/\t/\n/g" < /home/ansible/tmp.list > /home/ansible/sort.list
sort -t . -g -k4,4 /home/ansible/sort.list > /home/ansible/ip.list
rm /home/ansible/tmp.list /home/ansible/sort.list

IP_LIST=/home/ansible/ip.list
INVENTORY_FILE=/home/ansible/inventory
setfacl -m u:root:rwx /home/ansible/
mapfile -t ips < $IP_LIST
CURRENT_SERVER=`hostname -I`
NUMBER_OF_IPS=${#ips[@]}
i=0
j=1
k=0

# set roles

if [ $NUMBER_OF_IPS = 8 ]; then roles=(MC SH CM IDX1 IDX2 HF UF); elif [ $NUMBER_OF_IPS = 9 ]; then roles=(MC SH1 CM IDX1 IDX2 HF UF SH2); elif [ $NUMBER_OF_IPS = 10 ]; then roles=(MC SH CM IDX1 IDX2 HF UF NEW1 NEW2); fi
   
# creates the inventory file
echo "[all_servers]"  > $INVENTORY_FILE

while [ $j -le $NUMBER_OF_IPS ]
do
    if [ $CURRENT_SERVER = "${ips[i]}" ]; then
            ((j++))
            ((i++))    
        else
            echo ${roles[k]} "ansible_host="${ips[i]} >> $INVENTORY_FILE
            x=`aws ec2 describe-instances --filter "Name=network-interface.addresses.private-ip-address,Values=${ips[i]}" --query "Reservations[*][].Instances[*][].{Instance: InstanceId}" --output=text --region=$AWS_REGION`
            # aws ec2 create-tags --resources $x --tags Key=Name,Value=${roles[k]} --region=$AWS_REGION
            ((i++))
            ((j++))
            ((k++))
    fi
done

n=2
echo "" >> $INVENTORY_FILE
echo "[base]"  >> $INVENTORY_FILE
while [ $n -le 6 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done

#forwarders
if [ $NUMBER_OF_IPS -le 8 ]; then
    n=7
    echo "" >> $INVENTORY_FILE
    echo "[heavy_forwarder]"  >> $INVENTORY_FILE
    while [ $n -le 7 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done

    n=8
    echo "" >> $INVENTORY_FILE
    echo "[forwarders]"  >> $INVENTORY_FILE
    while [ $n -le 8 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done

    else
        n=7
        echo "" >> $INVENTORY_FILE
        echo "[forwarders]"  >> $INVENTORY_FILE
        while [ $n -le 8 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done
fi

# search head
if [ $NUMBER_OF_IPS = 9 ]; then
    n=9
    echo "" >> $INVENTORY_FILE
    echo "[other]"  >> $INVENTORY_FILE
    while [ $n -le 9 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done
fi

# other: DS or IDX
if [ $NUMBER_OF_IPS = 10 ]; then
    n=9
    echo "" >> $INVENTORY_FILE
    echo "[other]"  >> $INVENTORY_FILE
    while [ $n -le 10 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done
fi

n=3
echo "" >> $INVENTORY_FILE
echo "[gamora]"  >> $INVENTORY_FILE
while [ $n -le 6 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done

n=2
echo "" >> $INVENTORY_FILE
echo "[wkabi]"  >> $INVENTORY_FILE
while [ $n -le 7 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done

n=2
echo "" >> $INVENTORY_FILE
echo "[ent]"  >> $INVENTORY_FILE
while [ $n -le 4 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done

n=5
echo "" >> $INVENTORY_FILE
echo "[indexers]"  >> $INVENTORY_FILE
while [ $n -le 6 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done  
if [ $NUMBER_OF_IPS = 10 ]; then
    n=9
    while [ $n -le 10 ]; do awk "FNR==$n{print;exit}" $INVENTORY_FILE >> $INVENTORY_FILE $(( n++ )); done
fi

#clone git
yum install git -y
cd /home/ansible/
git config --global user.email "eveal@splunk.com"
git config --global user.name "E Veal"
git clone -b wkabi https://github.com/e-veal/splunk-practice-lab
mv /home/ansible/splunk-practice-lab /home/ansible/build
mv /home/ansible/build/tasks/main.yml /home/ansible/build/tasks/main1.yml 
mv /home/ansible/build/vars/main.yml /home/ansible/build/vars/main1.yml 
ansible-galaxy init build --f
rm /home/ansible/build/tasks/main.yml
mv /home/ansible/build/tasks/main1.yml /home/ansible/build/tasks/main.yml 
mv /home/ansible/build/vars/main1.yml /home/ansible/build/vars/main.yml 
cd /home/ansible/build
git remote rm origin
rm -rf .git
rm -R /home/ansible/build/tests

# Download license
# cd ./files
# curl -H 'Authorization: token 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' -H 'Accept: application/vnd.github.v3.raw' -O -L https://api.github.com/e-veal/Splunk/blob/620b01e76fb4d9979d10396cfa66d02dedcaac62/Practice%20Ansible%20Environment/Splunk_Enterprise_NFR_FY23.lic

# create ssh-key
mkdir -p /home/ansible/.ssh
ssh-keygen -q -t rsa -N '' -f /home/ansible/.ssh/id_rsa <<< y

# create sshkey script
mapfile -t ips < $IP_LIST
echo '#!/bin/bash' > /home/ansible/copy_key.sh
for y in "${ips[@]}"; do echo 'sshpass -p splunk3du ssh-copy-id -o stricthostkeychecking=no '$y' <<<y' >> /home/ansible/copy_key.sh; done
echo 'rm /home/ansible/copy_key.sh' >> /home/ansible/copy_key.sh

# Clean up
rm /home/ansible/ip.list

# Update permissions
chown -R ansible:ansible /home/ansible
setfacl -Rm u:sccStudent:rwx /home/ansible/
chmod 600 /home/ansible/.ssh/id_rsa

# Set name of Ansible server in AWS
aws ec2 create-tags --resources `curl -s http://169.254.169.254/latest/meta-data/instance-id` --tags Key=Name,Value=AnsibleServer --region=$AWS_REGION