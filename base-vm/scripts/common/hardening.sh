#!/bin/bash -x

INSTALLATION_WORKSPACE=/usr/share/kx.as.code/workspace

cisHardeningToRun="""
1.1.10
1.1.11.1
1.1.11.2
1.1.11.3
1.1.11
1.1.12.1
1.1.12.2
1.1.12.3
1.1.12
1.1.13
1.1.14.1
1.1.14
1.1.15
1.1.16
1.1.17
1.1.1.8
1.1.18
1.1.19
1.1.20
1.1.21
1.1.22
1.1.23
1.1.2
1.1.3
1.1.4
1.1.5
1.1.6.1
1.1.6.2
1.1.6
1.1.7
1.1.8
1.1.9
1.3.1
1.3.2
1.3.3
1.4.1
1.4.2
1.5.1
1.5.2
1.5.3
1.6.1
1.6.2
1.6.3.1
1.6.3
1.6.4
1.7.1.1
1.7.1.2
1.7.1.3
1.7.1.4
1.8.1.1
1.8.1.2
1.8.1.3
1.8.1.4
1.8.1.5
1.8.1.6
1.8.2
1.9
2.1.1
2.1.2
2.2.1.1
2.2.11
2.2.1.2
2.2.12
2.2.1.3
2.2.13
2.2.1.4
2.2.14
2.2.15
2.2.16
2.2.17
2.2.5
2.2.9
2.3.1
2.3.2
2.3.3
3.1.2
3.3.5
3.3.6
3.3.8
4.1.10
4.1.1.1
4.1.11
4.1.1.2
4.1.12
4.1.1.3
4.1.13
4.1.1.4
4.1.14
4.1.15
4.1.16
4.1.17
4.1.2.1
4.1.2.2
4.1.2.3
4.1.3
4.1.4
4.1.5
4.1.6
4.1.7
4.1.8
4.1.9
4.2.1.1
4.2.1.2
4.2.1.3
4.2.1.4
4.2.1.5
4.2.1.6
4.2.2.1
4.2.2.2
4.2.2.3
4.2.3
4.3
4.4
5.1.1
5.2.11
5.2.20
5.2.2
5.2.3
5.3.2
5.3.3
5.3.4
5.4.1.1
5.4.1.2
5.4.1.3
5.4.1.4
5.4.1.5
5.4.2
5.4.3
5.5
6.1.2
6.1.3
6.1.4
6.1.5
6.1.6
6.1.7
6.1.8
6.1.9
6.2.10
6.2.11
6.2.12
6.2.13
6.2.14
6.2.15
6.2.16
6.2.17
6.2.18
6.2.19
6.2.1
6.2.20
6.2.2
6.2.3
6.2.4
6.2.5
6.2.6
6.2.7
6.2.9
99.1.1.1
99.2.2
99.3.3.2
99.3.3.4
99.3.3.5
99.4.0
99.5.2.1
99.5.2.6
99.5.2.7
99.5.4.5.1
99.5.4.5.2
99.99
"""


### Initialize steps
cisDirectory=${INSTALLATION_WORKSPACE}/debian-cis
cisReportsDirectory=${INSTALLATION_WORKSPACE}/debian-cis-reports
mkdir -p ${cisReportsDirectory}
if [ ! -f ${cisDirectory} ]; then
  git clone --depth 1  https://github.com/ovh/debian-cis.git ${cisDirectory}
fi
cd ${cisDirectory}
sudo cp -f ${cisDirectory}/debian/default /etc/default/cis-hardening
sudo sed -i "s#CIS_ROOT_DIR=.*#CIS_ROOT_DIR='$(pwd)'#" /etc/default/cis-hardening


