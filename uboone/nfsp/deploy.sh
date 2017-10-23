#!/bin/bash

mydir=$(dirname $(readlink -f $BASH_SOURCE))
top=$(dirname $(dirname $mydir))

tgt=$1 ; shift
mkdir -p $tgt

for which in before after
do
    jsonnet -V noisedb=fnal -V hwnf_epoch=$which -J $top \
	    $top/uboone/nfsp/ubnfsp.jsonnet | bzip2 > $tgt/ubnfsp-${which}.json.bz2
done

cp $top/uboone/nfsp/*.fcl $tgt

echo "Make sure target directory:"
echo "$tgt"
echo "is in both WIRECELL_PATH and FHICL_FILE_PATH"
