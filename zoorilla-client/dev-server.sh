#!/bin/bash
coffee -b -o static/ -cw static/ &
python -m SimpleHTTPServer 9999