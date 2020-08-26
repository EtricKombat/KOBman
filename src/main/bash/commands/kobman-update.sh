#!/bin/bash

function __kob_update
{
	if [[ ! -f $KOBMAN_DIR/var/list.txt ]]; then
		__kobman_echo_red "Update failed"
		__kobman_echo_red "Could not find list file in your system."
		__kobman_echo_red "Please reinstall KOBman and try again"
		return 1
	fi

	[[ -f $KOBMAN_DIR/etc/user-config.cfg ]] && source "$KOBMAN_DIR/bin/kobman-init.sh"
	check_value_for_repo_env_var || return 1
	local env_repos namespace repo_name remote_list_url cached_list diff delta 
	cached_list=$KOBMAN_DIR/var/list.txt
	sort -u $cached_list >> old_list.txt
	env_repos=$(echo $KOBMAN_ENV_REPOS | sed 's/,/ /g')
	for i in ${env_repos[@]}; do
    	namespace=$(echo $i | cut -d "/" -f 1)
    	repo_name=$(echo $i | cut -d "/" -f 2)
		if [[ $namespace == $KOBMAN_NAMESPACE && $repo_name == "kobman_env_repo" ]]; then
			continue
		fi
    	
		if curl -s https://api.github.com/repos/$namespace/$repo_name | grep -q "Not Found"
    	then
      		continue
    	fi

		remote_list_url="https://raw.githubusercontent.com/$namespace/$repo_name/master/list.txt"
		__kobman_secure_curl "$remote_list_url" >> remote_list.txt
		remote=$(cat remote_list.txt)
		if [[ -z $remote ]]; then
			__kobman_echo_red "Update failed"
			__kobman_echo_red "Remote list corrupeted!!!!"
			rm remote_list.txt
			return 1
		fi
		cat $cached_list | sort -u >> sorted_local_list.txt
		sort -u remote_list.txt >> sorted_remote_list.txt
		diff=$(comm -3 sorted_local_list.txt sorted_remote_list.txt)
		if [[ -n $diff ]]; then
			__kobman_echo_no_colour "" >> $cached_list
			cat remote_list.txt | sort -u >> $cached_list
			__kobman_download_envs_from_repo $namespace $repo_name
		else
			continue
		fi	
	done
	sort -u $cached_list >> sorted_cached_list.txt
	delta=$(comm -3 sorted_cached_list.txt old_list.txt) 2> /dev/null
	if [[ -z $delta ]]; then
		__kobman_echo_no_colour "No updates found"
		[[ -f old_list.txt ]] && rm old_list.txt
	else
		rm remote_list.txt sorted_local_list.txt sorted_remote_list.txt old_list.txt sorted_cached_list.txt
		__kobman_echo_white "Updated successfully."
		__kobman_echo_no_colour ""
		__kobman_echo_white "Please run the below command to see the updated list"
		__kobman_echo_yellow "$ kob list"

	fi

	
	unset env_repos namespace repo_name remote_list_url cached_list diff delta 
	
}
##check this again
function check_value_for_repo_env_var
{
	if [[ -z $KOBMAN_ENV_REPOS ]]; then
		__kobman_echo_no_colour "No user repos found"
		return 1
	fi
}