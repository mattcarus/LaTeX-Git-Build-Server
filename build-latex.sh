#!/bin/sh

### Install this as a post-receive hook
### This script expects there to be a file called .latex-built-pointer
### in the root of the repository. The contents of this file should be
### the filename of the TEX file to compile

WEBDIR=yourwebdir
WORKSPACE=your/workspace

echo
echo "**** Pulling changes into Live [Hub's post-update hook]"
echo

# Go to the checked-out version of repo
cd $WORKSPACE || exit
unset GIT_DIR

# Save the current commit id so we can calculate the diff
current=`git rev-parse HEAD`

# Update the latest changes in master
git pull origin master

# Get the name of the TEX file to compile
TEX_FILE_NAME="`cat .latex-build-pointer`"

# Compile the LaTex stuff
pdflatex -interaction=batchmode $TEX_FILE_NAME.tex > /dev/null
bibtex -terse $TEX_FILE_NAME
pdflatex -interaction=batchmode $TEX_FILE_NAME.tex > /dev/null
pdflatex -interaction=batchmode $TEX_FILE_NAME.tex

# Create a folder for the new build
NOW=$(date +"%m-%d-%Y-%H%M")
OUT_DIR=$WEBDIR/$NOW
mkdir $OUT_DIR 

# Move the results to the output directory
cp $TEX_FILE_NAME.pdf $OUT_DIR/$TEX_FILE_NAME-$NOW-.pdf

# Make a syntax highlighted diff in the output directory
git diff $current..HEAD | pygmentize -l diff -f html -O full > $OUT_DIR/diff.html

# Output the log messages to the output directory
git log $current..HEAD > $OUT_DIR/log.txt

# And we're all done
exec git update-server-info