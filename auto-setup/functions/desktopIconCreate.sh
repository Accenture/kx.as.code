createDesktopIcon() {

  shortcutsDirectory="${1}"
  urlToOpen=${2}
  shortcutText="${3}"
  iconPath="${4}"
  browserOptions="${5}"

  mkdir -p "${shortcutsDirectory}"
  chown ${vmUser}:${vmUser} "${shortcutsDirectory}"

  echo """
  [Desktop Entry]
  Version=1.0
  Name=${shortcutText}
  GenericName=${shortcutText}
  Comment=${shortcutText}
  Exec=/usr/bin/google-chrome-stable %U ${primaryUrl} --use-gl=angle --password-store=basic ${browserOptions}
  StartupNotify=true
  Terminal=false
  Icon=${iconPath}
  Type=Application
  Categories=Development
  MimeType=text/html;text/xml;application/xhtml_xml;image/webp;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;
  Actions=new-window;new-private-window;
  """ | tee "${shortcutsDirectory}"/"${shortcutText}"
  sed -i 's/^[ \t]*//g' "${shortcutsDirectory}"/"${shortcutText}"
  chmod 755 "${shortcutsDirectory}"/"${shortcutText}"
  chown ${vmUser}:${vmUser} "${shortcutsDirectory}"/"${shortcutText}"

}
