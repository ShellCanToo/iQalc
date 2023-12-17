#!/bin/sh

# 'iq_util.sh' is a Module of the iQalc/IQ precision calculator
# It is not an executable program

# Copyright Gilbert Ashley 18 December 2023
# Contact: perceptronic@proton.me  Subject-line: iQalc

# iq_util version=1.82

# shellcheck disable=SC2034,SC2154,SC2086,SC2004,SC2089,SC2090,SC2046

iqutil="is_num padchars incr ceil floor trunc padit"

## is_num
# check if an input is really a value
is_num_help(){
echo "  'is_num' usage: 'is_num number'
  is_num checks if 'number' is a valid value 
  and returns either a true or false condition.
  Example: 'is_num 4.22 ; echo \$?'  returns '0'"
}
is_num() {
    case $1 in 
        '-h') is_num_help >&2 ; return 1 ;;
        ''|*[!+0-9.-]*) return 1 ;;
        *'.'*'.'*|*+*+*|*-*-*) return 1 ;;
        *'.'|*-|*+|*+*-*|*-*+*) return 1 ;;
        [0-9]*-*|[0-9]*+*) return 1 ;;
        *) return 0 ;;
    esac
} ## is_num


# print a string of characters, 0's by default
# first arg is number, then char
# padchars 5  = 00000 ; padchars 4 1  = 1111
# padchars 3 '<'  =  <<<
padchars() { pscale=$1 ; shift
    char=${1:-0} cnt=0 pad=''
    while [ $cnt -lt ${pscale} ] ;do pad="${pad}$char" ; cnt=$((cnt+1)) ; done
    echo $pad 
}

# incr - Naive Addition - WIP
# increment a decimal or integer by 1 or some 
# other, preferably, single-digit amount, like 5
# The purpose of this function woud be to add
# rounding fucntionality to 'add' itself. Or to
# serve as a backend to round, etc.
# By default, it functions like away-from-zero rounding:
# incr 1.234 returns 1.235 ; incr -1.234 returns -1.235
# where the addend amount is 1. Use the '-a' option 
# incr -a5 1.234 returns 1.239
# This function does a digit-by-digit addition, so is very slow,
# but can handle numbers of any length. 
incr() { res='' tmpres='' 
    case $1 in -a*) addend=${1#*-a} ; shift ;; *) addend=1 ;; esac
    
    case $1 in '') echo "-> incr: Missing input" >&2 ; return ;; 
        *.*) int=${1%.*} frac=${1#*.} fracsize=${#frac} ;; 
        *) int=$1 fracsize=0 ;;
    esac
    case $int in -*) sign='-' int=${int#*-} ;; *) sign='' int=${int#*+} ;;esac
    case $addend in -*) asign='-' addend=${addend#*-} ;; *) asign='' addend=${addend#*+} ;;esac
    
    [ ${#int} -gt 18 ] && { echo "--> incr: Input too long"  >&2 ; return 1 ;}
    [ ${#addend} -gt 18 ] && { echo "--> incr: Addend too long"  >&2 ; return 1 ;}
    addend=${asign}${addend}
    
    str=${int}${frac}
    if [ ${#str} -lt 19 ] ; then
            res=$((str+$addend))
    else
        while [ -n "$str" ] ; do
            mask=${str%?*} ; char=${str#*"${mask}"} ; str=$mask
            tmpres=$((char+addend))
            case $tmpres in ??) addend=1 res="${tmpres#*?}$res" ;; 
                *) addend=0 res="${tmpres}$res" ;; 
            esac
            tmpres=''
        done
    fi
    case $fracsize in 0) echo ${sign}$res ;;
        *) cnt=0 newfrac=''
            while [ $cnt -lt $fracsize ] ; do
                mask=${res%?*} ; char=${res#*"${mask}"} ; res=$mask
                newfrac="${char}$newfrac" ; cnt=$((cnt+1))
            done
            echo ${sign}$res'.'$newfrac ;;
    esac
} ### incr
#

# ceiling as a separate function apart from round
ceil_help=" 'ceil' usage: ceil [-s?] decimal-number"
ceil() { ceil_scale=$defprec
    case $1 in -s*) ceil_scale=${1#*-s} ; shift ;; ''|-h) echo $ceil_help >&2 ; return  ;;esac
    case $1 in *.*) int=${1%%.*} frac=${1#*.} ;; 
        '') echo "-> ceil: Missing input" >&2 ; return 1 ;; 
        *) int=$1 frac='0' ;;
    esac
    case $int in -*) sign='-' int=${int#*-} ;; *) sign='' int=${int#*+} ;;esac
    cnt=0 ; oldfrac=$frac
    while [ $cnt -lt ${ceil_scale} ] ;do 
        mask=${frac#*?} ; char=${frac%"${mask}"*}
        newfrac="$newfrac${char}" ; frac=$mask
        pad='0'"$pad" ; cnt=$((cnt+1))
    done
    lastchar=$char ; mask=${frac#*?} ; char2round=${frac%"${mask}"*}
    case $sign in 
        '-')  case $ceil_scale in 0) out="-"$int ;; *) out="-"$int'.'${newfrac:-0} ;;esac ;;
        *)  case $ceil_scale in 
                0)  [ ${oldfrac:-0} -eq 0  ] && out=$int || out=$( add -s0 $int + 1 ) ;;
                *)  [ -z "$char2round" ] || pad=${pad#*?}'1'
                    out=$( add -s$ceil_scale '.'${pad:-0} + $int'.'${newfrac:-0}$char2round ) ;;
            esac 
        ;;
    esac
    echo $out
} ## ceil

