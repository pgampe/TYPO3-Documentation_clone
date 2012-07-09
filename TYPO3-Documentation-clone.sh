#!/bin/bash

# This script is in the public domain.
# Based on an idea by Fabien Udriot
# see http://pastie.org/4225971

# Enter your username for typo3.org here. If no username is entered here, you
# will be promted for it during execution.
username=""

if [[ -z "$username" ]]; then
	read -p "Please enter your typo3.org username: " -r username
fi

# Asks the user if he wants to perform a dry run only.
read -p "Do you want to actually run the commands? [y/N] " answer

if [[ "$answer" = [yYjJ] ]]
then
	dryrun=false
	echo "Performing the actual commands."
else
	dryrun=true
	echo "Performing a dry run only."
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
else
	# Execute commands
	echo "$list_of_projects" \
		| sed 's/ /\n/g' \
		| parallel --jobs 1 "mkdir -p $(pwd)/{1}"

	echo "$list_of_projects" \
		| sed 's/ /\n/g' \
		| parallel --jobs 2 "cd $(pwd)/{1}; echo {1}; git clone --recursive git://git.typo3.org/{1}.git ."
fi
