#!/bin/sh

# This file is part of the iQalc/IQ precision calculator

# Copyright Gilbert Ashley 5 July 2023
# Contact: perceptronic@proton.me  Subject-line: iQalc

# iq_util version=1.79
# new file

# new function: trunc -back again, uses printf, if available
# new function: incr - performs away-from-zero rounding of results
# new function: padit - print a string of zeros of a given size
# new function: pads - print a string of any character of a given size
#

iqutil="is_num trunc round_up padit padchars "


## is_num is used by the execution block below
# but is not used by any of the main functions above
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
# print a string of characters, 0 by default
# first arg is number, then char
pads() { pscale=$1 ; shift
    char=${1:-0}
    cnt=0 pad=''
    while [ $cnt -lt ${pscale} ] ;do pad="${pad}$char" ; cnt=$((cnt+1)) ; done
    echo $pad 
}
# print a string of characters, 0's by default
# first arg is number, then char
padchars() { pscale=$1 ; shift
    char=${1:-0} cnt=0 pad=''
    while [ $cnt -lt ${pscale} ] ;do pad="${pad}$char" ; cnt=$((cnt+1)) ; done
    echo $pad 
}


# trunc, round_up and padit all optionally use
# printf so this check is used to enable that.
# also various quirks with zsh can be eliminated
#skip() {
# Check for 2 levels of printf compatibility. Even for
    # 2 simple features of printf, we have to vet the shells
    # posh has no printf at all
    printf "%.1s" "1.1234" 1>/dev/null 2>/dev/null
    case $? in 0) have_printf1=1 ;; *) have_printf1=0 ;;esac
    # ksh and busybox-ash don't support below use-case
    printf "%01d" 1>/dev/null 2>/dev/null
    case $? in 0) have_printf2=1 ;; *) have_printf2=0 ;;esac
    #echo have_printf1=$have_printf1 have_printf2=$have_printf2
    [ -n "$ZSH_VERSION" ] && emulate sh >/dev/null 2>/dev/null
#}

