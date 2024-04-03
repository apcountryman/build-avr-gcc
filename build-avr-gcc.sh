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

# Description: avr-gcc build script.

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
        "    $mnemonic - Build avr-gcc.\n" \
        "SYNOPSIS\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic --avr-gcc-version <avr-gcc-version>\n" \
        "        --install-prefix <install-prefix> [--jobs <jobs>]\n" \
        "OPTIONS\n" \
        "    --avr-gcc-version <avr-gcc-version>\n" \
        "        Specify the version of avr-gcc to build. The following avr-gcc\n" \
        "        versions are supported:\n" \
        "            8.3.0\n" \
        "            9.3.0\n" \
        "    --help\n" \
        "        Display this help text.\n" \
        "    --install-prefix <install-prefix>\n" \
        "        Specify the install prefix. '<install-prefix>/bin' must be in\n" \
        "        '\$PATH' prior to the execution of this script.\n" \
        "    --jobs <jobs>\n" \
        "        Specify the number of build jobs to use when building. If the number\n" \
        "        of jobs is not specified, 'nproc - 1' jobs will be used.\n" \
        "    --version\n" \
        "        Display the version of this script.\n" \
        "EXAMPLES\n" \
        "    $mnemonic --help\n" \
        "    $mnemonic --version\n" \
        "    $mnemonic --avr-gcc-version 8.3.0 --install-prefix ~/bin/avr-gcc/8.3.0\n" \
        "    $mnemonic --avr-gcc-version 8.3.0 --install-prefix ~/bin/avr-gcc/8.3.0\n" \
        "        --jobs 1\n" \
        "    $mnemonic --avr-gcc-version 9.3.0 --install-prefix ~/bin/avr-gcc/9.3.0\n" \
        "    $mnemonic --avr-gcc-version 9.3.0 --install-prefix ~/bin/avr-gcc/9.3.0\n" \
        "        --jobs 1\n" \
        ""
}

function display_version()
{
    echo "$mnemonic, version $version"
}

function download()
{
    case "$avr_gcc_version" in
        8.3.0)
            case "$component" in
                gmp)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2"
                    ;;
                mpfr)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/mpfr-3.1.4.tar.bz2"
                    ;;
                mpc)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz"
                    ;;
                isl)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2"
                    ;;
                binutils)
                    local -r url="https://gcc.gnu.org/pub/binutils/releases/binutils-2.32.tar.xz"
                    ;;
                gcc)
                    local -r url="https://gcc.gnu.org/pub/gcc/releases/gcc-8.3.0/gcc-8.3.0.tar.xz"
                    ;;
                avr-libc)
                    local -r url="svn://svn.savannah.nongnu.org/avr-libc/trunk/avr-libc@2551"
                    ;;
                *)
                    abort "'$component' is not a supported component"
            esac
            ;;
        9.3.0)
            case "$component" in
                gmp)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/gmp-6.1.0.tar.bz2"
                    ;;
                mpfr)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/mpfr-3.1.4.tar.bz2"
                    ;;
                mpc)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/mpc-1.0.3.tar.gz"
                    ;;
                isl)
                    local -r url="https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.18.tar.bz2"
                    ;;
                binutils)
                    local -r url="https://gcc.gnu.org/pub/binutils/releases/binutils-2.34.tar.xz"
                    ;;
                gcc)
                    local -r url="https://gcc.gnu.org/pub/gcc/releases/gcc-9.3.0/gcc-9.3.0.tar.xz"
                    ;;
                avr-libc)
                    local -r url="svn://svn.savannah.nongnu.org/avr-libc/trunk/avr-libc@2551"
                    ;;
                *)
                    abort "'$component' is not a supported component"
            esac
            ;;
        *)
            abort "'$avr_gcc_version' is not a supported avr-gcc version"
            ;;
    esac

    if [[ "$component" == "avr-libc" ]]; then
        if ! ( cd "$build_directory" && svn checkout "$url" "avr-libc" ); then
            abort "avr-libc checkout failure"
        fi
    else
        if ! ( cd "$build_directory" && wget "$url" ); then
            abort "$component download failure"
        fi
    fi
}

