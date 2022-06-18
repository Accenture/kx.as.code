pushPassword() {
  # Push received password to GoPass (only if it does not already exist)
  /usr/bin/sudo -H -i -u ${baseUser} bash -c "echo \"${2}\" | gopass insert \"${baseDomain}/${1}\""
}
