#!/bin/bash

# Liste de personnes
personnes=("Marc" "Regine" "Nathalie" "Claude" "Monique" "Suzanne" "Babou" "Arnaud" "Sam" "Laura")

# Exclusions dans les deux sens
exclusions=("Laura Sam" "Sam Laura" "Marc Regine" "Regine Marc" "Babou Arnaud" "Arnaud Babou" "Monique Claude" "Claude Monique")

# Ajouter les exclusions spécifiées à la liste des exclusions
exclusions+=("Laura Sam" "Sam Laura" "Marc Regine" "Regine Marc" "Babou Arnaud" "Arnaud Babou" "Monique Claude" "Claude Monique")

# Mélanger la liste de personnes de manière aléatoire
personnes=($(shuf -e "${personnes[@]}"))

# Initialiser les listes des offrants et des destinataires
offrants=("${personnes[@]}")
destinataires=("${personnes[@]}")

# Créer les paires en respectant les exclusions
cadeaux=()
for offrant in "${offrants[@]}"; do
    # Exclure les destinataires impossibles
    candidats=($(comm -23 <(echo "${destinataires[@]}" | tr ' ' '\n' | sort | grep -v "$offrant") <(echo "${exclusions[@]}" | tr ' ' '\n' | sort | grep -v "$offrant" | tr '\n' ' ')))
    
    if [ ${#candidats[@]} -eq 0 ]; then
        echo "Impossible de former une paire pour $offrant avec les exclusions actuelles."
        exit 1
    fi

    # Choisir un destinataire aléatoire parmi les candidats possibles
    index=$((RANDOM % ${#candidats[@]}))
    destinataire=${candidats[$index]}

    # Ajouter la paire à la liste des cadeaux
    cadeaux+=("$offrant offre un cadeau à $destinataire")

    # Mettre à jour les listes des offrants et destinataires
    offrants=("${offrants[@]/$offrant}")
    destinataires=("${destinataires[@]/$destinataire}")
done

# Afficher les résultats
echo "Tirage au sort des cadeaux :"
for cadeau in "${cadeaux[@]}"; do
    echo $cadeau
done

