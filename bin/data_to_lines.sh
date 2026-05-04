#!/bin/bash
#
# Detect lines, using the region layout provided in the Page meta-data:
#   
#   *.page.xml → *.lines.pred.json
#
# Note: B&W manuscripts from the Vatican library are ignored.

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
	echo "USAGE: ${0} [ -h | --help ]"
	exit 0
fi

export PYTHONPATH=~/graz/htr/vre/ddpa_lines_ng;
for d in $(ls . |grep -v 'vaticane'); do
	echo ${d}
	cd ${d};
	PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True $PYTHONPATH/bin/ddp_line_detect.py --img_paths *.jpg --img_suffix '.jpg' --layout_suffix '.page.xml' --verbosity 2 --apply_model_thresholds --device gpu;
	cd ..;
done

