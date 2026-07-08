
echo 
this_file=$(realpath $(dirname -- "$0"))
sublime_settings="${this_file}/sublime-settings/"
echo $this_file

echo " * Installing Sublime-Text configuration"


read -e -p ">>> Sublime (ABSOLUTE) installation path: " -i "$HOME/.config/sublime-text" sublime_folder


echo " > Sublime-Text installation selectected at: $sublime_folder"

if [ -d "$sublime_folder" ]; then
	echo " > Installation folder found!"
	if [[ $sublime_folder != *"/" ]]; then
		echo " > Adding backlash..."
		sublime_folder="${sublime_folder}/"
	fi
	user_folder="${sublime_folder}Packages/User/"
	echo " > User settings folder: ${user_folder}"
	if [ -d $user_folder ]; then
		echo -e " > Current files in user folder (\e[1;33myellow\e[0m] will be \e[1;31mover-written\e[0m):"
		for file in ${user_folder}*; do 
				eq_file="${sublime_settings}$(basename "${file}")"
				if [ -f "$eq_file" ]; then 
					echo -e "\e[1;33m   - $(basename "$file")\e[0m" 
				else
					echo "   - $(basename "$file")"
				fi 
			done
		read -p ">>> This will overwite current files! Are you sure you want to continue? [Y/n]" confirmation
		read -p ">>> By default this creates symlinks, would you rather copy the files? [y/N]" use_copy

		if [[ $confirmation == "y"* ]] || [[ $confirmation == "Y"* ]] || [[ -z $confirmation ]]; then
			
			if [[ $use_copy == "n"* ]] || [[ $use_copy == "N"* ]] || [[ -z $use_copy ]]; then
				echo " > Creating new symlinks..."
			else
				echo " > Copying files..."
			fi

			for file in ${sublime_settings}*; do 
				if [ -f "$file" ]; then 
					new_link="${user_folder}$(basename "${file}")"
					echo "    - $(basename "${file}") >>> ${new_link}" 
					if [ -f "${new_link}" ]; then
						rm "${new_link}"
					fi
					if [[ $use_copy == "n"* ]] || [[ $use_copy == "N"* ]] || [[ -z $use_copy ]]; then
						ln -sf "${file}" "${new_link}"
					else
						cp "${file}" "${new_link}"
					fi
				fi 
			done
			
		else
			echo " > Operation cancelled!"
			exit 1
		fi

	else
		echo "User settings folder does not exist!"
		exit 1
	fi

else 
	echo " > Installation folder not found!"
	exit 1
fi

echo "Installation completed succesfully!"
exit 0