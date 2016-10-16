#!/bin/bash
CURR_DIR=$PWD
INPUT_DIR=$1
APKEXT=.apk

APKTOOL_DIR=$CURR_DIR/apktool
OUTPUT_DIR=$CURR_DIR/output
OUTPUT_FILE=$OUTPUT_DIR/outputList


if [ "$1" != "" ]; then
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

	$APKTOOL_DIR/apktool d -f -s -r $INPUT_DIR/$filename

	# list all files within one app and test if any of them is an ELF file
	cd $OUTPUT_DIR/$file
	for f in $(find . *); 
	do 
		fileType=$(file $f)
		if [[ $fileType =~ .*ELF.* ]]
		then
			echo $file >> $OUTPUT_FILE
			break
		fi
	done
done

