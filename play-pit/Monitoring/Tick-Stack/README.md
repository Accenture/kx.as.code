!["kx.as.code_logo"](../../../kxascode_logo_black_small.png "kx.as.code_logo")

## Description

TICK Stack is an open-source performance monitoring tool. It consists of 4 components; Telegraf, Influxdb, Chronograf and Kapacitor.

## Screenshot

!["screenshot"](screenshot-cronograf.png "screenshot")

## Metdata

- Author: [Patrick Delamere](mailto:patrick.g.delamere@accenture.com)
- Code Link: [GitLab Repository](https://dev.ares.accenture.com/gitlab/kx.as.code/kx.as.code/-/tree/master/play-pit/02_Monitoring/03_Tick-Stack)
- VM Location: `/home/kx.hero/Documents/kx.as.code_source/play-pit/02_Monitoring/03_Tick-Stack`
- Application URL: [https://chronograf.kx-as-code.local](https://chronograf.kx-as-code.local)

## Architecture

This setup consists of the full Tick-Stack - Telegraf, Influxdb, Chronograf and Kapacitor.

- `Telegraf` is the data collection engine
- `InfluxDB` is the time series database
- `Chronograf` is the frontend visualization GUI
- `Kapacitor` is the data processing engine.

For an indepth description of each component, visit the following site: [Tick-Stack Overview](https://www.influxdata.com/time-series-platform/)

## Assumptions

Docker and Kubernetes is installed and working.

## Required Components

- Docker
- Kubernetes
- Helm
- Kubectl
- Internet Access (to pull images from docker.io)

## Important Information / Pitfalls

Nothing for the current basic setup.

## Installation

Navigate to the Tick-Stack directory and launch `./install.sh`

```bash
$ cd /home/kx.hero/Documents/kx.as.code_source/play-pit/02_Monitoring/03_Tick-Stack
$ ./install.sh
```
Once the deployment is done, you will see a new Chronograf icon on the desktop. Double click it to launch the Chronograf GUI.

## Configuration

When you first launch the Chronograf GUI, you will be asked to enter the connectivity details for InfluxDb and Kapacitor.

`NOTE:` The install script generates random credentials and drops `username.txt` and `password.txt` in the same folder from where you launched `install.sh`. Use these credentials when setting up the connectivity to the InfluxDb database.

Here a summary of the values you will need to enter during the initial configuration in KX.AS.CODE:

##### InfluxDb Connection

- InfluxDB Connection URL: `http://influxdb.tick-stack:8086`
- InfluxDB Connection Name: `InfluxDb`
- InfluxDB Connection Username: See `username.txt` as described above
- InfluxDB Connection Password: See `password.txt` as described above
- Telegraf Database Name: `telegraf`
- Default Retention Policy: `<leave blank>`

##### Kapacitor Connection

- Kapacitor Connection URL: `http://kapacitor-kapacitor.tick-stack:9092`
- Kapacitor Connection Name: `Kapacitor`

Once done, the configuration routine will already detect the system, Docker and Kubernetes data from Telegraf in the InfluxDb. Click on the Dashboards icon on the left and select any of the dashboards to view the data.

## Usage

Go to the following links for extensive documentation on how to use the four components of the Tick-Stack:

- [Chronograf Documentation](https://docs.influxdata.com/chronograf/v1.8/)
- [Telegraf Documentation](https://docs.influxdata.com/telegraf/v1.14/)
- [InfluxDb Documentation](https://docs.influxdata.com/influxdb/v1.8/)
- [Kapacitor Documentation](https://docs.influxdata.com/kapacitor/v1.5/)

### Troubleshooting

None at this time.

## Question?

:email: kx.as.code@accenture.com