pass_check (){
    FAIL_MESSAGE="[KO]CheckFailed"
    FAIL_MESSAGE=$(echo "$FAIL_MESSAGE" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    STR=`sudo bin/hardening/$1.sh --audit`
    STR=$(echo "$STR" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    if [[ "$STR" == *"$FAIL_MESSAGE"* ]]; then
        echo "failed"
        return 1
    else
        return 0
    fi

}

for cisScriptId in ${cisHardeningToRun}
do
  cd bin/hardening
  file=$(find ./ -name ${cisScriptId}_* -type f)
  file=$(basename "$file")
  file="${file%.*}"
  cd ../../etc/conf.d
  echo "status=enabled" > ./${file}.cfg
  cd ./../..
  pass_check ${file}
  return_code=$?
#  if [[ $return_code == 0 ]]; then
#    continue
#  fi



  case ${cisScriptId} in

      1.1.1.1)
          cd /etc/modprobe.d
          echo "install freevxfs /bin/true" | sudo tee --append CIS.conf
          ;;
      1.1.1.2)
          cd /etc/modprobe.d
          echo "install jffs2 /bin/true" | sudo tee --append CIS.conf
          ;;
      1.1.1.3)
          cd /etc/modprobe.d
          echo "install hfs /bin/true" | sudo tee --append CIS.conf
          sudo rmmod hfs
          ;;
      1.1.1.4)
          cd /etc/modprobe.d
          echo "install hfsplus /bin/true" | sudo tee --append CIS.conf
          sudo rmmod hfsplus
          ;;
      1.1.1.5)
          cd /etc/modprobe.d
          echo "install squashfs /bin/true" | sudo tee --append CIS.conf
          ;;
      1.1.1.6)
          cd /etc/modprobe.d
          echo "install udf /bin/true" | sudo tee --append CIS.conf
          ;;
      1.1.1.7)
          cd /etc/modprobe.d
          echo "install vfat /bin/true" | sudo tee --append CIS.conf
          sudo rmmod vfat
          ;;
      1.1.1.8)
          cd /etc/modprobe.d
          echo "install cramfs /bin/true" | sudo tee --append CIS.conf
          ;;
      1.1.17)
          cd /etc
          sed -i '/media/s/$/\n\/dev\/mapper\/vg-root-lv_devshm \/dev\/shm ext4 nodev,nosuid,noexec 0 2/' fstab
          sudo mount -o remount,noexec /dev/shm
          ;;
      1.1.18)
          cd /etc
          sudo sed -i '/\/dev\/sr0.*user,noauto/ s/noauto/noauto,nodev/' fstab
          ;;
      1.1.19)
          cd /etc
          sudo sed -i '/\/dev\/sr0.*user,noauto/ s/noauto/noauto,nosuid/' fstab
          ;;
      1.1.20)
          cd /etc
          sudo sed -i '/\/dev\/sr0.*user,noauto/ s/noauto/noauto,noexec/' fstab
          ;;
      1.1.23)
          cd /etc/modprobe.d
          echo "install usb-storage /bin/true" | sudo tee --append CIS.conf
          sudo rmmod usb-storage
          ;;
      3.4.1)
          cd /etc/modprobe.d
          echo "install dccp /bin/true" | sudo tee --append CIS.conf
          ;;
      3.4.2)
          cd /etc/modprobe.d
          echo "install sctp /bin/true" | sudo tee --append CIS.conf
          ;;
      3.4.3)
          cd /etc/modprobe.d
          echo "install rds /bin/true" | sudo tee --append CIS.conf
          ;;
      3.4.4)
          cd /etc/modprobe.d
          echo "install tipc /bin/true" | sudo tee --append CIS.conf
          ;;
      3.5.4.1.1)
          sudo iptables -P INPUT DROP
          sudo iptables -P FORWARD DROP
          ;;
      2.2.1.3)
          sudo apt-get install -y chrony
          ;;
      2.2.1.4)
          sudo apt-get install -y ntp
          ;;
      4.2.1.4)
          pwd
          cd etc/conf.d
          echo "status=enabled
          SYSLOG_BASEDIR='/etc/syslog-ng'
          PERMISSIONS='640'
          USER='root'
          GROUP='adm'
          EXCEPTIONS=''" > ./${file}.cfg
          ;;
      4.2.1.5)
          pwd
          cd etc/conf.d
          echo "status=enabled
          SYSLOG_BASEDIR='/etc/syslog-ng'" > ./${file}.cfg
          ;;
      4.2.1.6)
          pwd
          cd etc/conf.d
          echo "status=enabled
          SYSLOG_BASEDIR='/etc/syslog-ng'
          REMOTE_HOST=false" > ./${file}.cfg
          ;;
      5.2.18)
          pwd
          cd etc/conf.d
          echo "status=enabled
          ALLOWED_USERS=''
          ALLOWED_GROUPS=''
          DENIED_USERS=''
          DENIED_GROUPS=''" > ./${file}.cfg
          ;;
      5.2.19)
          pwd
          cd etc/conf.d
          echo "status=enabled
          BANNER_FILE=''" > ./${file}.cfg
          ;;
      5.4.2)
          pwd
          cd etc/conf.d
          echo "status=enabled
          EXCEPTIONS=''" > ./${file}.cfg
          ;;
      6.1.13)
          cd etc/conf.d
          echo "status=enabled
          EXCEPTIONS="/bin/mount /usr/bin/mount /bin/ping /usr/bin/ping /bin/ping6 /usr/bin/ping6 /bin/su /usr/bin/su /bin/umount /usr/bin/umount /usr/bin/chfn /usr/bin/chsh /usr/bin/fping /usr/bin/fping6 /usr/bin/gpasswd /usr/bin/mtr /usr/bin/newgrp /usr/bin/passwd /usr/bin/sudo /usr/bin/sudoedit /usr/lib/openssh/ssh-keysign /usr/lib/pt_chown /usr/bin/at"" > ./${file}.cfg
          ;;
          *)

  esac

  cd ${cisDirectory}
  rc=0

  sudo bin/hardening/${cisScriptId}_*.sh --apply &>>${cisReportsDirectory}/cis_${cisScriptId}_apply_output.txt || rc=$?
  if [[ ${rc} -ne 0 ]]; then
    echo "Apply for CIS script with ID ${cisScriptId} ended in a non zero return code." >>${cisReportsDirectory}/cis_error_summary_report.txt
    rc=0 # reset rc variable
  else
    echo "Apply for CIS script with ID ${cisScriptId} ended OK."
  fi

  sudo bin/hardening/${cisScriptId}_*.sh --audit &>>${cisReportsDirectory}/cis_${cisScriptId}_audit_output.txt || rc=$?
  if [[ ${rc} -ne 0 ]]; then
    echo "Audit for CIS script with ID ${cisScriptId} ended in a non zero return code." >>${cisReportsDirectory}/cis_error_summary_report.txt
    rc=0 # reset rc variable
  else
    echo "Audit for CIS script with ID ${cisScriptId} ended OK."
  fi

done

# Final audit
cd ${cisDirectory}
sudo bin/hardening.sh --audit-all &>>${cisReportsDirectory}/cis_audit_report_output.txt

# Clean-up
#sudo rm -rf ${cisDirectory}
