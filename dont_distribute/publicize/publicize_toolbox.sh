#!/bin/bash
#Update the private repo
echo ""
echo ""
echo "******************"
echo "* Updating the private repostiory"
echo "******************"
echo ""

cd ~/private/toolbox
git pull

#Mirror the private to the public using unison
echo ""
echo ""
echo "******************"
echo "* Mirroring the private to the public using unison"
echo "******************"
echo ""

cd ~
unison public_files_toolbox

#Checkin the changes to the public repo as a new commit with some
#reasonable commit message - right now the commit message is typed by the user
echo ""
echo ""
echo "******************"
echo "* Committing the changes to the public repository "
echo "******************"
echo ""

cd ~/public/toolbox
git add .  #Add untracked files (which will be new)
git add -u #Process deletions and renames
git commit -a && git push #Commit and if successful, push to server
