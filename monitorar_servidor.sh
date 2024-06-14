#!/bin/bash
log_Servidor="/Servidor_log/servidor.log"

if [ ! -d "/Servidor_log" ]; then
    mkdir "/Servidor_log"
fi

processos=$(ps -e -o pid --sort -size | head -n 11 | grep [0-9])

is_tomcat_running() {
    service tomcat6 status | grep "is running"
    return $?
}

restart_tomcat() {
    echo "Reiniciando Tomcat... $(date +%F,%H:%M:%S)" >> $log_Servidor
    service tomcat6 stop
    sleep 2
    killall -9 java
    sleep 2
    service tomcat6 start
}

while true; do
    if is_tomcat_running; then
        sleep 1
    else
        echo "Tomcat não está em execução. Reiniciando..." >> $log_Servidor
        echo "Obtendo informações dos processos com maior consumo de memoria..." >> $log_Servidor
        for pid in $processos; do
            nome_processos=$(ps -p $pid -o comm=)
            tamanho_processo=$(ps -p $pid -o size | grep -Eo '[0-9]+')
            if [ -n "$tamanho_processo" ]; then
                tamanho_processo_mb=$(echo "scale=2; $tamanho_processo/1024" | bc 2>/dev/null)
                if [ -n "$tamanho_processo_mb" ]; then
                    echo "$nome_processos: ${tamanho_processo_mb} MB" >> $log_Servidor
                else
                    echo "$nome_processos: Não disponível" >> $log_Servidor
                fi
            else
                echo "$nome_processos: Não disponível" >> $log_Servidor
            fi
        done
        restart_tomcat
        sleep 300
    fi
done
