configureKeyboardSettings() {

    # Set default keyboard language
    keyboardLanguages=""
    availableLanguages="us"
    for language in ${availableLanguages}; do
      if [[ -z ${keyboardLanguages} ]]; then
        keyboardLanguages="${language}"
      else
        if [[ ${language} == "${defaultKeyboardLanguage}" ]]; then
          keyboardLanguages="${language},${keyboardLanguages}"
        else
          keyboardLanguages="${keyboardLanguages},${language}"
        fi
      fi
    done

    echo '''
  # KEYBOARD CONFIGURATION FILE

  # Consult the keyboard(5) manual page.

  XKBMODEL="pc105"
  XKBLAYOUT="'${keyboardLanguages}'"
  XKBVARIANT=""
  XKBOPTIONS=""

  BACKSPACE=\"guess\"
  ''' | sed -e 's/^[ \t]*//' | /usr/bin/sudo tee /etc/default/keyboard

}
