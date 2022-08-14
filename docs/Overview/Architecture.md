# Architecture

The image is now out of date and will be updated soon. In the meantime, here what has changed since.

### Changelog

- AWS and OpenStack enablement was completed
- DNSMASQ was switched to Bind9 for DNS replication
- XFCE desktop was changed to KDE Plasma
- Kubernetes was upgraded to v1.24, so Docker is not part of the runtime anymore
- A new skipped queue was added to RabbitMQ, to allow overall processing to continue, if a non-critical component fails to install successfully

### Diagram

[![Architecture](images/image-20201112132221706.png)](images/image-20201112132221706.png)

