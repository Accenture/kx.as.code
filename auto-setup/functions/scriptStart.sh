####_EXCLUDE_FROM_FUNCTION_HEADER_FOOTER_INJECTION_####
scriptStart() {

    if [[ "${logLevel}" == "trace" ]]; then
        set -x
    else
        set +x
    fi

    set -eE -o functrace pipefail
    trap 'scriptFailure "${LINENO}" "${BASH_COMMAND}" "'${BASH_SOURCE[0]}'" "$?"' ERR

}