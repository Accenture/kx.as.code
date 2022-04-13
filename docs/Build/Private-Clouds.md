# Private Clouds

So far KX.AS.CODE has been tested on both VMWare vSphere and OpenStack. That said, OpenStack has been used the most and is most likely not to experience issues.
vSphere was successfully tested with an older version of KX.AS.CODE, but would like to work without adjustments to the terraform scripts as things stand now.

To start KX.AS.CODE in OpenStack, you need to change into the OpenStack profiles directory and update the profile-config.json.

In this guide I will only go into the OpenStack specifics, as the general setup is already described in the "Initial Setup" guide.

!!! tip "If you don't have access to an OpenStack cluster but want to try it out, then follow our [OpenStack setup guide](OpenStack-Setup-Guide.md)"
