#!/bin/bash

testdir=$(dirname $(readlink -f $BASH_SOURCE))
topdir=$(dirname $testdir)

failed=""
for try in $topdir/pgrapher/experiment/uboone/{wct,wcls}-*.jsonnet
do
    echo $try
    time jsonnet -J $topdir $try >/dev/null
    if [ "$?" != "0" ] ; then
        echo "failed: $try"
        failed="$failed $try"
    fi
done
if [ -n "$failed" ] ; then
    exit 1
fi
