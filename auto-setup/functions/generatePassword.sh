function generatePassword() {
  # Generate a password and store it in GoPass
  passwordName=$(echo $1 | sed 's/ /-/g')
  chars='@#$%&_+='
  securePassword=$({ </dev/urandom LC_ALL=C grep -ao '[A-Za-z0-9]' \
          | head -n$((RANDOM % 8 + 9))
      echo ${chars:$((RANDOM % ${#chars})):1}   # Random special char.
  } \
      | shuf \
      | tr -d '\n')
  su - ${vmUser} -c 'echo "'${securePassword}'" | gopass insert '${baseDomain}'/'${passwordName}''
  runuser -u ${vmUser} -P -- gopass show --password ${baseDomain}/${passwordName}
}
