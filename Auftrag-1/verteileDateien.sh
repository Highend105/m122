#!/bin/bash
mkdir -p $(find _schulklassen -type f -name "*.txt" -execdir basename {} .txt \;)
# 2 Zeile ist von GPT, noch nicht ausgeführt
