#!/bin/bash

SCRIPTPATH=$(dirname "$(realpath -s "$0")")
REPOROOT=$(dirname "$SCRIPTPATH")

cd "$REPOROOT"

TARGETFOLDER=$REPOROOT/generated

# Zip up files for Video LR
echo "Create ZIP file for video LR"
FILENAME_VIDEO=files-for-video-LR.zip
git ls-files -- ./files ':!:*.md' | zip -FS -q -@ "$TARGETFOLDER/$FILENAME_VIDEO"

# Zip up Autosplitters
echo "Create ZIP file for autosplitters"
FILENAME_AS=autosplitter.zip
git ls-files -- ./autosplitter ':!:*.md' | zip -FS -q -@ "$TARGETFOLDER/$FILENAME_AS"

# Create PDFs
echo "Create PDF from READMEs"
pandoc --from=gfm --to=pdf -o "$TARGETFOLDER/README.pdf" "$REPOROOT/README.md"
pandoc --from=gfm --to=pdf -o "$TARGETFOLDER/README-visual-LR.pdf" "$REPOROOT/files/README.md"

echo "Done"
