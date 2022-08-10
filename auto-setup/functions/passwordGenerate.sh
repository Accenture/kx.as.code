generatePassword() {

  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart

  # Generate a secure password. Not using pwgen in order to specify specific special characters
  echo {A..Z} {a..z} {0..9} {0..9} '_ - . ' | tr ' ' "\n" | shuf | xargs | tr -d ' ' | cut -b 1-32

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd
  
}
