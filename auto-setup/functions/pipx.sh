 pipx() {
  # TODO - Remove work around once pipx supports global install natively
  # --- https://github.com/pypa/pipx/issues/754#issuecomment-1871660321
  if [[ "$@" =~ '--global' ]]; then
    args=()
    for arg in "$@"; do
      # Ignore bad argument
      [[ $arg != '--global' ]] && args+=("$arg")
    done
    command sudo PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin PIPX_MAN_DIR=/usr/local/share/man pipx "${args[@]}"
  else
    command pipx "$@"
  fi
}