#!/bin/bash
CURR_DIR=$PWD
INPUT_DIR=$1
APKEXT=.apk

APKTOOL_DIR=$CURR_DIR/apktool
OUTPUT_DIR=$CURR_DIR/output
OUTPUT_FILE=$OUTPUT_DIR/outputList


LIMIT=200

if [ "$INPUT_DIR" != "" ]; then
	if [[ $INPUT_DIR == */ ]];
	then
		echo "Please do not add '/' at the end of input directory"
		exit
	fi
	echo "Begin analyzing all the $APKEXT files in INPUT DIRECTORY ($INPUT_DIR)"
else
	echo "Forget input directory?"
	exit
fi


if [ ! -d "$OUTPUT_DIR" ]; then
	mkdir $OUTPUT_DIR
fi


for file in $INPUT_DIR/*$APKEXT
do
	cd $OUTPUT_DIR
	filename=$(basename $file)
	file=$(basename $file $APKEXT)

	echo "Dissecting $filename ..."
	apkRet=$($APKTOOL_DIR/apktool d -s -r $INPUT_DIR/$filename)

	# list all files within one app and test if any of them is an ELF file
	cd $OUTPUT_DIR/$file

	COUNTER=0
	for f in $(find . -type f ! -iname "*.smali" ! -iname "*.xml" ! -iname "*.png" ! -iname "*.txt"); 
	do
		# In case some file names contain white space
		if [[ $f != ./* ]];
		then
			continue
		fi

		let COUNTER=COUNTER+1
		if [ $COUNTER -eq $LIMIT ]
		then
			echo "$filename has more than $LIMIT files, skip"
			break
		fi

		libname=$(basename $f)
		fileType=$(file $f)
		if [[ $fileType =~ .*ELF.* ]]
		then
			echo "$file has native lib $libname, add it into the list"
			echo $filename >> $OUTPUT_FILE
			break
		fi
	done
done

echo "Finished"
