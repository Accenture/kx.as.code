# Remote Access

There are two approaches to accessing applications remotely.

1. Access the application URLs directly remotely

2. Access the desktop remotely

This document describes number 2. For accessing the applications outside of the VM, see the following [guide](../../Deployment/External-Application-Access/).


## Accessing KX.AS.CODE Desktop Remotely

There are three ways to access KX.AS.CODE remotely.

The solutions are installed via scripts in the following [GitHub location](https://github.com/Accenture/kx.as.code/tree/main/auto-setup/core/remote-desktop){:target="\_blank"}.

To reach them, the following ports needed to be opened and NATed.



Table: Remote desktop listening ports

| Technology                                       | Listening Port |
| ------------------------------------------------ | -------------- |
| Apache Guacamole - https://guacamole.apache.org/ | 8043 (TCP)     |
| TigerVNC - https://tigervnc.org/                 | 5901 (TCP)     |
| NoMachine - https://www.nomachine.com/           | 4000 (TCP/UDP) |



Here are the three options in detail:



#### Apache Guacamole

Whilst the performance of this option is the lowest of the three, the biggest advantage is that no client tools need to be installed to access this site. All you need is a browser and a route to the KX-Main server's Guacamole port.
It also has the advantage of being 2FA enabled, so is the most secure of the three. It is also multi-user capable, unlike with the faster NoMachine (the free version included in KX.AS.CODE). 

This also has the advantage of SSL encryption between the client and the Guacamole server.

For more information, see the code linked above, and visit [Guacamole's site](https://guacamole.apache.org/){:target="\_blank"}.


#### TigerVNC

This service is used by Guacamole to serve up the VNC traffic remotely via VNC. It is not setup securely, so it is not recommended to use this connection, except for local installations of KX.AS.CODE, where in most cases, remote access will not be needed, because the local virtualization tools provide direct access to the desktop.

To access the VNC desktop, you will need a VNC client. There are a few available, but here is one we have used in the past - [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/){:target="\_blank"}.

Read more about TigerVNC [here](https://tigervnc.org/){:target="\_blank"}.

#### NoMachine

NoMachine has its own proprietary security transport protocol (read more [here](https://www.nomachine.com/AR10K00705){:target="\_blank"}) and is the most performant of the options here.

This is the recommended remote desktop solution, however, please note the free version has several restrictions - 1. no multi-user support, 2. requires a dedicated client to be installed.

You can download NoMachine [here](https://www.nomachine.com/download).