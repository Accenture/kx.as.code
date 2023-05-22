generateUsername() {

  local firstname=${1:-}
  local surname=${2:-}

  firstnameSubstringLength=$((8 - ${#surname}))

  if [[ ${firstnameSubstringLength} -le 0 ]]; then
      firstnameSubstringLength=1
  fi
  userId="$(echo ${surname,,} | cut -c1-7)$(echo ${firstname,,} | cut -c1-${firstnameSubstringLength})"

  echo "${userId}"

}