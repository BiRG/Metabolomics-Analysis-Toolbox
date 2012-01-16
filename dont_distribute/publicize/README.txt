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


**************************************************
* Gotcha for partially public parent directories *
**************************************************

If a parent directory (call it project_1) is not completely public (so
that the path has to be to an item in a directory that is not in its
own sync path) then unison will not sync paths pointing to items in
project_1 unless project_1 is manually created in the public clone.
Similarly, it will not remove pd if everything is deleted or if pd is
removed.

This is a limitation in unison.  You will get the error message:

Error: path project_1/old_code is not valid because project_1 is not a directory in one of the replicas

So, for example, say I have a directory containing old code that I
want to make public but there is also some new code in an adjacent
subdirectory, so my tree looks like:

project_1
|
+---old_code
|
L---new_code

If I want to share project_1/old_code, I need to do two steps

1. Add path = project_1/old_code to the public_files_toolbox.prf file

2. On birgnas2, mkdir -p public/toolbox/project_1

Then things will sync.

If I later rename project_1 to buzzword, I'll need to go on the server
and manually mv public/toolbox/project_1 public/toolbox/buzzword
before things will sync.

The only way around it is to write our own sync software (or add the
feature to unison after learning OCaml).  Writing sync software that
meets our specs would take at least one day and possibly three or
four.  Because the fix is a simple one-line manual intervention, I
don't think it is necessary to worry about writing our own software
unless this problem becomes common.


************************************
* Gotcha for renaming public files *
************************************

If you rename a public file that is synchronized as a file (rather
than just a member of a directory), you must leave the old name in the
*.prf file until the change has propagated to the public repository.

A rename is copy followed by a deletion.  If the old name is not in
the list of files to synchronize, unison will not perform the deletion
portion of this operation, since that file shouldn't be touched (not
being in the list of things to synchronize.)

This shouldn't be much of a problem since there should be few items
where just one file is synchronized rather than an entire directory,
and renames are rare operations.

The best idea I can come up with for a rename is to first commit the
rename with both names being synchronized.  Then publicize.  Then
remove the name from the *.prf file.  Then publicize again.

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

