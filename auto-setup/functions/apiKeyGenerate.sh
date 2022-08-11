generateApiKey() {
  
  # Call common function to execute common function start commands, such as setting verbose output etc
  functionStart
  
  # Generate a API key
  pwgen -c -n 32 1

  # Call common function to execute common function start commands, such as unsetting verbose output etc
  functionEnd

}
