# TCHALLA SOLUTION

This is the solution for the `TCHALLA` Implementation Lab.

## Instructions

> Note: Check the version of the system first.

> Note: System must be upgrade in this order CM, SH, MC, IDXs, everything else

> [Helpful Documentation](https://docs.splunk.com/Documentation/Splunk/latest/Installation/HowtoupgradeSplunk#Splunk_Enterprise_upgrade_process)

### Upgrade CM
> Note: [Upgrade cluster documentation](https://docs.splunk.com/Documentation/Splunk/8.2.6/Indexer/Upgradeacluster#Upgrade_each_tier_separately)
1. Verify the version of Splunk (v.8.0.5)
    - This version does not require 2 upgrades accordinging to the [Splunk Upgrade Path](https://docs.splunk.com/Documentation/Splunk/latest/Installation/HowtoupgradeSplunk#Upgrade_information_for_version_8.2)

1. Stop Splunk service
    ```
    /opt/splunk/bin/splunk stop
    ```
1. Download latest Splunk
    ```
    wget -O splunk-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz "https://download.splunk.com/products/splunk/releases/8.2.6/linux/splunk-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz"
    ```
1. Untar file
    ```
    tar -xzvf splunk-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz -C /opt
    ```

1. Start Splunk service
    ```
    /opt/splunk/bin/splunk start --accept-license --answer-yes --auto-ports --no-prompt --seed-passwd <adminPwd>
    ```
1. Delete installation file
    ```
    rm splunk-8.2.6-a6fe1ee8894b-Linux-x86_64.tgz
    ```
1. Verify Cluster Manager 
    - Wait for all instances to come online
    - Verify version

### Upgrade SH & MC

> Note: Check if its a SHC

1. Stop Splunk Service
1. Download & Install Splunk 
1. Upgrade Splunk on SH and MC
1. Start Splunk Service
1. Verify SH & MC show on CM

### Upgrade Indexers

> Note: Indexers **_must_** be configured one at a time.

1. Put CM in maintenance mode
    ```
    /opt/splunk/bin/splunk enable maintenance-mode --answer-yes -auth admin:<adminPwd>
    ```
1. Stop Splunk

1. Download & Install Splunk 

1. Upgrade Splunk

1. Start Splunk Service

1. Take CM out of maintenance mode
    ```
    /opt/splunk/bin/splunk disable maintenance-mode --answer-yes -auth admin:<adminPwd>
    ```
1. Verify installation
    ```
    /opt/splunk/bin/splunk version