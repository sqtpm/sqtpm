#!/bin/bash

# Host-side execution dispatcher for VirtualBox without a shared directory.
# This file is part of sqtpm.

uid=$1
assign=$2
lang=$3
cputime=$4
virtmem=$5
stkmem=$6

if [[ `vboxmanage list runningvms | grep sqtpm | wc -l` != "1" ]]; then 
  exit 1
fi

user='--username sqtpm --password senha'

date=`/bin/date +%d%b%y-%H%M%S`
tmpd="/home/sqtpm/$date-$$"

vboxmanage guestcontrol sqtpm createdir $tmpd $user

cd $assign &>/dev/null

for f in *.in; do
  vboxmanage guestcontrol sqtpm copyto $PWD/$f $tmpd/$f $user
done

if [[ -d extra-files ]]; then
  cd extra-files &>/dev/null
  for f in *; do
    vboxmanage guestcontrol sqtpm copyto $PWD/$f $tmpd/$f $user --recursive
  done
  cd .. &>/dev/null
fi

cd _$uid_tmp_ &>/dev/null
vboxmanage guestcontrol sqtpm copyto $PWD/elf $tmpd/elf $user

vboxmanage guestcontrol sqtpm execute --image /home/sqtpm/vbox-etc-noshared.sh --username sqtpm --password senha --wait-exit --wait-stdout --wait-stderr -- $tmpd $lang $cputime $virtmem $stkmem

files=(`vboxmanage guestcontrol sqtpm execute --image /bin/ls $user --wait-exit --wait-stdout --wait-stderr -- -1 $tmpd | grep \.run\.`)

for f in ${files[@]}; do
  vboxmanage guestcontrol sqtpm copyfrom $tmpd/$f $PWD/$f $user
done

