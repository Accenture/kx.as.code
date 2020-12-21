#!/bin/bash
sudo sh -c "echo '#!/bin/bash\n\n# The K8s TickStack must be deployed before this will work\n\ndocker run --rm -v \"/home/$VM_USER/KX_Share/sitespeed.io\":/sitespeed.io sitespeedio/sitespeed.io:13.3.0 https://empoweryou.accenture.com/ --influxdb.host influxdb.kx-as-code.local --influxdb.port 80 --influxdb.database sitespeed' > /etc/cron.hourly/sitespeed"
sudo chmod 755 /etc/cron.hourly/sitespeed