# truncate a fraction
trunc() { tscale=$1 ; shift
    [ 0 = "$tscale" ] && { echo ${1%%.*} ; return ;}
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
# print a string of zeros of the given size
padit() { pscale=$1 ; shift
    if [ 1 = "$have_printf2" ] ; then
        pad=$(printf "%0${pscale}d")
    else
        cnt=0 pad=''
        while [ $cnt -lt ${pscale} ] ;do pad='0'"$pad" ; cnt=$((cnt+1)) ; done
    fi
    echo $pad
}

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
        mask=${frac#*?} ; char=${frac%${mask}*}
        newfrac="$newfrac${char}" ; frac=$mask
        pad='0'"$pad" ; cnt=$((cnt+1))
    done
    lastchar=$char ; mask=${frac#*?} ; char2round=${frac%${mask}*}
    case $sign in 
        '-')    case $flr_scale in
                    0)  [ ${oldfrac} -eq 0  ] && out="-"$int || out="-"$( add -s0 $int + 1 ) ;;
                    *)  [ -z "$char2round" ] || pad=${pad#*?}'1'
                        out=${sign#*+}$( add -s$flr_scale '.'${pad} + $int'.'${newfrac:-0}$char2round ) ;;
                esac ;;
        *)  case $flr_scale in 0) out=$int ;; *) out=$int'.'${newfrac:-0} ;;esac ;;
    esac
    echo $out
}
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
        mask=${frac#*?} ; char=${frac%${mask}*}
        newfrac="$newfrac${char}" ; frac=$mask
        pad='0'"$pad" ; cnt=$((cnt+1))
    done
    lastchar=$char ; mask=${frac#*?} ; char2round=${frac%${mask}*}
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

#round_help=" 'round' usage: round (ceil|floor|hup|hev) [-s?] decimal-number"
round_help(){
echo "  'round' usage: round (method) [-s?] decimal-number
  
  Where 'method' is 'ceil' 'flor' 'hfup' 'hfev' or 'trnc'. 
  That is, ceiling, floor, half-up, half-even or truncation
  which is effectively toward-zero rounding.
  Note that 'method' comes before the '-s?' scale option.
  
  Example: 'round ceil -s0 4.001' returns '5'
  Example: 'round floor -s2 -4.001' returns '-4.01'
  Example: 'round hup -s2 4.005' returns '4.01'
  Example: 'round hev -s9 0.9999999985' returns '0.999999998'
  Example: 'round hev -s9 0.9999999995' returns '1.000000000'
  
  "
}
round() { rnd_scale=$defprec
    case $1 in ''|-h) round_help >&2 ; return ;; *) method=$1 ; shift ;;esac
    case $1 in -s*) rnd_scale=${1#*-s} ; shift ;;esac
    case $1 in *.*) int=${1%%.*} frac=${1#*.} ;; 
        '') echo "-> round: Missing input" >&2 ; return ;; 
        *) int=$1 frac='0' ;;
    esac
    case $int in -*) sign='-' int=${int#*-} ;; *) sign='' int=${int#*+} ;;esac
    # truncate, or round-toward-zero is easy out
    case $method in trnc|trunc) while [ ${#frac} -gt $rnd_scale ] ;do frac=${frac%?*} ;done
            # remove trailing zeros ??
            while : ; do  case $frac in *?0) frac=${frac%?*} ;; *) break ;;esac ;done
            echo ${sign}${int}'.'$frac
            return ;;
    esac
    oldfrac=$frac
    
    case $rnd_scale in 
        0) mask=${int%?*} ; lastchar=${int#*"$mask"} ;;
        *) cnt=0 ; pad=''
            while [ $cnt -lt ${rnd_scale} ] ;do 
                mask=${frac#*?} ; char=${frac%${mask}*}
                newfrac="$newfrac${char}" ; frac=$mask
                pad='0'"$pad" ; cnt=$((cnt+1))
            done
            lastchar=$char
        ;;
    esac
    
    mask=${frac#*?} ; char2round=${frac%${mask}*}
    
    case $method in
        ceil)   if [ '-' = "$sign" ] ; then
                     case $rnd_scale in 0) out="-"$int ;; *) out="-"$int'.'${newfrac:-0} ;;esac
                else
                    case $rnd_scale in 
                        0) tsst ${oldfrac:-0} -eq 0  && out=$int || out=$( add -s0 $int + 1 ) ;;
                        *)  [ ${char2round:-0} = 0 ] || pad=${pad#*?}'1'
                            out=$( add -s$rnd_scale '.'${pad:-0} + $int'.'${newfrac:-0}$char2round ) ;;
                    esac
                fi
        ;;
        floor|flor)  
                if [ '-' = "$sign" ] ; then
                    case $rnd_scale in
                        0)  tsst ${oldfrac} -eq 0 && out="-"$int || out="-"$( add -s0 $int + 1 ) ;;
                        *)  [ ${char2round:-0} = 0 ] || pad=${pad#*?}'1'
                            out=${sign#*+}$( add -s$rnd_scale '.'${pad} + $int'.'${newfrac}$char2round ) ;;
                    esac
                else
                    case $rnd_scale in 0) out=$int ;; *) out=$int'.'${newfrac} ;;esac
                fi
        ;;
        # half-up
        hup|hfup) pad=$pad'5'
            out=${sign#*+}$( add -s$rnd_scale '.'$pad + $int'.'${newfrac}$char2round )  ;;
        # half-even
        hev|hfev) signal=$( cmp3w $char2round 5) 
            case $signal in '=')
                    if [ $(( ${lastchar:-0} % 2 )) = "0"  ] ; then
                        # if previous digit is even, truncate
                        # but only if the rest of the fraction is zero
                        case $mask in 
                            *[!0]*) pad=$pad'5' newfrac="$newfrac${char2round}"
                                    out=${sign#*+}$( add -s$rnd_scale '.'$pad + $int'.'${newfrac:-0} ) ;;
                                *) out=${sign#*+}$int'.'${newfrac:-0} ;;
                        esac
                    else
                        # if odd, round half-up
                        pad=$pad'5' newfrac="$newfrac${char2round}"
                        out=${sign#*+}$( add -s$rnd_scale '.'$pad + $int'.'${newfrac:-0} )
                    fi
                ;;
                '>')  newfrac="$newfrac${char2round}" ; pad=${pad}'5'
                      out=${sign#*+}$( add -s$rnd_scale '.'$pad + $int'.'${newfrac:-0} )
                ;;
                '<')
                    case $rnd_scale in 0) out=${sign#*+}$int ;; *) out=${sign#*+}$int'.'${newfrac:-0} ;;esac
                ;;
            esac
        ;;
    esac
    pad=''
    echo $out
}

# increment a decimal or integer, away from zero
# 1.234 becomes 1.235 ; -1.234 becomes -1.235
incr() { res='' tmpres='' carry=1
    case $1 in '') echo "-> incr: Missing input" >&2 ; return ;; 
        *.*) int=${1%.*} frac=${1#*.} fracsize=${#frac} ;; 
        *) int=$1 fracsize=0 ;;
    esac
    case $int in -*) sign='-' int=${int#*-} ;; *) sign='' int=${int#*+} ;;esac
    
    str=${int}${frac}
    if [ ${#str} -lt 19 ] ; then
            res=$((str+1))
    else
        while [ -n "$str" ] ; do
            mask=${str%?*} ; char=${str#*${mask}} ; str=$mask
            tmpres=$((char+carry))
            case $tmpres in ??) carry=1 res="${tmpres#*?}$res" ;; *) carry=0 res="${tmpres}$res" ;; esac
            tmpres=''
        done
    fi
    case $fracsize in 0) echo ${sign}$res ;;
        *) cnt=0 newfrac=''
            while [ $cnt -lt $fracsize ] ; do
                mask=${res%?*} ; char=${res#*${mask}} ; res=$mask
                newfrac="${char}$newfrac" ; cnt=$((cnt+1))
            done
            echo ${sign}$res'.'$newfrac ;;
    esac
}
