# Networking

## Underlying Virtual Networks

For the public clouds there are additional considerations such as VPCs, security groups, subnets and so on. It's too much to go into here. See the deployment guide for public clouds[](../Deployment/Public-Clouds.md) to see what is needed.

Networking options are also detailed out in the [Profile Configuration guide](../Deployment/Configuration-Options.md).

!!! danger "important"
    Ensure that you don't expose services to the public! Ensure your security groups are configured correctly to only allow a range of IPs access, and not the whole world.

!!! danger "important"
    The VirtualBox solution is the only one that is started with two NICs! This can have implication on listening services listening on the wrong one. Be sure to always have your service listening on `enp0s8`. `enp0s3` is the NAT NIC, and is not reachable from the other nodes.

    If all you are doing is deploying a service to Kubernetes, then you don't need to worry about this, as it is already taken care of for the core services.  

## Kubernetes Networking

Networking in Kubernetes is handled by [Calico](https://www.tigera.io/project-calico/){:target="\_blank"} and installed via the following [installation scripts](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/calico-network){:target="\_blank"}

## Domain Name Resolution

Domain name resolution is carried out by an installed [Bind9](https://www.isc.org/bind/){:target="\_blank"} instance, installed via the script [configureBindDnsServer.sh](https://github.com/Accenture/kx.as.code/blob/main/auto-setup/functions/configureBindDnsServer.sh){:target="\_blank"} (for more details see [`configureBindDns()` in Central Functions documentation](../Development/Central-Functions.md#configurebinddns){:target="\_blank"}).

The domain configured in Bind9 is the one that was either configured via the Jenkins based launcher or directly in `profile-config.json` (FQDN is `*.<environment prefix>.<base domain>`).
The relevant properties in profile-config.json are `config.environmentPrefix` + `config.baseDomain`.

All KX-Main nodes have a Bind9 instance installed and synchronize with each other.

When a node comes up, it automatically registers itself with the Bind9 instance on KX-Main1, which is subsequently synchronized with the other nodes.

## Using an external DNS service

If you want to use an external DNS server for a private or cloud DNS setup, you have two options.

### Manual IP Configuration

Use the static IP configuration method, which allows you to define both the IP address and the DNS servers to use.

### Hybrid Mode

This keeps the DNS servers receive from DHCP, and appends the KX.AS.CODE DNS servers. The dependency here is that the DHCP server is configured with the DNS server you wish to use for KX.AS.CODE.
To configure `hybrid` mode, set the value for `config.dnsResolution` to hybris in `profile-config.json`.
