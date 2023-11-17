#!/bin/bash

# Do not install if public cloud or Raspberry Pi, as in these cases, NoMachine would have already been installed into the image.
if [[ "${installX2Go}" == "true" ]]; then

  # Install X2Go Server and Client
  sudo apt-get install -y x2goserver x2goserver-xsession x2goclient

fi
