applyCustomizations() {

    # Call common function to execute common function start commands, such as setting verbose output etc
    functionStart

    customImagesDirectory="${installationWorkspace}/custom-images"

    # Apply custom background
    customBackgroundImageFile=$(find ${customImagesDirectory} -maxdepth 1 -name background.jpg -o -name background.png -print)
    customBackgroundImageFileName="$(basename ${customBackgroundFile%.*})"
    customBackgroundImageFileExtension="${customBackgroundFile##*.}"

    if [[ -n ${customBackgroundImageFile} ]]; then
        log_debug "Found custom background image to apply. Applying."
        /usr/bin/sudo cp -f /usr/share/backgrounds/background.jpg /usr/share/backgrounds/background_backup.jpg
        if [[ "$(checkImageFileType \"${customBackgroundImageFile}\")" == "PNG" ]]; then
            installDebianPackage "imagemagick"
            /usr/bin/sudo mv -f ${customBackgroundImageFile} ${customImagesDirectory}/background_old.png
            /usr/bin/sudo convert ${customImagesDirectory}/background_old.png ${customImagesDirectory}/background.jpg
        fi
        /usr/bin/sudo cp -f ${customImagesDirectory}/background.jpg /usr/share/backgrounds/background.jpg
    else
        log_debug "No custom background image to apply. Skipping."
    fi

    # Update logo on boot screen
    customBootImageFile=$(find ${customImagesDirectory} -maxdepth 1 -name boot.jpg -o -name boot.png -print)
    customBootImageFileName="$(basename ${customBootImageFile%.*})"
    customBootImageFileExtension="${customBootImageFile##*.}"

    if [[ -n ${customBootImageFile} ]]; then
        log_debug "Found custom boot image to apply. Applying."
        /usr/bin/sudo cp -f /usr/share/plymouth/themes/kx.as.code/boot.png /usr/share/plymouth/themes/kx.as.code/boot_backup.png
        if [[ "$(checkImageFileType \"${customBootImageFile}\")" == "JPEG" ]]
            installDebianPackage "imagemagick"
            /usr/bin/sudo mv -f ${customBootImageFile} ${customImagesDirectory}/${customBootImageFileName}_old.jpg
            /usr/bin/sudo convert ${customImagesDirectory}/${customBootImageFileName}_old.jpg ${customImagesDirectory}/boot.png
        fi
        /usr/bin/sudo cp -f ${customImagesDirectory}/boot.png /usr/share/plymouth/themes/kx.as.code/boot.png
        /usr/bin/sudo update-initramfs -u
    else
        log_debug "No custom boot image to apply. Skipping."
    fi

    # Update profile icon for default user
    customAvatarImageFile=$(find ${customImagesDirectory} -maxdepth 1 -name avatar.jpg -o -name avatar.png -print)
    customAvatarImageFileName="$(basename ${customAvatarImageFile%.*})"
    customAvatarImageFileExtension="${customAvatarImageFile##*.}"

    if [[ -n ${customAvatarImageFile} ]]; then
        log_debug "Found custom profile avatar image to apply. Applying."
        /usr/bin/sudo cp -f /home/${baseUser}/.face.icon /home/${baseUser}/.face_backup.icon
        if [[ "$(checkImageFileType \"${customAvatarImageFile}\")" == "JPEG" ]]
            installDebianPackage "imagemagick"
            /usr/bin/sudo mv -f ${customAvatarImageFile} ${customImagesDirectory}/${customAvatarImageFileName}_old.jpg
            /usr/bin/sudo convert ${customImagesDirectory}/${customAvatarImageFileName}_old.jpg ${customImagesDirectory}/avatar.png
        fi
        /usr/bin/sudo cp -f ${customImagesDirectory}/avatar.png /home/${baseUser}/.face.icon
    else
        log_debug "No custom profile avatar image to apply. Skipping."
    fi


    # Update logo icon for for Conky on desktop 
    customConkyImageFile=$(find ${customImagesDirectory} -maxdepth 1 -name conky_logo.jpg -o -name conky_logo.png -print)
    customConkyImageFileName="$(basename ${customConkyImageFile%.*})"
    customConkyImageFileExtension="${customConkyImageFile##*.}"

    if [[ -n ${customConkyImageFile} ]]; then
        log_debug "Found custom Conky logo image to apply. Applying."
        /usr/bin/sudo cp -f /usr/share/logos/conky_logo.png /usr/share/logos/conky_logo_backup.png
        if [[ "$(checkImageFileType \"${customConkyImageFile}\")" == "JPEG" ]]
            installDebianPackage "imagemagick"
            /usr/bin/sudo mv -f ${customConkyImageFile} ${customImagesDirectory}/${customConkyImageFileName}_old.jpg
            /usr/bin/sudo convert ${customImagesDirectory}/${customConkyImageFileName}_old.jpg ${customImagesDirectory}/conky_logo.png
        fi
        /usr/bin/sudo cp -f ${customImagesDirectory}/conky_logo.png /usr/share/logos/conky_logo.png
    else
        log_debug "No custom Conky image to apply. Skipping."
    fi

    # Update various applications where the environment logo is set. For example, Guacamole.
    customLogoImageFile=$(find ${customImagesDirectory} -maxdepth 1 -name logo_icon.jpg -o -name logo_icon.png -print)
    customLogoImageFileName="$(basename ${customLogoImageFile%.*})"
    customLogoImageFileExtension="${customLogoImageFile##*.}"

    if [[ -n ${customLogoImageFile} ]]; then
        log_debug "Found custom Gucamole Remote Desktop logo image to apply. Applying."
        installDebianPackage "imagemagick"
        if [[ -d /var/lib/tomcat9/webapps/guacamole/images_backup/ ]]; then
            /usr/bin/sudo cp -rf /var/lib/tomcat9/webapps/guacamole/images/ /var/lib/tomcat9/webapps/guacamole/images_backup/ 
        fi
        if [[ "$(checkImageFileType \"${customLogoImageFile}\")" == "JPEG" ]]
            /usr/bin/sudo mv -f ${customLogoImageFile} ${customImagesDirectory}/${customLogoImageFileName}_old.jpg
            /usr/bin/sudo convert ${customImagesDirectory}/${customLogoImageFileName}_old.jpg ${customImagesDirectory}/logo_icon.png
        fi
      
        # Generate files needed in various sizes for Guacamole
        convert ${customImagesDirectory}/logo_icon.png    -resize 64x64      \!  ${customImagesDirectory}/guac-mono-192.png
        convert ${customImagesDirectory}/logo_icon.png    -resize 311x288    \!  ${customImagesDirectory}/guac-tricolor.png
        convert ${customImagesDirectory}/logo_icon.png    -resize 144x144    \!  ${customImagesDirectory}/logo-144.png
        convert ${customImagesDirectory}/logo_icon.png    -resize 64x64      \!  ${customImagesDirectory}/logo-64.png

        # Copy generated file to Gucamole
        if [[ -d /var/lib/tomcat9/webapps/guacamole/images/ ]]; then
            cp -f ${customImagesDirectory}/guac-mono-192.png \
                ${customImagesDirectory}/guac-tricolor.png \
                ${customImagesDirectory}/logo-144.png \
                ${customImagesDirectory}/logo-64.png \
                /var/lib/tomcat9/webapps/guacamole/images/
        fi
    else
        log_debug "No custom Gucamole Remote Desktop logo image to apply. Skipping."
    fi

    # Call common function to execute common function start commands, such as unsetting verbose output etc
    functionEnd

}