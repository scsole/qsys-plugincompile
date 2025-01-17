#!/bin/sh

if test "$1" = "CANCEL"; then
  exit 1
fi

# STEP 0.5 Add plugincompile dir to path temporarily
PATH="$PATH:$(dirname $0)"
#echo $PATH

filepath="info.lua"
if [ -d "src" ]; then
  filepath="src/info.lua"
fi

if test "$1" != "ver_none"; then

  # STEP 1 Increment BuildVersion Number
  oldnum="$(grep 'BuildVersion' $filepath | cut -d $'\"' -f2 | cut -d $'\"' -f1)"
  #echo $oldnum
  newnum="$oldnum"

  majnum=${oldnum%%.*}
  minnum=${oldnum#*.}
  minnum=${minnum%%.*}
  fixnum=${oldnum%.*}
  fixnum=${fixnum##*.}
  devnum=${oldnum##*.}

  newver="$majnum.$minnum.$fixnum"

  if test "$1" = "ver_maj"; then
    echo "updating buildversion major num"

    #majnum=${oldnum:0:1}
    ((majnum++))
    newnum="$majnum.0.0.0"
    newver="$majnum.0.0"

  elif test "$1" = "ver_min"; then
    echo "updating buildversion minor num"

    #minnum=${oldnum:2:1}
    ((minnum++))
    newnum="$majnum.$minnum.0.0"
    newver="$majnum.$minnum.0"

  elif test "$1" = "ver_fix"; then
    echo "updating buildversion fix num"

    #fixnum=${oldnum:4:1}
    ((fixnum++))
    newnum="$majnum.$minnum.$fixnum.0"
    newver="$majnum.$minnum.$fixnum"

  elif test "$1" = "ver_dev"; then
    echo "updating buildversion dev num"

    #devnum=${oldnum:6:1}
    ((devnum++))
    newnum="$majnum.$minnum.$fixnum.$devnum"
    newver="$majnum.$minnum.$fixnum"

  else
    echo "updating buildversion dev num"

    #devnum=${oldnum:6:1}
    ((devnum++))
    newnum="$majnum.$minnum.$fixnum.$devnum"
    newver="$majnum.$minnum.$fixnum"

  fi

  #echo $newnum
  sed -i -E "s/$oldnum/$newnum/" $filepath
  sed -i -E "s/(^\s*Version\s*=\s*\")\S+(\")/\1$newver\2/" $filepath
else
  echo "not updating buildversion"
fi

# STEP 2 Create new GUID if the plugin doesn't already have one
oldid="$(grep 'Id' $filepath | cut -d $'\"' -f2 | cut -d $'\"' -f1)"
#echo $oldid

if test "$oldid" = "<guid>"; then
  echo "generating guid for plugin"
  newid="$(uuidgen)"
  #echo $newid
  sed -i -E "s/$oldid/$newid/" $filepath
fi

# STEP 3 Fix up line endings
unix2dos -q $filepath
