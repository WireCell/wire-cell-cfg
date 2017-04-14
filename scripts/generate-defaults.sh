#!/bin/bash

# This script dumps a Wire Cell Toolkit configuration (JSON) file
# which hold all defaults that are hard-coded by the C++ component.

outdir="$1"
if [ -z "$outdir" ] ; then
    outdir="."
fi
outdir=$(readlink -f $outdir)
mkdir -p $outdir

mydir=$(dirname $(dirname $(readlink -f $BASH_SOURCE)))
top=$(dirname $mydir)
cd $top

pkgsed='s|^\([^/]*\)/.*|\1|'
typsed='s|^WIRECELL_FACTORY(\([^,]*\),.*|\1|'

for pkg in $(grep -c WIRECELL_FACTORY */src/*.cxx|grep -v :0 | sed -e $pkgsed |sort|uniq)
do
    echo "Package: $pkg"
    cmdline="wire-cell -p WireCell${pkg^}"
    for class in $(cat $pkg/src/*.cxx| grep WIRECELL_FACTORY | grep IConfigurable | sed -e $typsed)
    do
        echo -e "\t$class"
        cmdline="$cmdline -D $class"
    done
    dumpfile="${outdir}/${pkg}-defaults.cfg"
    $cmdline --dump-file "$dumpfile"
    echo
done

echo "Failures to open a plugin likely means it isn't built."
