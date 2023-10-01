checkImageFileType() {

    # Return image file type
    imageFile=${1}
    file ${imageFile} -b | awk {'print $1'}

}