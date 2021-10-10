waitForFile() {
  timeout -s TERM 6000 bash -c \
  'while [[ ! -f ${0} ]];\
  do echo "Waiting for ${0} file" && sleep 15;\
  done' ${1}
}