#!/bin/bash

for Klasse_Datei in _schulklassen/*.txt; do
Klasse_Ordner=$(basename "$Klasse_Datei" .txt)

mkdir -p "$Klasse_Ordner"

while IFS= read -r schueler; do
schueler_ordner="$Klasse_Ordner/$schueler"

mkdir -p "$schueler_ordner"

cp _templates/* "$Klasse_Ordner/"
    done < "$Klasse_Datei"
done
