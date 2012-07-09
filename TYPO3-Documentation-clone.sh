#!/bin/bash

# This script is in the public domain.

# Enter your username for typo3.org here
username=""
dryrun=true

if [[ -z "$USERNAME" ]]; then
	read -p "Please enter your typo3.org username: " -r username
fi

# Fetch the list of projects
list_of_projects="$(ssh "$username@review.typo3.org" -p 29418 "gerrit ls-projects" | grep -e "^Documentation/TYPO3")"

if [[ "$dryrun" = "true" ]]
then
	# Dry run mode, will only output the commands
	echo "$list_of_projects" \
		| sed 's/ /\n/g' \
		| parallel --jobs 1 'echo "mkdir -p $(pwd)/{1}"'

	echo "$list_of_projects" \
		| sed 's/ /\n/g' \
		| parallel --jobs 2 'echo "cd $(pwd)/{1}; echo {1}; git clone --recursive git://git.typo3.org/{1}.git ."'
fi

# Execute commands
echo "$list_of_projects" \
	| sed 's/ /\n/g' \
	| parallel --jobs 1 "mkdir -p $(pwd)/{1}"

echo "$list_of_projects" \
	| sed 's/ /\n/g' \
	| parallel --jobs 2 "cd $(pwd)/{1}; echo {1}; git clone --recursive git://git.typo3.org/{1}.git ."
