function getPassword() {
  # Retrieve the password from GoPass
  passwordName=$(echo $1 | sed 's/ /-/g')
  runuser -u ${vmUser} -P -- gopass show --password ${baseDomain}/${passwordName}
}
