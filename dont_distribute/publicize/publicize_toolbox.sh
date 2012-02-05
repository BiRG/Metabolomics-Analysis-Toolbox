#!/bin/bash

#You can pass a commit message to this script by adding it as the
#first command-line argument.
#
#If there is a second command line argument that is equal to nopush,
#no push is attempted to the server
#
#Thus:
#
# publicize_toolbox.sh - updates repo, asks user for a message and
#                        pushes to github
#
# publicize_toolbox.sh "my message here" - updates repo, uses the
#                                          message it was given on the
#                                          command line and pushes to
#                                          github
#
# publicize_toolbox.sh "my message here" nopush - updates repo, uses
#                                                 the message it was
#                                                 given on the command
#                                                 line and does not
#                                                 push to github
#

if [ $# -gt 2 ]; then
    echo "Too many arguments.  Did you forget the quotes around your "
    echo "commit message?"
    echo ""
    echo "Read the comments at the beginning of the script file for usage."
fi

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
echo "* Mirroring the private to the public"
echo "******************"
echo ""

cd ~
~/public/toolbox/dont_distribute/publicize/publicize_toolbox.syncscript ~/public/toolbox ~/private/toolbox

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

#Commit and if successful, push to server
if [ $# -gt 0 ]; then
    #A message was specified on the command line
    if [ $2 != "nopush" ]; then
	#Message specified but not nopush
	git commit -a -m "$1" && git push 
    else
	#We have a message and we are not supposed to push
	git commit -a -m "$1"
    fi
else
    #Ask user for the commit message then push
    git commit -a && git push 
fi