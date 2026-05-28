#!/bin/bash

PROJECT_ROOT="/Users/w1z4rd/University/omnetpp-6.4.0/samples/cp"
INET_SRC="/Users/w1z4rd/University/omnetpp-6.4.0/samples/inet4.6/src"
OMNET_ROOT="/Users/w1z4rd/University/omnetpp-6.4.0"

INI_DIR="$PROJECT_ROOT/simulations/ini"
RESULTS_DIR="$PROJECT_ROOT/simulations/ini/results"

set -e

if [ -f "$OMNET_ROOT/setenv" ]; then
    echo "--> Подключение окружения OMNeT++..."
    set +e
    source "$OMNET_ROOT/setenv" > /dev/null 2>&1
    set -e
else
    export PATH="$OMNET_ROOT/bin:$PATH"
fi

echo "=== [1/4] Запуск симуляций OMNeT++ в графическом режиме ==="
cd "$INI_DIR"

for c in Base General Scalability; do
  echo "--> Running config: $c"
  
  opp_run -u Qtenv -m \
    -n "$PROJECT_ROOT:$INET_SRC" \
    -l "$INET_SRC/INET" \
    -c "$c" \
    -r 0 \
    omnetpp.ini
done

echo "=== [2/4] Экспорт результатов в CSV ==="
cd "$RESULTS_DIR"

SCAL_VEC="Scalability-#0.vec"
if [ ! -f "Scalability-#0.vec" ] && [ -f "Load-#0.vec" ]; then
    SCAL_VEC="Load-#0.vec"
fi

opp_scavetool export -o Base.csv Base-#0.vec
opp_scavetool export -o General.csv General-#0.vec
opp_scavetool export -o Scalability.csv "$SCAL_VEC"

echo "=== [3/4] Генерация интерактивного графика ==="
cd "$PROJECT_ROOT"
python3 plot.py

echo "=== [4/4] Готово! Скрипт успешно завершен ==="
