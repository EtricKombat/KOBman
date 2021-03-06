#!/usr/bin/env bash


function __kob_install {
	local environment_name=$1
	local version_id=$2
	mkdir -p ${KOBMAN_DIR}/envs/kobman-"${environment_name}"
	touch ${KOBMAN_DIR}/envs/kobman-${environment_name}/current
	current="${KOBMAN_DIR}/envs/kobman-${environment_name}/current"

	if [[ ! -f ${KOBMAN_DIR}/envs/kobman-${environment_name}.sh ]]; then
		__kobman_echo_debug "Could not find file kobman-$environment_name.sh"
		return 1
	fi
	if [[ ! -d ${KOBMAN_DIR}/envs/kobman-${environment_name}/$version_id ]];
	then
		mkdir -p ${KOBMAN_DIR}/envs/kobman-${environment_name}/$version_id
		# cd $version_id                                          # Needs to be refactored identify the latest version
		__kobman_echo_no_colour "$version_id" > "$current"
		cp "${KOBMAN_DIR}/envs/kobman-${environment_name}.sh" ${KOBMAN_DIR}/envs/kobman-${environment_name}/$version_id/
		source "${KOBMAN_DIR}/envs/kobman-${environment_name}/${version_id}/kobman-${environment_name}.sh"
		__kobman_install_"${environment_name}" "${environment_name}" "${version_id}"
	elif [[ -d ${KOBMAN_DIR}/envs/kobman-${environment_name}/$version_id && $(cat ${KOBMAN_DIR}/envs/kobman-${environment_name}/current) != "$version_id" ]];
	then
		__kobman_echo_no_colour "Re-installing ${environment_name} with version:${version_id} "
		__kobman_echo_no_colour "$version_id" > "$current"
		__kobman_install_"${environment_name}" "${environment_name}" "${version_id}"
	else
		__kobman_echo_white "${environment_name} $version_id is currently installed in your system "
		
	fi

}