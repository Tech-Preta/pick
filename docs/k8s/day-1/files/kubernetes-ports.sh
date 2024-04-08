#!/bin/bash

# Este script permite a liberação de portas necessárias para nós Kubernetes.

echo "Seu nó será control-plane ou worker?"
read node_type

if [ "$node_type" = "control-plane" ]; then
    echo "Liberando portas para control-plane..."
    # Aqui você pode adicionar os comandos para liberar as portas necessárias.
    # Por exemplo, se você estiver usando o ufw (Uncomplicated Firewall) no Ubuntu, você pode fazer:
    sudo ufw allow 6443/tcp
    sudo ufw allow 2379:2380/tcp
    sudo ufw allow 10250/tcp
    sudo ufw allow 10259/tcp
    sudo ufw allow 10257/tcp
elif [ "$node_type" = "worker" ]; then
    echo "Liberando portas para worker..."
    # Aqui você pode adicionar os comandos para liberar as portas necessárias.
    # Por exemplo, se você estiver usando o ufw (Uncomplicated Firewall) no Ubuntu, você pode fazer:
    sudo ufw allow 10250/tcp
    sudo ufw allow 30000:32767/tcp
else
    echo "Tipo de nó desconhecido: $node_type"
fi