Everything is designed to be run from the repo_publicizer account on
birg.

The syncscript holds the list of files to synchronize.  It is located at:
~/private/toolbox/dont_distribute/publicize/publicize_toolbox.syncscript

****************
* To publicize current versions of everything
***************

~/publicize_toolbox.sh

It will open vi for you to type a commit message,

****************
* To make a file or directory public
****************

Add a line

mirror 'path/to/file/or/directory';

To the end of the syncscript

****************
* To mirror a file or directory to a location specific to the public
* directory
****************

Add a line

mirror2 'private/path/to/file' 'public/path/to/file';

To the end of the syncscript


****************
* Implementation details
****************

The publicizing system has two parts LocalMirror.pm (which does the
mirroring) and git (to do the scm).

##
## publicize_toolbox.sh
##

publicize_toolbox.sh is the script to run to do the actual
publication.  It will synchronize things and run git commit.  The user
must type in a commit message in vi.  With no commit message, the
script aborts at that point allowing manual intervention before
changes are committed to the public repository if necessary.

publicize_toolbox.sh is a symlink to
~/private/toolbox/dont_distribute/publicize/publicize_toolbox.sh so
that this script can be versioned.  It calls the syncscript to do the
mirroring, then calls git to do the versioning.

publicize_toolbox.sh can take arguments.  These are useful during
testing.  You can set the current branch to some throw-away branch and
then do all your commits from a script without affecting the real public
repository.

publicize_toolbox.sh 'commit message here'  ------------- will not ask for a commit message, but will use the one from the command line.

publicize_toolbox.sh 'commit message here' nopush  ------ will not ask for a commit message, but will use the one from the command line and will not push the commits back to the github server.

##
## ~/private/toolbox/dont_distribute/publicize/publicize_toolbox.syncscript
##

Holds the list of files to make public.  Note that this is really a
perl script under the hood, so you can do all sorts of crazy things if
you need to.  It takes two arguments, the source and destination
directory.  It depends on being in the same directory as the
LocalMirror.pm file.  It imports LocalMirror.pm and uses it to do the command processing etc.

The basic algorithm is:
1. import stuff
2. process arguments to get source and destination
3. preserve some special destination files (in particular the git metadata)
4. delete everything else in the destination
5. copy current versions of everything into the destination

Except step 1, these steps are carried out by commands from LocalMirror.pm

1. Perl native stuff
2. parse_args, set_source, set_dest
3. dont_delete
4. delete_dest, is_in_dont_delete
5. mirror, mirror2

Another way to think of this is that LocalMirror.pm makes a
domain-specific language for mirroring.  I could have made it
declarative, but I thought that would add more complexity, so it is
imperative.

##
## Directory structure
##

~/private contains one directory for every private repository

~/public contains one directory for every public repository

~/perl5 contains the local copies of installed modules which won't
change when the OS is upgraded and which don't interfere with ubuntu's
package system.  You can use the 'cpan' command to install others you
need.  ~/perl5 was set up using local::lib.

~/SW/perl contains software that I installed in my quest to get cpan
and local::lib working on birgnas2

****************
* Modifying
****************

When you want to modify something directly from the repo_publicizer
account, set the email and username according to your email/username
on github (instructions for setting them will be given when you try to
commit).  Then delete them from the user section of
private/toolbox/.git/config when you are done.  That way the changes
will be correctly attributed.

Only set the repository local email and username not the global ones.

****************
* Testing 
****************

To run the automated test suite:

> cd ~/private/toolbox/dont_distribute/publicize/publicize_toolbox.sh
> prove

Note: You must have Test::Output and Test::Exception packages installed

To check test coverage:

In the same directory, 
> ./do_test_coverage.sh

Note: you must have the Devel::Cover perl package installed.  I
already installed it on birgnas2.
