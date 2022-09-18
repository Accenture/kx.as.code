checkImageFileType() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    # Return image file type
    imageFile=${1}
    file ${imageFile} -b | awk {'print $1'}

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}