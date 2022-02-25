# GAMORA

This is the configuration for Core Implementation Lab 1
Note:
- Different OS version than actual

## Instructions
1. Install splunk on your Monitoring console node. Make sure not to start it.
2. Use the same steps to install splunk as in the first practice lab.
3. Copy the splunk.secret file from `$SPLUNK_HOME/etc/auth/` on your cluster master node and place it in the same location on your new Monitoring Console node.
4. Once copied, start your new instance.
Take the hashed Pass4SymmKey value from the existing cluster master. Remember, btool is your friend.
5. Create a Splunk app `ci1_unhash_app` with an `passwords.conf` file containing a credential stanza with your reclaimed Pass4SymmKey.
6. Add the following to `$SPLUNK_HOME/etc/apps/ci1_unhash_app/local/passwords.conf`.
For example:

    ```
    [credential::test:]
    password = $pass4symmkeyvalue
    ```

7. Make sure you check the spec file in splunk or docs to understand the config you've added.
8. Use the following command to retrieve your credentials.
`$SPLUNK_HOME/bin/splunk _internal call /storage/passwords/test`
9. You can now use that value to join your new Monitoring console node to your cluster.
10. The command above may not work in it's current form. Make sure you check your app permissions or adjust the command to match the namespace of your app.
11. Remember to use base configuration templates to complete the configuration of your MC. You'll find all of the apps you'll need are already deployed to your clustered environment.
12. Once successfully joined to the cluster with a fully configure monitoring console, make sure that you delete the ci1_unhash_app.

### Configure the Monitoring Console
To monitor your configured environment, you will need to configure your monitoring console in distributed mode.

Further information on the Monitoring Console can be found here: http://docs.splunk.com/Documentation/Splunk/latest/DMC/DMCoverview

Instructions on configuring the monitoring Console in distributed mode can be found here: http://docs.splunk.com/Documentation/Splunk/latest/DMC/Configureindistributedmode
