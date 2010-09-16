#!/bin/bash

sed -i \
	-e 's|^USE="\([^"]\+\)"|USE="cjk \1 vim-syntax zsh-completion"|' \
	/etc/make.conf

emerge screen sudo vim zsh --quiet
sed -i \
	-e 's|^EDITOR="\([^"]\+\)"|#EDITOR="\1"|' \
	-e 's|^#EDITOR="/usr/bin/vim"|EDITOR="/usr/bin/vim"|' \
	/etc/rc.conf
sed -i \
	-e 's|^# \(%wheel ALL=(ALL) ALL\)|\1|' \
	/etc/sudoers

emerge --update --deep --newuse world --quiet
