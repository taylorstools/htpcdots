#!/bin/bash

WALLPAPER_DIR="$HOME/Wallpapers/"

#Get random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name ".DrawerWallpaper" | shuf -n 1)

#Get just the filename
WALLPAPER_NAME=$(basename "$WALLPAPER")

#Apply wallpaper in Plasma
plasma-apply-wallpaperimage "$WALLPAPER"

DRAWER_WALLPAPERS_DIR="$WALLPAPER_DIR/DrawerWallpapers"
mkdir -p "$DRAWER_WALLPAPERS_DIR"

#Apply effects to make app drawer wallpaper
if [ ! -e "$DRAWER_WALLPAPERS_DIR/$WALLPAPER_NAME" ]; then
  magick "$WALLPAPER" \
    \( -clone 0 -fill black -colorize 100 \) \
    -compose blend -define compose:args=60,40 -composite \
    -blur 0x20 \
    -gravity center -crop 16:9 +repage \
    -resize 1920x1080 \
    -background black -vignette 0x150+0+0 \
    -flatten -alpha off \
    "$DRAWER_WALLPAPERS_DIR/$WALLPAPER_NAME"
fi

SYMLINK="$WALLPAPER_DIR/.DrawerWallpaper"
rm -f "$SYMLINK"
#Create new symlink
ln -sf "$DRAWER_WALLPAPERS_DIR/$WALLPAPER_NAME" "$SYMLINK"