# floor as a separate function apart from round
floor_help=" 'floor' usage: floor [-s?] decimal-number"
floor() { flr_scale=$defprec
    case $1 in -s*) flr_scale=${1#*-s} ; shift ;; ''|-h) echo $floor_help >&2 ; return  ;;esac
    case $1 in *.*) int=${1%%.*} frac=${1#*.} ;; 
        '') echo "-> floor: Missing input" >&2 ; return 1 ;; 
        *) int=$1 frac='0' ;;
    esac
    case $int in -*) sign='-' int=${int#*-} ;; *) sign='' int=${int#*+} ;;esac
    cnt=0 ; oldfrac=$frac
    while [ $cnt -lt ${flr_scale} ] ;do 
        mask=${frac#*?} ; char=${frac%"${mask}"*}
        newfrac="$newfrac${char}" ; frac=$mask
        pad='0'"$pad" ; cnt=$((cnt+1))
    done
    lastchar=$char ; mask=${frac#*?} ; char2round=${frac%"${mask}"*}
    case $sign in 
        '-')    case $flr_scale in
                    0)  [ ${oldfrac} -eq 0  ] && out="-"$int || out="-"$( add -s0 $int + 1 ) ;;
                    *)  [ -z "$char2round" ] || pad=${pad#*?}'1'
                        out=${sign#*+}$( add -s$flr_scale '.'${pad} + $int'.'${newfrac:-0}$char2round ) ;;
                esac ;;
        *)  case $flr_scale in 0) out=$int ;; *) out=$int'.'${newfrac:-0} ;;esac ;;
    esac
    echo $out
} ## floor


## trunc and padit can optionally use print for truncation or printing
# strings of zeroes for padding.
# support for 'printf' varies among the various shells.
# So, to use even ONE feature of printf we would have to check if the shell
# being used supports that feature. For two features, 2 tests.
# For heavy repeated use within a single instance of IQ, one should
# put the have_printf1/2 test or tests outside the function, so they
# are only performed once. Otherwise, uncommenting the tests inside
# the function itself will allow printf to be used.
# Any speed-advantage from using printf for either of these purposes
# can only be seen when dealing with very long numbers >40-50 digits.

# 'posh' has no printf at all

## Case 1 - truncate a decimal number to a given prescision
# dash, ksh, busybox-ash, bash, zsh and yash support this form:
# 'printf "%.3s" "1.1234"' which prints '1.1'
# uncomment the next 2 lines to use trunc with printf
#printf "%.1s" "1.1234" 1>/dev/null 2>/dev/null
#case $? in 0) have_printf1=1 ;; *) have_printf1=0 ;;esac

# Case 1 - truncate a fraction
# truncation is equivalent to round-toward-zero
trunc() { 
    case $1 in -s*) tscale=${1#*-s} ; shift ;; *) tscale=$defprec ;; esac
    [ 0 = "$tscale" ] && { echo ${1%%.*} ; return ;}
    # uncomment the next 2 lines to use trunc with printf
    
    #printf "%.1s" "1.1234" 1>/dev/null 2>/dev/null
    #case $? in 0) have_printf1=1 ;; *) have_printf1=0 ;;esac
    
    case $1 in 
        *.*) if [ 1 = "$have_printf1" ] ; then 
                echo ${1%%.*}'.'$(printf "%.${tscale}s" ${1#*.}) ; return
            else
                int=${1%%.*} frac=${1#*.}
                while [ ${#frac} -gt $tscale ] ;do frac=${frac%?*} ;done
                echo ${int%%.*}'.'$frac
            fi
        ;;
        *) echo $1 ;;
    esac
}

# Case 2 - Print a string of zeros of a given size
### ksh and busybox-ash do not support this usage:
# printf "%03d"  , which prints a string of 3 0's
# uncomment the next 2 lines to use padit with printf
#printf "%01d" 1>/dev/null 2>/dev/null
#case $? in 0) have_printf2=1 ;; *) have_printf2=0 ;;esac

# Case 2 - print a string of zeros of the given size
padit() { case $1 in -s*) pscale=${1#*-s} ; shift ;; *) pscale=$1 ;; esac
    
    # uncomment the next 2 lines to use padit with printf
    #printf "%01d" 1>/dev/null 2>/dev/null
    #case $? in 0) have_printf2=1 ;; *) have_printf2=0 ;;esac

    if [ 1 = "$have_printf2" ] ; then
        pad=$(printf "%0${pscale}d")
    else
        cnt=0 pad=''
        while [ $cnt -lt ${pscale} ] ;do pad='0'"$pad" ; cnt=$((cnt+1)) ; done
    fi
    echo $pad
} ## padit