function extract()
{
    if [[ "$component" != "avr-libc" ]]; then
        if ! ( cd "$build_directory" && mkdir "$component" && tar -xf "$component"*.tar.* -C "$component" --strip-components 1 ); then
            abort "$component extraction failure"
        fi
    fi
}

function bootstrap()
{
    if [[ "$component" == "avr-libc" ]]; then
        if ! ( cd "$build_directory/avr-libc" && ./bootstrap ); then
            abort "avr-libc bootstrap failure"
        fi
    fi
}

function configure()
{
    case "$component" in
        gmp)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--disable-shared"
                "--disable-static"
                "--enable-cxx"
                "CPPFLAGS=-fexceptions"
            )
            ;;
        mpfr)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--disable-shared"
                "--disable-static"
                "--with-gmp=$install_prefix"
            )
            ;;
        mpc)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--disable-shared"
                "--disable-static"
                "--with-gmp=$install_prefix"
                "--with-mpfr=$install_prefix"
            )
            ;;
        isl)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--disable-shared"
                "--disable-static"
                "--with-gmp-prefix=$install_prefix"
            )
            ;;
        binutils)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--disable-shared"
                "--disable-static"
                "--target=avr"
                "--disable-nls"
                "--with-dwarf2"
                "--with-gmp=$install_prefix"
                "--with-mpfr=$install_prefix"
                "--with-mpc=$install_prefix"
                "--with-isl=$install_prefix"
            )
            ;;
        gcc)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--disable-shared"
                "--disable-static"
                "--target=avr"
                "--enable-languages=c,c++"
                "--disable-nls"
                "--disable-libssp"
                "--with-dwarf2"
                "--with-gmp=$install_prefix"
                "--with-mpfr=$install_prefix"
                "--with-mpc=$install_prefix"
                "--with-isl=$install_prefix"
            )
            ;;
        avr-libc)
            local -r configuration=(
                "--prefix=$install_prefix"
                "--host=avr"
            )
            ;;
        *)
            abort "'$component' is not a supported component"
            ;;
    esac

    if ! ( mkdir "$component_build_directory" && cd "$component_build_directory" && ../configure "${configuration[@]}" ); then
        abort "$component configuration failure"
    fi
}

function build()
{
    if ! ( cd "$component_build_directory" && make -j "$build_jobs" ); then
        abort "$component build failure"
    fi
}

function check()
{
    if ! ( cd "$component_build_directory" && make -j "$build_jobs" check ); then
        abort "$component build failure"
    fi
}

function install()
{
    if ! ( cd "$component_build_directory" && make -j "$build_jobs" install ); then
        abort "$component build failure"
    fi
}

function build_avr_gcc()
{
    local -r build_directory="$repository/build"

    rm -rf "$build_directory"

    if ! mkdir "$build_directory"; then
        abort "build directory creation failure"
    fi

    if ! mkdir -p "$install_prefix"; then
        abort "install directory creation failure"
    fi

    local -r components=(
        "gmp"
        "mpfr"
        "mpc"
        "isl"
        "binutils"
        "gcc"
        "avr-libc"
    )

    local component
    for component in "${components[@]}"; do
        local component_build_directory="$build_directory/$component/build"

        download
        extract
        bootstrap
        configure
        build
        check
        install
    done
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
            --avr-gcc-version)
                if [[ -n "$avr_gcc_version" ]]; then
                    abort "avr-gcc version already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "avr-gcc version not specified"
                fi

                local -r avr_gcc_version="$1"; shift
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
            --jobs)
                if [[ -n "$build_jobs" ]]; then
                    abort "build job count already specified"
                fi

                if [[ "$#" -le 0 ]]; then
                    abort "build job count not specified"
                fi

                local -r build_jobs="$1"; shift
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

    if [[ -z "$avr_gcc_version" ]]; then
        abort "'--avr-gcc-version' must be specified"
    fi

    if [[ -z "$build_jobs" ]]; then
        local -r build_jobs=$(( $( nproc ) - 1 ))
    fi

    if [[ -z "$install_prefix" ]]; then
        abort "'--install-prefix' must be specified"
    fi

    build_avr_gcc
}

main "$@"
