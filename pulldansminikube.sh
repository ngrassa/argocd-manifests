#!/bin/bash

# Pointer vers le Docker daemon de Minikube
eval $(minikube docker-env)

# Liste des images à puller
images=(
    "yassmineg/plateforme-eureka:latest"
    "yassmineg/plateforme-frontend:latest"
    "yassmineg/plateforme-gateway:latest"
    "yassmineg/plateforme-invoice:latest"
    "yassmineg/plateforme-notification:latest"
    "yassmineg/plateforme-payment:latest"
    "yassmineg/plateforme-signature:latest"
    "yassmineg/plateforme-subscription:latest"
    "yassmineg/plateforme-userauth:latest"
    "yassmineg/plateforme_electronique-api-gateway:latest"
    "yassmineg/plateforme_electronique-eureka-server:latest"
    "yassmineg/plateforme_electronique-frontend:latest"
    "yassmineg/plateforme_electronique-invoice-service:latest"
    "yassmineg/plateforme_electronique-notification-service:latest"
    "yassmineg/plateforme_electronique-payment-service:latest"
    "yassmineg/plateforme_electronique-signature-service:latest"
    "yassmineg/plateforme_electronique-subscription-service:latest"
    "yassmineg/plateforme_electronique-user-auth-service:latest"
    "yassmineg/plateforme_electronique_api-gateway:latest"
    "yassmineg/plateforme_electronique_eureka-server:latest"
    "yassmineg/plateforme_electronique_frontend:latest"
    "yassmineg/plateforme_electronique_invoice-service:latest"
    "yassmineg/plateforme_electronique_k8s-api-gateway:latest"
    "yassmineg/plateforme_electronique_k8s-eureka-server:latest"
    "yassmineg/plateforme_electronique_k8s-frontend:latest"
    "yassmineg/plateforme_electronique_k8s-invoice-service:latest"
    "yassmineg/plateforme_electronique_k8s-notification-service:latest"
    "yassmineg/plateforme_electronique_k8s-payment-service:latest"
    "yassmineg/plateforme_electronique_k8s-signature-service:latest"
    "yassmineg/plateforme_electronique_k8s-subscription-service:latest"
    "yassmineg/plateforme_electronique_k8s-user-auth-service:latest"
    "yassmineg/plateforme_electronique_notification-service:latest"
    "yassmineg/plateforme_electronique_payment-service:latest"
    "yassmineg/plateforme_electronique_signature-service:latest"
    "yassmineg/plateforme_electronique_subscription-service:latest"
    "yassmineg/plateforme_electronique_user-auth-service:latest"
)

echo "=== Début du pull des images dans Minikube ==="
echo ""

# Compteurs
total=${#images[@]}
skipped=0
pulled=0
failed=0

# Boucle sur toutes les images
for image in "${images[@]}"; do
    echo "[$((pulled + skipped + failed + 1))/$total] Vérification de $image"
    
    # Vérifier si l'image existe déjà
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^${image}$"; then
        echo "  ✓ Image déjà présente, passage au suivant"
        ((skipped++))
    else
        echo "  ⬇ Pull en cours..."
        if docker pull "$image"; then
            echo "  ✓ Pull réussi"
            ((pulled++))
        else
            echo "  ✗ Échec du pull"
            ((failed++))
        fi
    fi
    echo ""
done

# Résumé
echo "=== Résumé ==="
echo "Total d'images    : $total"
echo "Déjà présentes    : $skipped"
echo "Nouvelles pullées : $pulled"
echo "Échecs            : $failed"
echo ""

# Revenir au Docker local
eval $(minikube docker-env -u)

echo "=== Terminé - Retour au Docker local ==="
