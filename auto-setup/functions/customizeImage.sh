customizeImage() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    sourceImageFile=$1
    targetImageFile=$2

    customImagesDirectory="${installationWorkspace}/custom-images"

    # Calculate source file name
    sourceImageFilePath=$(find "${customImagesDirectory}" -maxdepth 1 -name "${sourceImageFile}.jpg" -o -name "${sourceImageFile}.png" -print)
    sourceImageFileName=$(basename "${sourceImageFilePath%.*}")

    # Calculate target file extension
    targetImageFileExtension="${targetImageFile##*.}"

    # Set target image format based on target file extension
    if [[ "${targetImageFileExtension}" == "jpg" ]]; then
        targetImageFileFormat="JPEG"
    elif [[ "${targetImageFileExtension}" == "png" ]]; then
        targetImageFileFormat="PNG"
    fi

    # Apply custom file
    if [[ -n "${sourceImageFilePath}" ]]; then
        log_debug "Found custom image \"${sourceImageFileName}\" to apply. Applying."
        /usr/bin/sudo cp -f "${targetImageFile}" "${targetImageFile}_backup"
        if [[ $(checkImageFileType "${sourceImageFilePath}") == "${targetImageFileFormat}" ]]; then
            installDebianPackage "imagemagick"
            /usr/bin/sudo mv -f "${sourceImageFilePath}" "${sourceImageFilePath}_old"
            /usr/bin/sudo convert "${sourceImageFilePath}_old" "${sourceImageFilePath}"
        fi
        /usr/bin/sudo cp -f "${sourceImageFilePath}" "${targetImageFile}"
    else
        log_debug "No custom  \"${sourceImageFileName}\" image to apply. Skipping."
    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}