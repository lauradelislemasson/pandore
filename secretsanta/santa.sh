#!/bin/bash

# Fonction pour effectuer le tirage au sort
tirage_cadeaux() {
    # Mélanger la liste des participants de manière aléatoire
    personnes=($(shuf -e "${participants[@]}"))

    # Initialiser les listes des donneurs et receveurs
    donneurs=("${personnes[@]}")
    receveurs=("${personnes[@]}")

    # Créer des paires, en excluant l'auto-cadeau et les paires avec des exclusions spécifiées
    cadeaux=()
    for donneur in "${donneurs[@]}"; do
        # Exclure l'auto-cadeau
        candidats=($(comm -23 <(echo "${receveurs[@]}" | tr ' ' '\n' | sort) <(echo "$donneur") | grep -v "$donneur"))

        # Exclure les paires avec des exclusions spécifiées
        for exclusion_pair in "${exclusion_pairs[@]}"; do
            exclusion_donneur=$(echo "$exclusion_pair" | awk '{print $1}')
            exclusion_receveur=$(echo "$exclusion_pair" | awk '{print $2}')
            
            candidats=($(echo "${candidats[@]}" | grep -vw "$exclusion_donneur" | grep -vw "$exclusion_receveur"))
        done

        if [ ${#candidats[@]} -eq 0 ]; then
            return 1  # Impossible de former une paire valide
        fi

        # Choisir un receveur aléatoire parmi les candidats restants
        index=$((RANDOM % ${#candidats[@]}))
        receveur=${candidats[$index]}

        # Ajouter la paire à la liste des cadeaux
        cadeaux+=("$donneur offre un cadeau à $receveur")

        # Mettre à jour les listes des donneurs et receveurs
        donneurs=("${donneurs[@]/$donneur}")
        receveurs=("${receveurs[@]/$receveur}")
    done

    return 0  # Le tirage au sort a réussi
}

# Demander les participants
echo "Veuillez saisir la liste des participants. Saisissez 'terminé' pour finir."

# Initialiser la liste des participants
participants=()

while true; do
    read -r -p "> " input

    if [ "$input" == "terminé" ]; then
        break
    else
        participants+=($input)
    fi
done

# Vérifier si le nombre de participants est pair
if [ $(( ${#participants[@]} % 2 )) -ne 0 ]; then
    echo "Le nombre de participants doit être pair. Veuillez saisir un nombre pair de participants."
    exit 1
fi

# Lire les paires d'exclusion depuis la première entrée
exclusion_pairs=($input)

# Effectuer le tirage, relancer si nécessaire pour respecter les exclusions
while ! tirage_cadeaux; do
    echo "Impossible de former une paire valide. Nouveau tirage..."
done

# Afficher les résultats du tirage
echo "Résultats du tirage des cadeaux :"
for cadeau in "${cadeaux[@]}"; do
    echo $cadeau
done

