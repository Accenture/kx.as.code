# Customizing KX.AS.CODE

You don't need to code to give KX.AS.CODE the look and feel you desire. If you add certain files to the profile directory, they will automatically be picked up and distributed as needed.

Here a short table detailing which files to drop for which customization.

| Filename | Target | Recommended Size (px) | Comments | Screenshot |
| ---- | ---- | ---- | ---- | ---- |
| User Profile Avatar | avatar.png | 512 x 512 | This will update the user's user Avatar. Per default the avatar is selected automatically at random | ![](../assets//images/customization_avatar.png) |
| Desktop Wallpaper | background.jpg | 3840 x 2160 | This will update the desktop background | ![](../assets/images/kx.as.code_desktop.png) |
| Desktop Conky Logo | conky_logo.png | 1000 x 500 | This will update the Conky widget, displayed top right on the desktop | ![](../assets/images/customization_conky_logo.png) |
| Boot Logo | boot.png | 220 x 120 | This will update the KX.AS.CODE boot Plymouth theme. Not applicable for private and public cloud installations | ![](../assets/images/customization_boot_screen.png) |
| Guacamole Remote Desktop Logo | logo_icon.png | 200 x 200 | Several sizes are needed. Backend processing will take care to create the 4 needed sizes | ![](../assets/images/customization_guacamole.png) |

As KX.AS.CODE is not just a Kubernetes environment, but a framework, there are many more ways to customize KX.AS.CODE.
This page concentrated primarily on the customization of visual components.

See the following pages for customizing functionality.

- [Use-Case Example](../Overview/Use-Case-Example.md)
- [Components to install](../Overview/Application-Library.md)
- [Add your own installation groups](./Provisioning-Templates.md)
- [Profile customization, including domain name etc](./Configuration-Options.md)
- [Adding custom component walk-through](../Development/Adding-a-Solution.md)
- [Adding custom central functions](../Development/Central-Functions.md)
- [Customizing component metadata](../Development/Solution-Metadata.md)
