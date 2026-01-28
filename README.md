# README_BD : Sauvegarde et Restauration PostgreSQL dans Kubernetes

Ce document détaille les procédures de sauvegarde et de restauration d'une base de données PostgreSQL opérant au sein d'un cluster Kubernetes (via ArgoCD).

---

## Pré-requis

* Accès configuré au cluster Kubernetes (`kubectl`).
* Pod PostgreSQL en cours d'exécution.
* Secret Kubernetes contenant les identifiants (ex: `plateforme-secrets`).

### Structure attendue du secret
```yaml
POSTGRES_USER:      <utilisateur>
POSTGRES_PASSWORD:  <mot_de_passe>
POSTGRES_DB:        <nom_base>
Bash
# Générer le dump dans le pod
kubectl exec -n default <pod> -- \
env PGPASSWORD=$(kubectl get secret plateforme-secrets -n default -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 --decode) \
pg_dump -U $(kubectl get secret plateforme-secrets -n default -o jsonpath="{.data.POSTGRES_USER}" | base64 --decode) -d postgres \
-f /tmp/backup.sql

# Copier le dump sur la machine locale
kubectl cp default/<pod>:/tmp/backup.sql ./backup.sql

# Nettoyer le pod (Optionnel)
kubectl exec -n default <pod> -- rm /tmp/backup.sql
Restauration via copie intermédiaire
Bash
# Copier le backup vers le pod cible
kubectl cp ./backup.sql default/<pod_cible>:/tmp/backup.sql

# Exécuter la restauration en interne
kubectl exec -n default -it <pod_cible> -- bash
export PGUSER=$(kubectl get secret plateforme-secrets -n default -o jsonpath="{.data.POSTGRES_USER}" | base64 --decode)
export PGPASSWORD=$(kubectl get secret plateforme-secrets -n default -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 --decode)
psql -U $PGUSER -d postgres -f /tmp/backup.sql
Restauration via injection directe
Bash
kubectl exec -i -n default <pod_cible> -- \
env PGPASSWORD=$(kubectl get secret plateforme-secrets -n default -o jsonpath="{.data.POSTGRES_PASSWORD}" | base64 --decode) \
psql -U $(kubectl get secret plateforme-secrets -n default -o jsonpath="{.data.POSTGRES_USER}" | base64 --decode) -d postgres < ./backup.sql
Vérification
SQL
-- Dans le pod cible
\c postgres
\dt
Notes importantes
Attention au -it : Ne jamais l'utiliser avec une redirection > vers un fichier local, cela corrompt le dump.

Méthodologie : Toujours privilégier l'option -f /tmp/backup.sql ou la redirection < ./backup.sql pour assurer l'intégrité du flux.

Industrialisation : Pour des sauvegardes récurrentes, il est recommandé de mettre en place un CronJob Kubernetes couplé à un volume persistant (PVC).
