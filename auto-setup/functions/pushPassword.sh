function pushPassword() {
  # Push received password to GoPass (only if it does not already exist)
  /usr/bin/sudo -H -i -u ${vmUser} bash -c "echo \"${2}\" | gopass insert \"${baseDomain}/${1}\""
}
