#!/bin/bash

## Installing the Gentoo Base System

env-update
source /etc/profile

emerge --sync --quiet

sed -i \
	-e "s/^#en_US ISO-8859-1/en_US ISO-8859-1/" \
	-e "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" \
	-e "s/^#ja_JP.EUC-JP EUC-JP/ja_JP.EUC-JP EUC-JP/" \
	-e "s/^#ja_JP.UTF-8 UTF-8/ja_JP.UTF-8 UTF-8/" \
	-e "s/^#ja_JP EUC-JP/ja_JP UTF-8/" \
	/etc/locale.gen

locale-gen
