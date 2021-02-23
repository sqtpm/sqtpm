#!/bin/bash

# VM-side executir for VirtualBox with a shared directory.
# This file is part of sqtpm.

sharedd=/media/sf_aux

dir=$1
input=$2
lang=$3
cputime=$4
virtmem=$5
stkmem=$6

cd $sharedd/$dir &>/dev/null
umask 0000

tag=${input/.in/}

if [[ "$lang"  == "Python3" ]]; then 
  bash -c "ulimit -c 0 -t $cputime -v $virtmem -s $stkmem; python3 ./elf <$input 1>$tag.run.out 2>$tag.run.err; echo \$? >$tag.run.st"
else
  bash -c "ulimit -c 0 -t $cputime -v $virtmem -s $stkmem; ./elf <$input 1>$tag.run.out 2>$tag.run.err; echo \$? >$tag.run.st"
fi
