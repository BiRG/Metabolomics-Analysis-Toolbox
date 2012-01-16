#!/bin/bash
#Update the private repo
cd ~/private/toolbox
git pull

#Mirror the private to the public using unison
cd ~
unison public_files_toolbox

#Checkin the changes to the public repo as a new commit with some
#reasonable commit message - right now the commit message is typed by the user
cd ~/public/toolbox
git add -u
git commit -a && git push #Commit and if successful, push to server
