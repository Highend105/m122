#!/bin/bash

fertigfile="$(date '+%Y-%m-%d_%H-%M-%S')_mailimports.csv"
briefpapier_dir="./briefpapier/"

generate_password() {
    < /dev/urandom tr -dc 'a-zA-Z0-9' | head -c12
    echo
}

clean_name() {
    echo "$1" | iconv -f utf-8 -t ascii//TRANSLIT | tr -cd '[:alnum:]-'
}

{
    read
    while read -r line
    do
        # Extract fields using cut command
        id=$(echo "$line" | cut -d ',' -f 1)
        first_name_unclean=$(echo "$line" | cut -d ',' -f 2)
        last_name_unclean=$(echo "$line" | cut -d ',' -f 3)
        gender_unclean=$(echo "$line" | cut -d ',' -f 4)
        street_unclean=$(echo "$line" | cut -d ',' -f 5)
        streetnr_unclean=$(echo "$line" | cut -d ',' -f 6)
        zip_unclean=$(echo "$line" | cut -d ',' -f 7)
        location_unclean=$(echo "$line" | cut -d ',' -f 8)

        # Clean names and other relevant fields
        first_name=$(clean_name "$first_name_unclean")
        last_name=$(clean_name "$last_name_unclean")
        gender=$(clean_name "$gender_unclean")
        street=$(clean_name "$street_unclean")
        streetnr=$(clean_name "$streetnr_unclean")
        zip=$(clean_name "$zip_unclean")
        location=$(clean_name "$location_unclean")

        email="${first_name}.${last_name}@edu.tbz.ch"
        password=$(generate_password)

	echo "${email};${password}" >> "$fertigfile"

	# Create notification letter file
        letter_file="${briefpapier_dir}${email}.brf"
        today_date=$(date '+%d.%m.%Y')

        # Determine gender-specific salutation
        if [ "$gender" = "Male" ]; then
            salutation="Lieber ${first_name}"
        else
            salutation="Liebe ${first_name}"
        fi

        # Create the content of the letter
        letter_content=$(cat <<EOF
Technische Berufsschule Zürich
Ausstellungsstrasse 70
8005 Zürich

Zürich, den ${today_date}

                        ${first_name} ${last_name}
                        ${street} ${streetnr}
                        ${zip} ${location}

${salutation}

Es freut uns, Sie im neuen Schuljahr begrüssen zu dürfen.

Damit Sie am ersten Tag sich in unsere Systeme einloggen
können, erhalten Sie hier Ihre neue Emailadresse und Ihr
Initialpasswort, das Sie beim ersten Login wechseln müssen.

Emailadresse:   ${email}
Passwort:       ${password}


Mit freundlichen Grüssen

Lukas Grüter
(TBZ-IT-Service)

admin.it@tbz.ch, Abt. IT: +41 44 446 96 60
EOF
)

        # Write the letter content to the letter file
        echo "$letter_content" > "$letter_file"

    done
} < "/mnt/c/Users/Lukas/OneDrive - TBZ/Github/m122/Auftrag-3/MOCK_DATA.csv"

# Erstellen des Archivs
# Neue Archivdatei mit dem entsprechenden Namen erstellen
archive_name="${today_date}_newMailadr_IhreKlasse_IhrNachname.zip"

# Alle relevanten Dateien zum Archiv hinzufügen
zip -r "$archive_name" \
    "$fertigfile" \
    "${briefpapier_dir}"*.brf

# FTP Zugangsdaten
FTP_HOST="ftp.haraldmueller.ch"
FTP_USER="schueler"
FTP_PASS="studentenpasswort"
FTP_PATH="/Grueter"

# FTP Transfer mit curl
curl -T "$archive_name" ftp://$FTP_USER:$FTP_PASS@$FTP_HOST$FTP_PATH/
