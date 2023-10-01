applyCustomizations() {

    customImagesDirectory="${installationWorkspace}/custom-images"

    # Apply custom background
    customizeImage "background" "/usr/share/backgrounds/background.jpg"

    # Update logo on boot screen
    customizeImage "boot" "/usr/share/plymouth/themes/kx.as.code/boot.png"

    # Update profile icon for default user
    customizeImage "avatar" "/home/${baseUser}/.face.icon"

    # Update logo icon for for Conky on desktop
    customizeImage "conky_logo" "/usr/share/logos/conky_logo.png"

    # Update various applications where the environment logo is set. For example, Guacamole.
    customizeImage "logo_icon" "${customImagesDirectory}/logo_icon_processed.png"

    if [[ -f ${customImagesDirectory}/logo_icon_processed.png ]]; then
        # Generate files needed in various sizes for Guacamole
        convert "${customImagesDirectory}/logo_icon_processed.png"    -resize 64x64      \!  "${customImagesDirectory}/guac-mono-192.png"
        convert "${customImagesDirectory}/logo_icon_processed.png"    -resize 311x288    \!  "${customImagesDirectory}/guac-tricolor.png"
        convert "${customImagesDirectory}/logo_icon_processed.png"    -resize 144x144    \!  "${customImagesDirectory}/logo-144.png"
        convert "${customImagesDirectory}/logo_icon_processed.png"    -resize 64x64      \!  "${customImagesDirectory}/logo-64.png"

        # Copy generated file to Guacamole
        if [[ -d /var/lib/tomcat9/webapps/guacamole/images/ ]]; then
            cp -f ${customImagesDirectory}/guac-mono-192.png \
                ${customImagesDirectory}/guac-tricolor.png \
                ${customImagesDirectory}/logo-144.png \
                ${customImagesDirectory}/logo-64.png \
                /var/lib/tomcat9/webapps/guacamole/images/
        fi
    fi

}