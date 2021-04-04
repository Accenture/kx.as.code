#!/bin/bash -x

# Create and configure XRDP connection in Guacamole database
echo """
INSERT INTO public.guacamole_connection(
        connection_name, protocol)
        VALUES ('rdp', 'rdp');

INSERT INTO public.guacamole_connection_group(
        connection_group_name, type)
        VALUES ('kx-as-code', 'ORGANIZATIONAL');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'hostname', 'localhost');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'port', '3389');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'ignore-cert', 'true');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'security', 'any');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'disable-audio', 'true');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'disable-security', 'false');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'username', '\${GUAC_USERNAME}');

INSERT INTO public.guacamole_connection_parameter(
        connection_id, parameter_name, parameter_value)
        VALUES (1, 'password', '\${GUAC_PASSWORD}');

""" | sudo su - postgres -c "psql -U postgres -d guacamole_db" -

# Restart services
systemctl restart tomcat9
systemctl restart guacd
systemctl restart xrdp.service
systemctl restart xrdp-sesman.service