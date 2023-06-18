#!/bin/sh -eux

tmp=$(mktemp)
did --help > $tmp
grep -C3 'Test Management Tool' $tmp
rm $tmp
