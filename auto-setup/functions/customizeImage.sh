customizeImage() {

    sourceImageFile=${1:-}
    targetImageFile=${2:-}

    if [[ -d ${installationWorkspace}/custom-images ]]; then

      customImagesDirectory="${installationWorkspace}/custom-images"
      sudo chmod 644 -R ${installationWorkspace}/custom-images

      # Calculate source file name
      sourceImageFilePath=$(find "${customImagesDirectory}" -maxdepth 1 -name "${sourceImageFile}.jpg" -o -name "${sourceImageFile}.png" | head -1)
      sourceImageFileName=$(basename "${sourceImageFilePath%.*}")

      if [[ -n ${sourceImageFilePath} ]]; then

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
            sudo cp -f "${targetImageFile}" "${targetImageFile}_backup"
            if [[ $(checkImageFileType "${sourceImageFilePath}") == "${targetImageFileFormat}" ]]; then
                installDebianPackage "imagemagick"
                sudo mv -f "${sourceImageFilePath}" "${sourceImageFilePath}_old"
                sudo convert "${sourceImageFilePath}_old" "${sourceImageFilePath}"
            fi
            sudo cp -f "${sourceImageFilePath}" "${targetImageFile}"
            sudo chmod 644 "${targetImageFile}"
        else
            log_debug "No custom  \"${sourceImageFileName}\" image to apply. Skipping."
        fi

      fi

    fi

}