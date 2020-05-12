#!/bin/bash

[[ ${1} == "-n" ]] || [[ ${1} == "--dry-run" ]] && run="echo "

function needs_sudo () {
    local dst="${1}"

    local dir=$(dirname "${dst}")
    if [[ -w "${dir}" ]]
    then return 1
    else return 0
    fi
}

function install_file () {
    src="${1}"
    dst="${2}"

    needs_sudo ${dst} && local sudo="sudo "
    ${run} ${sudo} mkdir -p $(dirname ${dst})
    ${run} ${sudo} cp ${src} ${dst}
}

function install_module () {
    local module_file="${1}"
    local module="$(dirname ${module_file})"

    while read -r src dst ; do
        local true_dst=$(eval "readlink -f ${dst}")
        install_file "${module}/${src}" "${true_dst}"
    done < "${module_file}"
}

find $(dirname $(readlink -f "${0}")) -maxdepth 2 -mindepth 2 -type f -name install |\
while read module_file ; do
    install_module "${module_file}"
done
