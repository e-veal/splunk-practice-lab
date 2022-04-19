# MBAKU SOLUTION

## Instructions

## Configure LDAP authentication
1. Log into Splunk Web
1. Navigate to **Settings**, **Authenication Methods**
1. Select **LDAP**
1. Click on the link **Configure Splunk to use LDAP**
1. Click on the **New LDAP** button in the top right corner
1. Configure the application with these settings:

| Name | Setting |
| --- | --- |
| LDAP strategy name | spe_auth_ldap (this can be anything) |
| Host | ipa.demo1.freeipa.org |
| Bind DN | uid=admin,cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org |
| Bind DN password | Secret123 |
| User base DN | cn=users,cn=accounts,dc=demo1,dc=freeipa,dc=org |
| User name attribute | uid |
| Real name attribute | cn |
| Group base DN | cn=groups,cn=accounts,dc=demo1,dc=freeipa,dc=org |
| Group name attribute | cn |
| Static member attribute | cn |

## Create new role
1. Navigate to **Settings**, **Roles**
1. Click **Create Role** in top right
1. Create **Student** role

## Map role
1. Navigate back to **Settings**, **Authenication Methods**
1. Click on **LDAP Settings** link
1. Select **Map groups**
1. Select **employee**
1. Grant it to the **student** role

## Test
1. Log out of Splunk
1. Log back in with the following credentials:
    ```
    username: employee
    password: Secret123
    ```
