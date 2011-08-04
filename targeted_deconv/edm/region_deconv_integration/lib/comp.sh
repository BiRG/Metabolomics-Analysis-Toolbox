
dirA="../../omics_dev/matlab_scripts/"
dirB="../../omics_dev/lib/"
for i in *.m; do 
    if [ -e "$dirA$i" ]; then
	diff -q "$i" "$dirA$i"
    elif [ -e "$dirB$i" ]; then
	diff -q "$i" "$dirB$i"
    else
	echo "$i is a new file"
    fi
done
