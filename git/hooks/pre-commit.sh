#!/usr/bin/env bash

# build-avr-gcc
#
# Copyright 2019, 2021-2024, Andrew Countryman <apcountryman@gmail.com> and the
# build-avr-gcc contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
# file except in compliance with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the specific language governing
# permissions and limitations under the License.

# Description: Git pre-commit hook script.

function error()
{
    local -r message="$1"

    ( >&2 echo "$mnemonic: $message" )
}

function abort()
{
    if [[ "$#" -gt 0 ]]; then
        local -r message="$1"

        error "$message, aborting"
    fi

    exit 1
}

function validate_script()
{
    if ! shellcheck "$script"; then
        abort
    fi
}

function display_help_text()
{
    printf "%b" \
        "NAME\n" \
        "    $mnemonic - Ensure commit preconditions are met.\n" \
        "SYNOPSIS\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic" \
        "OPTIONS\n" \
        "    --help\n" \
        "        Display this help text.\n" \
        "    --version\n" \
        "        Display the version of this script.\n" \
        "EXAMPLES\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic\n" \
        ""
}

function display_version()
{
    echo "$mnemonic, version $version"
}

function message()
{
    local -r content="$1"
    local -r content_length=${#content}
    local -r content_length_max=47
    local -r ellipsis_count_min=3
    local -r ellipsis_count=$(( content_length_max - content_length + ellipsis_count_min ))

    if [[ "$ellipsis_count" -lt "$ellipsis_count_min" ]]; then
        abort "increase content_length_max (ellipsis_count=$ellipsis_count)"
    fi

    local -r ellipsis=$( head -c "$ellipsis_count" < /dev/zero | tr '\0' '.' )

    echo -n "$mnemonic: $content $ellipsis "
}

function message_status_no_errors_found()
{
    echo "none"
}

function message_status_errors_found()
{
    echo "error(s) found"
}

function ensure_filenames_are_portable()
{
    message "checking for non-portable (non-ASCII) filenames"

    if [[ $( git -C "$repository" diff --cached --name-only --diff-filter=A -z "$against" | LC_ALL=C tr -d '[ -~]\0' | wc -c ) != 0 ]]; then
        message_status_errors_found
        error "aborting commit due to non-portable (non-ASCII) filename(s)"
        abort
    fi

    message_status_no_errors_found
}

function ensure_no_whitespace_errors_are_present()
{
    message "checking for whitespace errors"

    if ! git -C "$repository" diff-index --check --cached "$against" -- > "/dev/null" 2>&1; then
        message_status_errors_found
        error "aborting commit due to whitespace error(s), listed below"
        git -C "$repository" diff-index --check --cached "$against" --
        abort
    fi

    message_status_no_errors_found
}

function ensure_no_script_errors_are_present()
{
    message "checking for script errors"

    local scripts; mapfile -t scripts < <( git -C "$repository" ls-files '*.sh' | xargs -r -d '\n' -I '{}' find "$repository/{}" ); readonly scripts

    if ! shellcheck "${scripts[@]}" > "/dev/null" 2>&1; then
        message_status_errors_found
        error "aborting commit due to script error(s), listed below"
        shellcheck "${scripts[@]}"
        abort
    fi

    message_status_no_errors_found
}

function main()
{
    local -r script=$( readlink -f "$0" )
    local -r mnemonic=$( basename "$script" )

    validate_script

    local -r repository=$( readlink -f "$( dirname "$script" )/../.." )
    local -r version=$( git -C "$repository" describe --match=none --always --dirty --broken )

    while [[ "$#" -gt 0 ]]; do
        local argument="$1"; shift

        case "$argument" in
            --help)
                display_help_text
                exit
                ;;
            --version)
                display_version
                exit
                ;;
            --*)
                ;&
            -*)
                abort "'$argument' is not a supported option"
                ;;
            *)
                abort "'$argument' is not a valid argument"
                ;;
        esac
    done

    if git -C "$repository" rev-parse --verify HEAD > "/dev/null" 2>&1; then
        local -r against=HEAD
    else
        local -r against=$( git hash-object -t tree "/dev/null" )
    fi

    ensure_filenames_are_portable
    ensure_no_whitespace_errors_are_present
    ensure_no_script_errors_are_present
}

main "$@"
