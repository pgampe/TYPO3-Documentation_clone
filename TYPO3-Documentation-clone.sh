#!/bin/bash

# This script is in the public domain.
# Based on an idea by Fabien Udriot
# see http://pastie.org/4225971

# Gather ANSI escape codes.
bold=$(tput bold)
green=$(tput setaf 2)
reset=$(tput sgr0)

# Enter your username for typo3.org here. If no username is entered here, you
# will be promted for it during execution.
username=""

if [[ -z "$username" ]]; then
	read -p "Please enter your typo3.org username: " -r username
fi

# Fetch the list of projects.
list_of_projects="$(ssh "$username@review.typo3.org" -p 29418 "gerrit ls-projects" | grep -e "^Documentation/TYPO3")"

start_dir="$(pwd)"

for project in $list_of_projects
do
	# Print out the project name in bold green.
	echo "${bold}${green}${project}${reset}"

	# Create a new directory for the git repository.
	project_dir="$(pwd)/$project"
	mkdir -p "$project_dir"
	cd "$project_dir"

	# Clone the actual repository.
	git clone --recursive "git://git.typo3.org/$project.git" .

	# Fetch gerrit commit hook.
	scp -p -P 29418 "$username@review.typo3.org:hooks/commit-msg" .git/hooks/

	# Init potential submodules.
	if [[ -n "$(git submodule status)" ]]
	then
		git submodule update --init
		git submodule foreach "scp -p -P 29418 \"$username@review.typo3.org:hooks/commit-msg\" .git/hooks/"
	fi

	# Return to the old directory.
	cd "$start_dir"
done
