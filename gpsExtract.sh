#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 IMG_0011.HEIC"
  exit 1
fi

LAT=$(exiftool -s3 -n -GPSLatitude "$1")
LON=$(exiftool -s3 -n -GPSLongitude "$1")

if [ -z "$LAT" ] || [ -z "$LON" ]; then
  echo "No GPS coordinates found."
  exit 1
fi

echo "Latitude:  $LAT"
echo "Longitude: $LON"
echo "Google Maps URL:"
echo "https://www.google.com/maps/search/?api=1&query=${LAT},${LON}"
