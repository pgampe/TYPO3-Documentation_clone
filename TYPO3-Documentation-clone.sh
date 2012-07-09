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

start_dir="$(pwd)"

if [[ "$dryrun" = "true" ]]
then
	for project in $list_of_projects
	do
		echo "$project"
		project_dir="$(pwd)/$project"
		echo mkdir -p "$project_dir"
		echo cd "$project_dir"
		echo git clone --recursive "git://git.typo3.org/$project.git" .
	done
else
	for project in $list_of_projects
	do
		echo "$project"

		# Create a new directory for the git repository.
		project_dir="$(pwd)/$project"
		mkdir -p "$project_dir"
		cd "$project_dir"

		# Clone the actual repository.
		git clone --recursive "git://git.typo3.org/$project.git" .

		# Return to the old directory.
		cd "$start_dir"
	done
fi
