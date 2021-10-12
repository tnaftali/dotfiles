#/bin/bash

wget -O /tmp/wallpaper.jpg https://unsplash.it/1920/1080/?random
gsettings set org.gnome.desktop.background picture-uri "file:///tmp/wallpaper.jpg"
gsettings set org.gnome.desktop.screensaver picture-uri "file:///tmp/wallpaper.jpg"

echo "Wallpaper updated successfully!"
