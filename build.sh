#! /bin/bash

set -ex

make data

make notebooks

cp analysis/*.pdf /output
cp analysis/*.pdf /publish
