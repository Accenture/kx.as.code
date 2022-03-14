# Troubleshootings

## RabbitMQ
### Problem: Messages in pending queue not consumed
- No application installation triggered.

*Solution 1:*
- Check if messages are in failed queue. If yes, move messages to pending queue.

*Solution 2:*
- Execute `pollActionQueue.sh`
  - ```$ /usr/share/kx.as.code/git/kx.as.code/auto-setup/pollActionQueue.sh```
  - *Note:* Run as sudo user inside KX.AS Code VM. May need to disconnect from VPN. 
