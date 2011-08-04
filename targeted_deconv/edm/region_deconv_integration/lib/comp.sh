#This script compares the matlab script files in this directory with
#the global matlab library directories.  It prints, for each file,
#whether it is a new file, the same as one in the global directories,
#or it is different from a file of the same name in the global directories

dirA="../../../../matlab_scripts/"
dirB="../../../../lib/"
for i in *.m; do 
    if [ -e "$dirA$i" ]; then
	if diff -q "$i" "$dirA$i" > /dev/null; then
	    echo "$i same"
	else
	    echo "$i changed"
	fi
    elif [ -e "$dirB$i" ]; then
	if diff -q "$i" "$dirB$i" > /dev/null; then
	    echo "$i same"
	else
	    echo "$i changed"
	fi
    else
	echo "$i is a new file"
    fi
done
