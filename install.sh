

# Beware I don't know why does it actually work on windows(wsl) regardless of all the errorrs
echo 

win_proof () {
	if [[ $(uname -r) == *"WSL"* ]]; then
		echo "$(echo "$@" | sed 's/ /\\ /g')"

	fi
}

this_file=$(realpath $(dirname -- "$0"))
sublime_settings="${this_file}/sublime-settings"

if [[ $(uname -r) == *"WSL"* ]]; then
	pretext=$(echo -e "$(cmd.exe /c echo "%APPDATA%\Sublime Text")")
	#echo ">>>"
	#echo "$pretext"
	#echo "C:\Users\iainv\AppData\Roaming\Sublime Text"
	#echo "<<<"
	wslpath -au "C:\Users\iainv\AppData\Roaming\Sublime Text"
	pretext="$(wslpath -au "$(echo ${pretext:1:-2})")"
	#echo ">>>"
	#echo "$pretext"
else
	pretext="$HOME/.config/sublime-text"
fi

#echo $this_file

echo " * Installing Sublime-Text configuration"

read -e -p ">>> Sublime (ABSOLUTE) installation path: " -i "$pretext" sublime_folder


echo " > Sublime-Text installation selectected at: $(win_proof $sublime_folder)"





if [ -d "$sublime_folder" ]; then
	echo " > Installation folder found!"
	if [[ $sublime_folder = *"/" ]]; then
		echo " > Removing backlash..."
		sublime_folder="${sublime_folder::-1}"
	fi
	user_folder=${sublime_folder}/"Packages/User"
	echo " > User settings folder: $(win_proof ${user_folder})"
	if [[ -d "${user_folder}" ]]; then
		if [[ $(uname -r) == *"WSL"* ]]; then
			echo " > So you are running Windows..."
		else
			echo -e " > Current files in user folder (\e[1;33myellow\e[0m] will be \e[1;31mover-written\e[0m):"
			#echo "$(win_proof "${user_folder}/*")"
			#ls "$(win_proof "${user_folder}/*")"
			for file in $(win_proof "${user_folder}/*"); do 
					eq_file="${sublime_settings}/$(basename "${file}")"
					if [ -f "$eq_file" ]; then 
						echo -e "\e[1;33m   - $(basename "$file")\e[0m" 
					else
						echo "   - $(basename "$file")"
					fi 
				done
			#ls "$(win_proof "${user_folder}/*")"
		fi
		read -p ">>> This will overwite current files! Are you sure you want to continue? [Y/n] " confirmation
		

		if [[ $confirmation == "y"* ]] || [[ $confirmation == "Y"* ]] || [[ -z "$confirmation" ]]; then
			if [[ $(uname -r) == *"WSL"* ]]; then
				read -p " > A little prayer just in case? [prayer] " -i "I pray..." prayer
				if [[ -n "$prayer" ]]; then
					echo "$prayer" > "${user_folder}/prayer.txt"
				fi
				use_copy="y"
			else
				read -p ">>> By default this creates symlinks, would you rather copy the files? [y/N] " use_copy
			fi
			
			if [[ $use_copy == "n"* ]] || [[ $use_copy == "N"* ]] || [[ -z $use_copy ]]; then
				echo " > Creating new symlinks..."
			else
				echo " > Copying files..."
			fi
			
			for file in ${sublime_settings}/*; do 
				if [ -f "$file" ]; then 
					new_link="${user_folder}/$(basename "${file}")"
					echo "    - $(basename "${file}") >>> ${new_link}" 
					if [ -f "${new_link}" ]; then
						rm "${new_link}"
					fi
					if [[ $use_copy == "n"* ]] || [[ $use_copy == "N"* ]] || [[ -z "$use_copy" ]]; then
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