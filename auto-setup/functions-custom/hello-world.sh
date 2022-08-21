################################################################################
#
# Rather than editing functions in the functions folder, copy the ones you want
# to change to this folder to override them.
#
# If you edit the ones in the main functions folder, you may make it difficult
# for yourself to upgrade to a new version in future.
#
################################################################################

helloWorld() {

    >&2 log_debug "This is just a sample custom function in the functions-custom directory - ${FUNCNAME[0]}()"
    set -x

}