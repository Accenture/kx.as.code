# User Guide



## Accessing KX.AS.CODE Remotely

There are three ways to access KX.AS.CODE remotely.

To reach them, the following ports needed to be opened and NATed.



Table: Remote desktop listening ports

| Technology                                       | Listening Port |
| ------------------------------------------------ | -------------- |
| Apache Guacamole - https://guacamole.apache.org/ | 8098 (TCP)     |
| TigerVNC - https://tigervnc.org/                 | 5901 (TCP)     |
| NoMachine - https://www.nomachine.com/           | 4000 (TCP/UDP) |



Here are the three options in detail:



##### Apache Guacamole

Whilst the performance of this option is the lowest of the three, the biggest advantage is that no client tools need to be installed to access this site. All you need is a browser and a route to the KX-Main server's Guacamole port.

This also has the advantage of SSL encryption between the client and the Guacamole server.



##### TigerVNC

This service is used by Guacamole to serve up the VNC traffic remotely via VNC. It is not setup securely, so it is not recommended to use this connection, except of local installations of KX.AS.CODE, where in most cases, remote access will not be needed, because the local virtualization tools provide direct access to the desktop.



##### NoMachine

NoMachine has it's own proprietary security transport protocol (read more [here](https://www.nomachine.com/AR10K00705)) and is the most performant of the options here.

This is the recommended solution of all three here, however, do to the restrictions often imposed on enterprise laptops, we also provide the option to use Guacamole's web based access to overcome that.
