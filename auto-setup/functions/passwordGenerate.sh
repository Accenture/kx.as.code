generatePassword() {
  # Generate a secure password
  chars='#%-=.*&_'
  { </dev/urandom LC_ALL=C grep -ao '[A-Za-z0-9]' \
          | head -n$((RANDOM % 8 + 9))
      echo ${chars:$((RANDOM % ${#chars})):1}   # Random special char.
  } \
      | shuf \
      | tr -d '\n'
}
