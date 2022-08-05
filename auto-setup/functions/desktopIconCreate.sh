#!/bin/bash
# shellcheck disable=SC2154 disable=SC1091
createDesktopIcon() {

  targetDirectory="${1}"
  urlToOpen=${2}
  shortcutText="${3}"
  iconPath="${4}"
  browserOptions="${5}"

  mkdir -p "${targetDirectory}"
  chown "${baseUser}":"${baseUser}" "${targetDirectory}"

  echo """
  [Desktop Entry]
  Version=1.0
  Name=${shortcutText}
  GenericName=${shortcutText}
  Comment=${shortcutText}
  Exec=/usr/bin/chromium %U ${urlToOpen} --use-gl=angle --password-store=basic ${browserOptions}
  StartupNotify=true
  Terminal=false
  Icon=${iconPath}
  Type=Application
  Categories=Development
  MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
  Actions=new-window;new-private-window;
  """ | tee "${targetDirectory}"/"${shortcutText}"
  sed -i 's/^[ \t]*//g' "${targetDirectory}"/"${shortcutText}"
  chmod 755 "${targetDirectory}"/"${shortcutText}"
  chown "${baseUser}":"${baseUser}" "${targetDirectory}"/"${shortcutText}"

}
