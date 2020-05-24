#! /bin/bash

set -ex

make notebooks

cp analysis/*.pdf /output
cp analysis/*.pdf /publish
