waitForFile() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  timeout -s TERM 6000 bash -c \
  'while [[ ! -f ${0} ]];\
  do echo "Waiting for ${0} file" && sleep 15;\
  done' ${1}

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
