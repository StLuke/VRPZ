#!/bin/bash

until ./kinectmenu.py $@;
do
	if [ "$?" -eq "128" ]; then
		./lol.py
	fi
done
