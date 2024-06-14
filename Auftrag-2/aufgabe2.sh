# Funktion zum Sammeln der Systeminformationen
function informationen_sammeln {
  echo "Uptime"
  uptime | cut -d ',' -f 1
  echo ""
  echo "Datum"
  date
  echo ""
  echo "Speicherplatz"
  df -h
  echo ""

  echo "Hostname: $(hostname)"
  echo "IP-Adresse: $(hostname -i)"
  echo ""

  echo "Betriebssystem"
  echo "Name: $(grep ^NAME= /etc/os-release | cut -d '=' -f 2)"
  echo "Version: $(grep '^VERSION=' /etc/os-release | cut -d '=' -f 2 )"
  echo ""

  echo "CPU-Modellname: $(grep 'model name' /proc/cpuinfo | uniq | cut -d ':' -f 2 )"
  echo "Anzahl der CPU-Cores: $(grep -c '^processor' /proc/cpuinfo)"
  echo ""

  echo "Gesamter Arbeitsspeicher: $(free -h | grep Mem | tr -s '[:space:]' ' ' | cut -d ' ' -f 2)"
  echo ""
  echo "Genutzer Arbeitsspeicher: $(free -h | grep Mem | tr -s '[:space:]' ' ' | cut -d ' ' -f 3)"
}

# Funktion zum Schreiben der Informationen in die Log-Datei
function schreibe_log {
  local log_file="$1"
  local output="$2"

  echo "$output" >> "$log_file"
}

# Prüfen, ob die Option -f angegeben wurde
erstelle_file=false
if [[ "$1" == "-f" ]]; then
  erstelle_file=true
fi

# Name der Log-Datei mit aktuellem Datum und Hostname
log_file="/mnt/c/users/Lukas/OneDrive - TBZ/Github/m122/Auftrag-2/log/$(date +'%Y-%m-%d')-sys-$(hostname).log"

# Wenn Ausgabe in Datei erfolgen soll
if [ "$erstelle_file" = true ]; then
  # Sammle Informationen und schreibe sie in die Log-Datei
  collected_info=$(informationen_sammeln)
  schreibe_log "$log_file" "$collected_info"
else
  # Sonst nur Informationen auf der Konsole ausgeben
  informationen_sammeln
fi
