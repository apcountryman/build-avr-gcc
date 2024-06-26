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

# Description: avr-gcc device family pack install script.

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
        "    $mnemonic - Install an avr-gcc device family pack.\n" \
        "SYNOPSIS\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic --install-prefix <install-prefix>\n" \
        "        --family-pack <name> <version>\n" \
        "OPTIONS\n" \
        "    --family-pack <name> <version>\n" \
        "        Specify the name and version of the device family pack to install.\n" \
        "    --help\n" \
        "        Display this help text.\n" \
        "    --install-prefix <install-prefix>\n" \
        "        Specify avr-gcc's install prefix.\n" \
        "    --version\n" \
        "        Display the version of this script.\n" \
        "EXAMPLES\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic --install-prefix ~/bin/avr-gcc/9.3.0\n" \
        "        --family-pack ATmega 3.1.264\n" \
        ""
}

function display_version()
{
    echo "$mnemonic, version $version"
}

function download()
{
    if ! ( cd "$build_directory" && wget "https://packs.download.microchip.com/$family_pack.atpack" ); then
        abort "device family pack download failure"
    fi
}

function extract()
{
    if ! unzip "$build_directory/$family_pack.atpack" -d "$build_directory/$family_pack"; then
        abort "device family pack extraction failure"
    fi
}

function install_device_specs()
{
    local device_specs; mapfile -t device_specs < <( find "$build_directory/$family_pack/gcc/dev" -name "specs-*" ); readonly device_specs

    local -r install_directory="$( find "$install_prefix/lib/gcc/avr" -type d -name "device-specs" )"

    local device_spec
    for device_spec in "${device_specs[@]}"; do
        if ! cp "$device_spec" "$install_directory"; then
            abort "$device_spec install failure"
        fi
    done
}

function install_device_startup_files_and_libraries()
{
    local devices; mapfile -t devices < <( find "$build_directory/$family_pack/gcc/dev" -mindepth 1 -maxdepth 1 -type d ); readonly devices

    local device
    for device in "${devices[@]}"; do
        local device_startup_files_and_libraries; mapfile -t device_startup_files_and_libraries < <( cd "$device" && find . -mindepth 1 -maxdepth 1 -type d ! -name "device-specs" )

        local device_startup_file_and_library
        for device_startup_file_and_library in "${device_startup_files_and_libraries[@]}"; do
            if ! ( cd "$device" && tar -czvf "$device_startup_file_and_library.tar.gz" "$device_startup_file_and_library" && tar -xzvf "$device_startup_file_and_library.tar.gz" -C "$install_prefix/avr/lib" ); then
                abort "$device $device_startup_file_and_library install failure"
            fi

        done
    done
}

function install_header_files()
{
    local header_files; mapfile -t header_files < <( find "$build_directory/$family_pack/include/avr" -name "*.h" ); readonly header_files

    local header_file
    for header_file in "${header_files[@]}"; do
        if ! cp "$header_file" "$install_prefix/avr/include/avr/"; then
            abort "$header_file install failure"
        fi
    done
}

function install_device_family_pack()
{
    local -r build_directory="$repository/build"

    rm -rf "$build_directory"

    if ! mkdir "$build_directory"; then
        abort "build directory creation failure"
    fi

    download
    extract
    install_device_specs
    install_device_startup_files_and_libraries
    install_header_files
}

function main()
{
    local -r script=$( readlink -f "$0" )
    local -r mnemonic=$( basename "$script" )

    validate_script

    local -r repository=$( dirname "$script" )
    local -r version=$( git -C "$repository" describe --match=none --always --dirty --broken )

    while [[ "$#" -gt 0 ]]; do
        local argument="$1"; shift

        case "$argument" in
            --family-pack)
                if [[ -n "$family_pack" ]]; then
                    abort "device family pack already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "device family pack name and version not specified"
                fi

                if [[ "$#" -le 1 ]]; then
                    abort "device family pack version not specified"
                fi

                local -r family_pack_name="$1"; shift
                local -r family_pack_version="$1"; shift

                local -r family_pack="Microchip.${family_pack_name}_DFP.${family_pack_version}"
                ;;
            --help)
                display_help_text
                exit
                ;;
            --install-prefix)
                if [[ -n "$install_prefix" ]]; then
                    abort "install prefix already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "install prefix not specified"
                fi

                local -r install_prefix="$1"; shift
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

    if [[ -z "$install_prefix" ]]; then
        abort "'--install-prefix' must be specified"
    fi

    if [[ -z "$family_pack" ]]; then
        abort "'--family-pack' must be specified"
    fi

    install_device_family_pack
}

main "$@"
