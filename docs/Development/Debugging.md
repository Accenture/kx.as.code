# Debugging

All component installations get their own log file placed in the `/usr/share/kx.as.code/workspace` directory. This directory includes everything needed for debugging a component installation, including generated scripts and configuration files used during the installation process.

If there is something wrong with the base setup, you may also want to look at the system log `/var/log/syslog`.

To figure out why something is failing, it may also be an idea to stop the KX.AS.CODE queue poller service, and start it manually, in order to be able to see live what is going on.

```bash
# Switch to the root user
sudo su

# Stop the service
systemctl stop kxAsCodeQueuePoller.service

# Start the KX.AS.CODE Action Queue Poller manually for live viewing
/bin/bash -x /usr/share/kx.as.code/git/kx.as.code/auto-setup/pollActionQueue.sh
```