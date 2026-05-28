## Инструкция по запуску проекта

Шаги для успешного запуска проекта:

1. **Переход в папку проекта, активация виртуального окружения, запуск проекта**
   Переходим в папку проекта, активируем окружение и сразу запускаем проект:

   ```bash
   cd /Users/w1z4rd/University/omnetpp-6.4.0
   source setenv
   omnetpp
   ```

2. **Запуск проекта**
   Запускаем **проект**.

   ```bash
   cd /Users/w1z4rd/University/omnetpp-6.4.0/samples/cp/ && ./run_all.sh
   ```

3. **Запуск из терминала проект OMNET++**
   Для старта самого проекта в терминале (для демонстрации)

   ```bash
   cd /Users/w1z4rd/University/omnetpp-6.4.0/samples/cp/simulations/ini
   ../../out/clang-release/cp -m \
    -n "/Users/w1z4rd/University/omnetpp-6.4.0/samples/cp:/Users/w1z4rd/University/omnetpp-6.4.0/samples/inet4.6/src" \
    -l /Users/w1z4rd/University/omnetpp-6.4.0/samples/inet4.6/src/INET \
    omnetpp.ini
   ```
