#!/bin/bash

bspc subscribe node_add | while read -r Event Monitor Desktop Node
do
    bspc node last -f
done
