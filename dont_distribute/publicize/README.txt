The publicizing system is a bit complicated.  The two tools that do
most of the work are unison (to do the mirroring) and git (to do the
scm).

Everything is designed to be run from the repo_publicizer account on
birg.

publicize_toolbox.sh is the script to run to do the actual
publication.  It will synchronize things and run git commit.  The user
must type in a commit message in vi.  With no commit message, the
script aborts at that point allowing manual intervention if necessary.
publicize_toolbox.sh is a symlink to
~/private/toolbox/dont_distribute/publicize/publicize_toolbox.sh so
that this script can be versioned.

~/.unison/public_files_toolbox.prf is a unison profile containing the
unison commands to do the mirror operation for the toolbox repository.
It is very close to the original design of having the code read a text
file of files and directories to make public, except now each thing to
make public must be preceeded by the word path and there is a bit of
cruft (root=blah ... etc) at the beginning of the file.  This file is
actually a symlink to
~/private/toolbox/dont_distribute/publicize/public_files_toolbox.prf so
it can be versioned.  These two bits of hackery (the funny format of
the file and the symlink) seemed a small price to pay for doing most
of the complicated syncing with a tested and flexible tool.

~/private contains one directory for every private repository

~/public contains one directory for every public repository

*********************
* Notes on branches *
*********************

The current implementation does not change to a particular branch for
publicizing.  This is good for testing, because one can manually
change to the branches one wants to deal with (for example a hotfix
branch implementing a new publicizing feature) without interfering
with the main branch.  It may have other uses as well.

**************************************
* Thoughts on publicizing a new repo *
**************************************

To publicize another repository foo, make a new git repo under public,
a new one under private, and a new public_files_foo.prf that we link
into the unison directory.  Make a new script publicize_foo.sh based
on publicize_toolbox.sh (or refactor out the common stuff if you are
feeling your hacker mojo particularly strong that day so that both
publicize_foo and publicize_toolbox call a common base script called
publicize_repo).  You probably don't want to have one script publicize
both repositories because each project will be ready for release at a
different time.

The new publicizing machinery for the other repository should stay in
the same directory in toolbox so that it is easy to find things and
keep them in sync when bugs are found or systemic changes are made
(like, for example, changing the hard-coded paths or operating system
upgrades that break the expected return values of commands.)

