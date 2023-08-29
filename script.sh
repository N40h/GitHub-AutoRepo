#!/bin/bash

if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found."
    exit 1
fi

function createRepo {
    local repo="$1"
    local description="$2"
    local bearer="$GITHUB_BEARER_TOKEN"

    # JSON payload for creating the repository
    payload='{
        "name": "'"${repo}"'",
        "description": "'"${description}"'",
        "auto_init": true
    }'

    # Make POST request to create the repository
    url="https://api.github.com/user/repos"
    response=$(curl -s -X POST -H "Content-Type: application/json" -H "Authorization: Bearer ${bearer}" -d "$payload" "$url")

    # Check if the request was successful
    http_status=$(echo "$response" | grep -o '"http_status": [0-9]*' | grep -o '[0-9]*')

    if [ -n "$http_status" ] && [ "http_status" -ne 201 ]; then
        echo "Failed to create repository. HTTP status code: $http_status"
    else
        echo "Repository created successfully!"
    fi
}

function deleteRepo {
    local user="$1"
    local repo="$2"
    local bearer="$GITHUB_BEARER_TOKEN"

    # Make DELETE request to delete the repository
    url="https://api.github.com/repos/${user}/${repo}"
    response=$(curl -s -X DELETE -H "Authorization: Bearer ${bearer}" "$url")

    # Check if the request was successful
    http_status=$(echo "$response" | grep -o '"http_status": [0-9]*' | grep -o '[0-9]*')

    if [ -n "$http_status" ] && [ "http_status" -ne 204 ]; then
        echo "Failed to delete repository. HTTP status code: $http_status"
    else
        echo "Repository deleted successfully!"
    fi
}

function updateRepo {
    local user="$1"
    local repo="$2"
    local bearer="$GITHUB_BEARER_TOKEN"

    read -p "Enter the new repository name: " newRepoName
    read -p "Enter the updated repository description: " newDescription
    read -p "Would you set this repository to private? (true/false): " isPrivate

    # JSON payload for updating the repository (replace this with your payload)
    payload='{
        "name": "'"${newRepoName}"'",
        "description": "'"${newDescription}"'",
        "private": '"${isPrivate}"'
    }'

    # Make PATCH request to update the repository
    url="https://api.github.com/repos/${user}/${repo}"
    response=$(curl -s -X PATCH -H "Content-Type: application/json" -H "Authorization: Bearer ${bearer}" -d "$payload" "$url")

    # Check if the request was successful
    http_status=$(echo "$response" | grep -o '"http_status": [0-9]*' | grep -o '[0-9]*')

    if [ -n "$http_status" ] && [ "http_status" -ne 200 ]; then
        echo "Failed to update repository. HTTP status code: $http_status"
    else
        echo "Repository updated successfully!"
    fi
}

echo "Select an action:"
echo "1. Create a repository"
echo "2. Update a repository"
echo "3. Delete a repository"

read -p "Select any option (1, 2, or 3): " option

case $option in
    1)
        read -p "Enter the repository name: " repo
        read -p "Enter the repository description: " description
        createRepo "$repo" "$description"
        ;;
    2)  
        read -p "Enter the owner name of the repository: " user
        read -p "Enter the repository name to be update: " repo
        updateRepo "${user}" "${repo}"
        ;;
    3) 
        read -p "Enter the owner name of the repository: " user
        read -p "Enter the repository name to delete: " repo
        deleteRepo "$user" "$repo"
        ;;
    *)
        echo "Invalid choice."
        ;;
esac