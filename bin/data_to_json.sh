#!/bin/bash
#
# Convert segmentation meta-data:
#  ALTO → Page → [DiDip-]JSON
#
# USAGE: ./data_to_json.sh [clean | verbose]
#
#

export PYTHONPATH=~/graz/htr/vre/ddpa_htr
SCHEMA_PATH=~/graz/htr/vre/ddpa_lines_ng/dataset/lines_schema.json


if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	cat<<-EOF
	${0} [ clean | verbose ]
	
          clean: exit immediately after restoring the original [Alto] XML files from repo.
	
	  verbose: debugging output?
	EOF
	exit 0	
fi

find . -name "*.alto.xml" | xargs rm -f;
find . -name "*.page.xml" | xargs rm -f ;
find . -name "*.json" | xargs rm -f ;
git reset HEAD *
git checkout -- .

VERBOSE=0

if [ "$1" == "clean" ]; then
	exit 0
elif [ "$1" == "verbose" ] || [ "$1" == "-v" ] ; then
	VERBOSE=1
fi


for d in * ; do 
	cd $d ; 
	echo "Directory: ${d}..."
	# Alto → Page
	echo "Alto → Page..."
	for alto in $(ls *.xml|grep -v chocomufin) ; do 
		cp -a $alto ${alto%.xml}.alto.xml ; 
		$PYTHONPATH/bin/alto_to_page.py ${alto%.xml}.chocomufin.xml > ${alto%.xml}.page.xml ; 
	done;
	# Page → JSON
	echo "Page → JSON..."
	$PYTHONPATH/bin/xml_to_json.py --file_paths *.page.xml --overwrite_existing --input_suffix .page.xml --verbose $VERBOSE
	echo "Validating JSON files..."
	check-jsonschema --schemafile $SCHEMA_PATH *.json
	cd .. ; 
done
