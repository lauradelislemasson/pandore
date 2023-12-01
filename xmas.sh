#!/bin/bash

# Fonction pour effectuer le tirage au sort
tirage_au_sort() {
    # Mélanger la liste de participants de manière aléatoire
    personnes=($(shuf -e "${participants[@]}"))

    # Initialiser les listes des offrants et des destinataires
    offrants=("${personnes[@]}")
    destinataires=("${personnes[@]}")

    # Créer les paires en interdisant les auto-cadeaux
    cadeaux=()
    for offrant in "${offrants[@]}"; do
        # Exclure l'offrant lui-même
        candidats=($(comm -23 <(echo "${destinataires[@]}" | tr ' ' '\n' | sort) <(echo "$offrant") | grep -v "$offrant"))

        if [ ${#candidats[@]} -eq 0 ]; then
            return 1  # Impossible de former une paire
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

    return 0  # Le tirage au sort a réussi
}

# Demander les participants
echo "Veuillez entrer la liste des participants. Entrez 'done' pour terminer."

# Initialiser la liste des participants
participants=()

while true; do
    read -r -p "> " input

    if [ "$input" == "done" ]; then
        break
    else
        participants+=($input)
    fi
done

# Vérifier si le nombre de participants est pair
if [ $(( ${#participants[@]} % 2 )) -ne 0 ]; then
    echo "Le nombre de participants doit être pair. Veuillez entrer un nombre pair de participants."
    exit 1
fi

# Effectuer le tirage au sort en relançant si nécessaire
while ! tirage_au_sort; do
    echo "Impossible de former une paire. Relance du tirage..."
done

# Afficher les résultats
echo "Tirage au sort des cadeaux :"
for cadeau in "${cadeaux[@]}"; do
    echo $cadeau
done

