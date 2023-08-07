#!/bin/sh
# - iQalc or 'iq' is a precision decimal calculator for the shell

# Copyright Gilbert Ashley 7 August 2023
# Contact:  perceptronic@proton.me  Subject-line: iQalc

# Operations supported: addition, subtraction, multiplication, division,
# remainder, modulo, divmod and numeric comparison of decimal values.

# This is a condensed version of the basic iq arithmetic operations,
# for a light-weight and easy way to add Decimal math operations
# to any shell script. The differences between this header-style
# math.h.sh and the normal iq executable program are: 
# - No rounding is done and round() function is not included
# - Has only minimal help info for each function
# - Input-validation is disabled, but can be easily enabled and
#     then uses a debug-version of validate_inputs
# - Includes an optional debug-version of is_num for checking inputs
# - Has no Execution Block -is not meant to be used as an executable
# - Smaller Footprint of ~360 code-lines -excluding debug code,
#     compared to ~560 lines of code in the full 'iq' program.
# - Additional functions from the iq library can be added to scripts

# See the bottom of the file for full instructions on using iq_math.h.sh 

# disable some style checks from shellcheck
# shellcheck disable=SC2086,SC2004,SC2295,SC2123

# iq_math.h.sh version=1.81

# default precision
defprec=${defprec:-6}
defzero='.0'

# tsst  - numeric comparison of decimal numbers using shell 'test' syntax
# depends on: 'cmp3w'
tsst_help="  'tsst' usage: 'tsst num1 (operator) num2'"
tsst() { case $1 in ''|-h|-s*) echo "$tsst_help" >&2 ; return 1 ;;esac
    tstret=$( cmp3w $1 $3 )
    case $2 in
        '-lt') [ "$tstret" = '<' ] ; return $? ;;
        '-le')  case $tstret in '<'|'=') return 0 ;; *) return 1 ;;esac ;;
        '-eq') [ "$tstret" = '=' ] ; return $? ;;
        '-ge')  case $tstret in '>'|'=') return 0 ;; *) return 1 ;;esac ;;
        '-gt') [ "$tstret" = '>' ] ; return $? ;;
        '-ne')  case $tstret in '=') return 1 ;; *) return 0 ;;esac ;;
    esac
} ## tsst
# tstret=

# 'cmp3w' compares 2 decimal numbers relatively, returning: '<', '=' or '>'
# depends on: /bin/sh
# used by: 'tsst' 'add' 'div'
# The input-handling routine used here, is similar to that used in most other
# functions so it's commented here, and later only where it differs from here
cmp3w_help="  'cmp3w' usage: 'cmp3w num1 num2'"
cmp3w() { case $1 in ''|-h|-s*) echo "$cmp3w_help" >&2  ; return 1 ;;esac
    # separate and store the signs of both inputs
    case $1 in '-'*) c1sign='-' c1=${1#*-} ;; *) c1sign='+' c1=${1#*+} ;;esac
    case $2 in '-'*) c2sign='-' c2=${2#*-} ;; *) c2sign='+' c2=${2#*+} ;;esac
    # separate the integer and fractional parts
    case $c1 in *.*) c1i=${c1%.*} c1f=${c1#*.} ;; *) c1i=$c1 c1f=0  ;;esac
    case $c2 in *.*) c2i=${c2%.*} c2f=${c2#*.} ;; *) c2i=$c2 c2f=0 ;;esac
    # default zeros
    c1i=${c1i:-0} c1f=${c1f:-0} c2i=${c2i:-0} c2f=${c2f:-0}
    # pad both integers and fractions until equal in length
    while [ ${#c1i} -gt ${#c2i} ] ;do c2i='0'$c2i ;done 
    while [ ${#c2i} -gt ${#c1i} ] ;do c1i='0'$c1i ;done
    while [ ${#c1f} -gt ${#c2f} ] ;do c2f=$c2f'0' ;done 
    while [ ${#c2f} -gt ${#c1f} ] ;do c1f=$c1f'0' ;done
    # recombine each number into an equi-length integer string
    c1=${c1i}$c1f c2=${c2i}$c2f
    # if both inputs are >18-digits, work left-to-right in chunks of 18 chars
    while [ ${#c1} -gt 18 ] ;do
        cmpmsk1=${c1#*??????????????????} cmp1=${c1%"${cmpmsk1}"*} 
        cmpmsk2=${c2#*??????????????????} cmp2=${c2%"${cmpmsk2}"*}
        c1=$cmpmsk1 c2=$cmpmsk2
        # if both chunks are only zeros, skip to next chunk
        case ${cmp1}$cmp2 in *[!0]*) : ;; *) continue ;; esac
        # Check (signed) for '>' or '<' condition. Prepended 1's protect any embedded zeros
        [ $c1sign'1'"$cmp1" -gt $c2sign'1'"$cmp2" ] && { echo '>' ; return ;}
        [ $c1sign'1'"$cmp1" -lt $c2sign'1'"$cmp2" ] && { echo '<' ; return ;}
    done
    # Do the same for inputs under 19 digits, or last chunks from above
    case ${c1}$c2 in *[!0]*) : ;; *) echo '=' ; return ;; esac
    [ $c1sign'1'"$c1" -gt $c2sign'1'"$c2" ] && { echo '>' ; return ;}
    [ $c1sign'1'"$c1" -lt $c2sign'1'"$c2" ] && { echo '<' ; return ;}
    # if we get here the numbers are definitely equal
    echo '='
} ## cmp3w
#c1= c1i= c1f= c1sign= c2= c2i= c2f= c2sign= cmp1= cmp2= cmpmsk1= cmpmsk2= 

# add - add and/or subtract 2 or more decimal numbers
# depends on: 'cmp3w'
# adds or subtracts large numbers in chunks of 16 digits
add_help="  'add' usage: 'add [-s?] num1 [+-] num2 ...'"
add(){ aprec=off
    case $1 in -s*) aprec=${1#*-s} ; shift ;; ''|-h) echo "$add_help" >&2 ; return 1 ;; esac
    
    # make sure we have only valid numbers and appropriate operators for add
    #validate_inputs_debug add $aprec $* || { echo "->add: Invalid input in '-s$aprec' '$@'" >&2 ; return 1 ; }
    
    # initial sum is the first input
    r_add=$1 ; shift
    while [ "$1" ] ;do
        # if next input is operator, record it and shift to next input
        case $1 in +|-) aoprtr=$1 ; shift ;;esac
        # get the next number
        anxt=$1
    
        # separate any signs from the numbers and establish positive/negative state of result
        case $r_add in -*) rsign='-' r_add=${r_add#*-} ;; *) rsign='+' r_add=${r_add#*+} ;;esac
        case $anxt in -*) anxtsign='-' anxt=${anxt#*-} ;; *) anxtsign='+' anxt=${anxt#*+} ;;esac
        # separate the integer and fraction parts of both numbers -dont allow single or trailing dot
        case $r_add in .*) rint=0 rfrac=${r_add#*.} ;; *.*) rint=${r_add%.*} rfrac=${r_add#*.} ;;
            *) rint=$r_add rfrac=0 ;;esac
        case $anxt in .*) nint=0 nfrac=${anxt#*.} ;; *.*) nint=${anxt%.*} nfrac=${anxt#*.} ;;
            *) nint=$anxt nfrac=0 ;;esac
            
        # pad fractions till equal-length = 'write one number above the other, aligning the decimal points'
        while [ ${#rfrac} -lt ${#nfrac} ] ;do rfrac=$rfrac'0' ;done
        while [ ${#nfrac} -lt ${#rfrac} ] ;do nfrac=$nfrac'0' ;done
        # get the size of the fraction after padding them
        afsize=${#rfrac}
        # front-pad integers till equal-length for accurate chunking.
        # This also means we are sending pre-formatted numbers to cmp3w
        while [ ${#rint} -lt ${#nint} ] ;do rint='0'$rint ;done
        while [ ${#nint} -lt ${#rint} ] ;do nint='0'$nint ;done
        # when an operator is used we need this step to handle these forms: 'a + -b', 'a - -b', 'a - +b'
        [ -n "$aoprtr" ] && case ${aoprtr}${anxtsign} in '++'|'--') anxtsign='+' ;; '+-'|'-+') anxtsign='-' ;;esac 
        # put _larger_ number first for an easier work-flow -we've pre-padded so this is fast
        case $( cmp3w '1'${rint}$rfrac '1'${nint}$nfrac ) in '<')  swpint=$rint swpfrac=$rfrac swpsign=$rsign 
            rint=$nint rfrac=$nfrac rsign=$anxtsign nint=$swpint nfrac=$swpfrac anxtsign=$swpsign ;;esac
        # the sign of the result, rsign, is the sign of the greater number(absolute value)
        
        # find the real operation we will be performing
        case ${rsign}${anxtsign} in '+-'|'-+') aoprtr='-' ;; *) aoprtr='+' ;;esac
        
        # assign recombined values to A and B, and recycle r_add
        A=${rint}$rfrac B=${nint}$nfrac r_add='' 
        case $aoprtr in 
        '+')    adsub=0 acry=0
            # work from right to left, just like doing it on paper
            # protect embedded 0's in chunks with leading 1's. This also
            # allows to easily check if a carry is triggered
            while [ ${#A} -gt 16 ] ;do
                admsk1=${A%????????????????*} Achnk='1'${A#*$admsk1} A=$admsk1    
                admsk2=${B%????????????????*} Bchnk='1'${B#*$admsk2} B=$admsk2
                adsub=$(( $Achnk + $Bchnk + $acry )) 
                # If result begins with '3', there was a carry
                case $adsub in 3*) acry=1 ;; *) acry=0 ;;esac
                # remove the extra leading digit which is a '2' or '3'
                r_add=${adsub#*?}$r_add 
            done
            # same for any last chunk or the original which was <17 digits
            if [ -n "$A" ] ; then
                Achnk='1'$A Bchnk='1'$B  adsub=$(( $Achnk + $Bchnk + $acry ))
                # if there was a carry(a leading 3), replace with '1'
                # otherwise we simply remove the leading '2'
                case $adsub in 3*) r_add='1'${adsub#*?}$r_add acry=0 ;; 
                    *) r_add=${adsub#*?}$r_add ;;
                esac
            fi
        ;;
        '-')
            if [ ${#A} -lt 19 ] ;then
                # if numbers are <19 digits, do short method
                # prepend a dummy '1' avoids depadding
                A='1'$A B='1'$B
                r_add=$(( $A - $B )) 
            else
                # subtract by chunks - first char of result is a signal for borrow
                adsub=0  acry=0
                # For subtraction, prepending 1's doesn't help us. We'd have to detect
                # the length of the result for borrow detection and decide whether
                # or not to remove the first digit of result. Using leading '3' and '1'
                # makes detection easy and the leading digit of result is always removed
                while [ ${#A} -ge 17 ] ;do
                    admsk1=${A%?????????????????*}  Achnk='3'${A#*$admsk1}  A=$admsk1
                    admsk2=${B%?????????????????*}  Bchnk='1'${B#*$admsk2}  B=$admsk2
                    [ "$acry" = 1 ] && { Bchnk=$(( $Bchnk + 1 ))  acry=0 ;}
                    adsub=$(( $Achnk - $Bchnk ))
                    # prepending 3 and 1 to the numbers above provides
                    # a borrow/carry signal in the first digit from the result
                    # if adsub begins with '2' no carrow/borrow was triggered
                    case $adsub in 1*) acry=1 ;;esac
                    # the leading 3/1 combination assures a constant result length
                    # so we don't have ask whether the result is shorter
                    adsub=${adsub#*?}
                    r_add=${adsub}$r_add
                done
                if [ -n "$A" ] ; then
                    # remove any left-over _extra_ leading zeros from both numbers
                    # we may have a carry, so we can't simply prepend 1's here
                    while : ; do case $A in '0'?*) A=${A#*?} ;; *) break ;;esac ;done
                    while : ; do case $B in '0'?*) B=${B#*?} ;; *) break ;;esac ;done
                    # just as above, use carry instead of borrow
                    [ "$acry" = 1 ] && { B=$(( $B + 1 ))  acry=0 ;}
                    adsub=$(( $A - $B ))
                    r_add=${adsub}$r_add
                fi
            fi
        esac
        # remove any neg sign -we already know what sign the result is
        r_add=${r_add#*-}
        # if result is shorter than frac size, front-pad till equi-length
        while [ ${#r_add} -lt $afsize ] ;do r_add='0'$r_add ;done   
        # separate the fraction from the result, working right-to-left
        adcnt=0   ofrac=''
        while [ $adcnt -lt $afsize ] ;do 
            admsk1=${r_add%?*} ofrac=${r_add#$admsk1*}$ofrac r_add=$admsk1 adcnt=$((adcnt+1))
        done
        # trim leading zeros, # dont leave '-' sign if answer is 0
        while : ;do case $r_add in '0'?*) r_add=${r_add#*?} ;; *) break ;;esac ;done
        # if answer is zero, make sure sign is not '-'
        case ${r_add}$ofrac in *[!0]*) : ;; *) rsign='' ;;esac
        # add the sign unless it's '+'
        r_add=${rsign#*+}${r_add:-0}'.'${ofrac:-0}
        # sanitize these variables for the next round, if any
        aoprtr='' anxtsign='' rsign=''
        shift 1
    done
    
    case $aprec in 
        0) echo ${r_add%.*} ;; off) echo $r_add ;; 
        *)  ofrac=${r_add#*.}
            while [ ${#ofrac} -gt $aprec ] ;do ofrac=${ofrac%?*} ;done
            # remove trailing zeros ??
            # while : ; do  case $ofrac in *?0) ofrac=${ofrac%?*} ;; *) break ;;esac ;done
            echo ${r_add%.*}'.'$ofrac ;;
    esac
    # sanitize exit variables
    aprec='' r_add='' ofrac=''
} ## add
# aoprtr= anxt= rsign= anxtsign= rint= rfrac= nint= nfrac= afsze= swpint= swpfrac= swpsign= # aprec= r_add=
# A= B= adsub= acry= admsk1= Achnk= admsk2= Bchnk= adcnt= ofrac=

# mul - multiply 2 or more decimal numbers
# depends on 'add'
# for large numbers, multiplies in chunks of 9 digits
mul_help="  'mul' usage: 'mul [-s?] num1 [xX] num2 ...'"
mul(){ mprec=off
    case $1 in -s*) mprec=${1#*-s} ; shift ;; ''|-h) echo "$mul_help" >&2 ; return 1 ;;esac
    
    # make sure we have only valid numbers and appropriate operators for mul
    #validate_inputs_debug mul $mprec $@ || { echo "->mul: Invalid input in '-s$mprec' '$@'" >&2 ; return 1 ; }
    
    [ "$mprec" = 0 ] && defzero=''
    # exit early if any input is zero, the answer will always be 0 
    # any variants of zero which get by here will be handled below
    case " $@ " in *" 0 "*|*" .0 "*|*" 0.0 "*) echo "0$defzero" ; return ;;esac
    
    r_mul=$1 ; shift
    while [ "$1" ] ;do  
        case $1 in x|X) shift ;;esac
        mnxt=$1
        case $r_mul in -*) mrsign='-' r_mul=${r_mul#*-} ;; *) mrsign='+' r_mul=${r_mul#*+} ;;esac
        case $mnxt in -*) mnxtsign='-' mnxt=${mnxt#*-} ;; *) mnxtsign='+' mnxt=${mnxt#*+} ;;esac
        case $r_mul in  .*) mrint=0 mrfrac=${r_mul#*.} ;; *.*) mrint=${r_mul%.*} mrfrac=${r_mul#*.} ;; 
            *) mrint=$r_mul mrfrac=0 ;;esac
        case $mnxt in  .*) mnint=0 mnfrac=${mnxt#*.} ;; *.*) mnint=${mnxt%.*} mnfrac=${mnxt#*.} ;; 
            *) mnint=$mnxt mnfrac=0 ;;esac
        # remove all leading zeros from integers
        while : ;do case $mrint in '0'*) mrint=${mrint#*?} ;; *) break ;;esac ;done
        while : ;do case $mnint in '0'*) mnint=${mnint#*?} ;; *) break ;;esac ;done 
        # also remove all trailing zeros from fractions
        while : ;do case $mrfrac in *'0') mrfrac=${mrfrac%?*} ;; *) break ;;esac ;done
        while : ;do case $mnfrac in *'0') mnfrac=${mnfrac%?*} ;; *) break ;;esac ;done
        # combine numbers
        Am=${mrint}$mrfrac  Bm=${mnint}$mnfrac  fastm=0
        if [ $(( ${#Am} + ${#Bm} )) -lt 19 ] ; then
            # get the full size of the result fraction
            mfsize=$(( ${#mrfrac} + ${#mnfrac} ))
            # if the integer portion is 0(null), also remove leading zeros from fractions
            [ -z $mrint ] && while : ;do case $mrfrac in '0'*) mrfrac=${mrfrac#*?} ;; *) break ;;esac ;done
            [ -z $mnint ] && while : ;do case $mnfrac in '0'*) mnfrac=${mnfrac#*?} ;; *) break ;;esac ;done
            fastm=1
        else
            # make sure _longer_ number is first for easier chunking
            if [ ${#Am} -lt ${#Bm} ] ; then
                swpint=$mrint swpfrac=$mrfrac swpsign=$mrsign mrint=$mnint mrfrac=$mnfrac mrsign=$mnxtsign 
                mnint=$swpint mnfrac=$swpfrac mnxtsign=$swpsign 
            fi
            mfsize=$(( ${#mrfrac} + ${#mnfrac} ))
        fi
        # determine the sign of result
        case ${mrsign}${mnxtsign} in '++'|'--') R_msign='+' ;; '+-'|'-+') R_msign='-' ;;esac
        
        # recombine numbers and reuse original input r_mul
        Am=${mrint}$mrfrac  Bm=${mnint}$mnfrac  r_mul=0
        
        # if either or both is '1', setup to skip calculation below
        # also check for zero(null) -even though we checked inputs
        # a zero could emerge from an underflow
        case $Am in '') echo 0$defzero ; return ;; 1) r_mul=$Bm ;;esac
        case $Bm in '') echo 0$defzero ; return ;; 1) r_mul=$Am ;;esac
        
        if [ "${Am}$Bm" = "11" ] ; then
            r_mul=1
        elif [ "$r_mul" = 0 ] ; then
            case $fastm in 1) r_mul=$(( $Am * $Bm )) ;;
                # long numbers get chunked
                *)  mchnksize=9 ocol=''
                    while [ -n "$Am" ] ;do
                        # if smaller than chunk size, use all, otherwise take a bite
                        if [ ${#Am} -lt $mchnksize ] ; then
                            Amchnk=$Am Am='' 
                        else
                            mumsk1=${Am%?????????*} Amchnk=${Am#*$mumsk1} Am=$mumsk1
                        fi
                        # depad
                        while : ;do case $Amchnk in '0'*) Amchnk=${Amchnk#*?} ;; *) break ;;esac ;done
                        if [ -n "$Amchnk" ] ; then
                            Bm=${mnint}$mnfrac mtmp=0 icol='' # reset
                            
                            while [ -n "$Bm" ] ;do 
                                if [ ${#Bm} -lt $mchnksize ] ; then
                                    Bmchnk=$Bm Bm=''
                                else
                                    mumsk2=${Bm%?????????*} Bmchnk=${Bm#*$mumsk2} Bm=$mumsk2
                                fi
                                # depad
                                while : ;do case $Bmchnk in '0'*) Bmchnk=${Bmchnk#*?} ;; *) break ;;esac ;done
                                if [ -n "$Bmchnk" ] ; then
                                    mchnk=''
                                    case $Amchnk'_'$Bmchnk in 
                                        1_1) mchnk=1 ;; 1_*) mchnk=$Bmchnk ;; *_1) mchnk=$Amchnk ;;
                                        *)  mchnk=$(( $Amchnk * $Bmchnk )) ;;
                                    esac
                                    mtmp=$( add -s0 $mtmp  ${mchnk}$icol )
                                fi
                                icol=$icol'000000000'
                            done
                            # add the temporary result to total
                            case $r_mul in 
                                    0) r_mul=${mtmp}$ocol ;;
                                    *) r_mul=$( add -s0 $r_mul ${mtmp}$ocol ) ;;
                            esac
                        fi
                        ocol=$ocol'000000000' icol=''
                    done
                ;;
            esac
        fi
        # process ouput from this round the same way as with 'add'
        r_mul=${r_mul#*-}
        while [ ${#r_mul} -lt $mfsize ] ;do r_mul='0'$r_mul ;done
        icol=''   mtmp=0  mcnt=0   mfrac=''
        # separate frac -right to left
        while [ $mcnt -lt $mfsize ] ;do 
            mumsk1=${r_mul%?*} mfrac=${r_mul#*$mumsk1}$mfrac r_mul=$mumsk1 mcnt=$((mcnt+1))
        done
        # depad _extra_ zeros on both sides of result
        while : ;do case $r_mul in '0'?*) r_mul=${r_mul#*?} ;; *) break ;;esac ;done
        while : ;do case $mfrac in *?'0') mfrac=${mfrac%?*} ;; *) break ;;esac ;done
        case ${r_mul:-0}'.'${mfrac:-0} in 0.0) R_msign='' ;;esac
        r_mul=${R_msign#*+}${r_mul:-0}'.'${mfrac:-0}
        R_msign=''
        shift
    done
    
    case $mprec in 
        0)  echo ${r_mul%.*} ;; off) echo $r_mul ;;
        *)  mfrac=${r_mul#*.}
            while [ ${#mfrac} -gt $mprec ] ;do mfrac=${mfrac%?*} ;done
            # remove trailing zeros ??
            # while : ; do  case $mfrac in *?0) mfrac=${mfrac%?*} ;; *) break ;;esac ;done
            echo ${r_mul%.*}'.'$mfrac ;;
    esac
    
    mfrac='' mprec='' r_mul=''
} ## mul
# mprec= r_mul= mnxt= mrsign= mnxtsign= mrint= mrfrac= mnint= mnfrac= mfsize= mfrac=
# swpint= swpfrac= swpsign= fastm= R_msign= Am= Bm= mtmp= mcnt= icol= ocol= mchnk= rounding= mpad= mumsk1=

# div - perform division '/' or modulo '%' on 2 decimal numbers
# depends on: 'cmp3w' 'tsst' 'add' 'mul'
# this a one-shot function which, unlike 'add' and 'mul', doesn't accept a series of inputs
div_help="  'div' usage: 'div [-s?] num1 (/ % m qr) num2'"
div() { scale_div=$defprec
    case $1 in -s*) scale_div=${1#*-s} ; shift ;; ''|-h) echo "$div_help" >&2 ; return 1 ;; esac
    
    # require exactly 3 inputs
    [ -z $3 ] || [ -n "$4" ] && { echo "$div_help" >&2 ; return 1 ;}
    # make sure we have only valid scale, input numbers and appropriate operators for div
    #validate_inputs_debug div $scale_div $@ || { echo "->div: Invalid input in '-s$scale_div' '$@'" >&2 ; return 1 ; }
    M=$1 oprtr=$2 D=$3
    
    case $M in '-'*) M_sign='-' M=${M#*-} ;; *) M_sign='+' M=${M#*+} ;;esac
    case $D in '-'*) D_sign='-' D=${D#*-} ;; *) D_sign='+' D=${D#*+} ;;esac
    case "${M_sign}${D_sign}" in '++'|'--') Q_sign='+' ;; '+-'|'-+') Q_sign='-' ;;esac
    case $M in .?*) M_int='' M_frac=${M#*.} ;; *.*) M_int=${M%.*} M_frac=${M#*.} ;;
        *) M_int=${M} M_frac='' ;;esac
    case $D in  .*) D_int='' D_frac=${D#*.} ;; *.*) D_int=${D%.*} D_frac=${D#*.} ;;
        *) D_int=${D} D_frac='' ;;esac
    # remove all leading zeros from integers
    while : ;do case $M_int in '0'*) M_int=${M_int#*?} ;; *) break ;;esac ;done
    while : ;do case $D_int in '0'*) D_int=${D_int#*?} ;; *) break ;;esac ;done
    # remove any trailing zeros from fractions
    while : ;do case $M_frac in *'0') M_frac=${M_frac%?*} ;; *) break ;;esac ;done
    while : ;do case $D_frac in *'0') D_frac=${D_frac%?*} ;; *) break ;;esac ;done
    # save sanitized fractions for comparison below
    sane_mfrac=${M_frac:-0}     sane_dfrac=${D_frac:-0}
    
    # if either number has an integer part eqal to zero, then we need to remove any
    # leading zeros from the fraction and calculate the offset to restore them in answer
    me=0 de=0
    case $M_int in 
        '') while : ;do case $M_frac in '0'*) M_frac=${M_frac#*?} me=$((me-1)) ;; *) break ;;esac ;done ;; 
        *) me=${#M_int} ;;
    esac
    case $D_int in 
        '') while : ;do case $D_frac in '0'*) D_frac=${D_frac#*?} de=$((de-1)) ;; *) break ;;esac ;done ;; 
        *) de=${#D_int} ;;
    esac
    # punch is the offset
    punch=$(( me - de ))
    
    # combine numbers
    mod=${M_int}$M_frac dvsr=${D_int}$D_frac
    # test early for division by zero or easy answers
    case $dvsr in '') echo "->div: Division by zero" >&2 ; return 1 ;;esac

    [ "$scale_div" = 0 ] && defzero=''
    # if mod is zero, the answer is '0'
    case $mod in '') echo 0$defzero ; return ;;esac
    
    # special cases for early exit
    case "${D_int:-0}"'.'"$sane_dfrac" in 1.0)
            # denominator is 1, so answer equals numerator
            case $oprtr in 
                '/') Q_out=${Q_sign#*+}${M_int:-0} ; [ "$scale_div" != 0 ] && Q_out=$Q_out'.'$sane_mfrac ;;
                '%'|'m') Q_out='0' ; [ "$sane_mfrac" != 0 ] && Q_out=${M_sign#*+}'0.'$sane_mfrac ;;
            esac
            echo $Q_out ; return ;;
        "${M_int:-0}"'.'"$sane_mfrac") 
            # numerator and denominator are equal, so answer equals 1
            case $oprtr in 
                '/') Q_out=${Q_sign#*+}1$defzero ;;
                '%'|'m') Q_out='0'$defzero ;;
            esac
            echo $Q_out ; return ;;
    esac
    
    # pad both numbers to equal length
    while [ ${#mod} -lt ${#dvsr} ] ;do mod=$mod'0' ;done
    while [ ${#dvsr} -lt ${#mod} ] ;do dvsr=$dvsr'0' ;done
    
    # when punch is negative, it means that the answer is going to be less than 1,
    # and we may need to front-pad the result to restore leading zeros
    case $punch in -*) tsst $mod -ge $dvsr && punch=$((punch+1)) ;;esac
    
    Q_int=0
    # if numerator is greater than denominator, then answers' integer 'Q_int' must be calculated
    if tsst ${M_int:-0}'.'$sane_mfrac -gt ${D_int:-0}'.'$sane_dfrac ; then
        qcnt=0
        while [ $qcnt -lt $punch ] ; do qcnt=$((qcnt+1))
            # if dvsr has trailing zeros, shorten it instead of making mod longer
            case $dvsr in *?0) dvsr=${dvsr%?*} ;; *) mod=$mod'0' ;;esac
        done
        
        if [ ${#mod} -lt 19 ] ; then
            Q_int=$(( $mod / $dvsr )) 
            mod=$(( $mod % $dvsr ))
        else
            # this is division by subtraction using partitioning
            while : ;do
                case $mod in ?) divpad='' ;;
                    *)  seed=$(( ${#mod} - ${#dvsr} )) qcnt=0
                        while [ $qcnt -lt $seed ] ;do divpad=$divpad'0' qcnt=$((qcnt+1)) ;done
                        case $( cmp3w ${dvsr}$divpad $mod ) in '>') divpad=${divpad%?*} ;;esac
                    ;;
                esac
                last_intrm_P=${dvsr}$divpad
                for fctr in 2 3 4 5 6 7 8 9 ;do
                    intrm_P=$( mul -s0 $fctr ${dvsr}$divpad )
                    case $( cmp3w  $intrm_P $mod ) in
                        '>') fctr=$(( $fctr - 1 )) intrm_P=$last_intrm_P ; break ;;
                        '=') break ;;esac
                    last_intrm_P=$intrm_P
                done
                tsst $mod -lt $dvsr && break
                intrm_Q=${fctr}$divpad Q_int=$( add -s0 $Q_int $intrm_Q )
                mod=$( add -s0 $mod - $intrm_P ) divpad='' fctr=''
            done
        fi
    fi
    
    # early exit if operator is %, m or qr
    case $oprtr in '%'|'m'|'qr')
        # restore magnitude and sign of remainder
        mod=$( mul -s$scale_div ${Q_sign#*+}$Q_int x ${D_sign#*+}${D_int:-0}'.'$sane_dfrac )
        mod=$( add -s$scale_div ${M_sign#*+}${M_int:-0}'.'$sane_mfrac - $mod )
        case $oprtr in 
            # if oprtr is % (remainder) return modulus
            '%') echo $mod ; return ;;
            # if oprtr is mod (divmod) return quotient and remainder
            'qr') echo ${Q_sign#*+}${Q_int:-0}${defzero} ${mod} ; return ;;
        esac
        # if signs are different, add the divisor, to yield a
        # floored modulo, like python, online-calculators, etc
        case ${M_sign}${D_sign} in 
            '+-'|'-+') mod=$( add -s$scale_div $mod + ${D_sign#*+}${D_int:-0}'.'$sane_dfrac ) ;;
        esac
        echo $mod
        return ;;
    esac
    # or if scale is zero
    case $scale_div in 0) 
        [ "$Q_int" = 0 ] && echo $Q_int || echo ${Q_sign#*+}$Q_int 
        return ;; 
    esac
    
    # calculate fraction digit-by-digit
    Q_frac=''
    case $punch in -*) qlimit=$(( ${punch} + ${scale_div} ));;
        *) qlimit=$scale_div ;;
    esac
    # for numbers <19 digits
    if [ ${#mod} -lt 18 ] && [ ${#dvsr} -lt 19 ] ;then
        while [ ${#mod} -lt 18 ] ;do
            [ "$mod" = 0 ] && break
            mod=$mod'0'
            if [ $mod -lt $dvsr ] ;then
                Q_frac=$Q_frac'0'
            else
                this_q=$(( $mod / $dvsr ))
                Q_frac=${Q_frac}$this_q
                mod=$(( $mod % $dvsr ))
            fi
            [ ${#Q_frac} -ge ${qlimit} ] && break
        done
    fi
    # there may be partial results above which get finished below
    # calculate fraction using subtraction for long numbers
    while [ ${#Q_frac} -lt $qlimit ] ;do
        [ "$mod" = 0 ] && break
        mod=$mod'0'
        if tsst $mod -lt $dvsr ;then
            Q_frac=$Q_frac'0'
        else    qcnt=0
            while : ;do
                tsst $mod -lt $dvsr && break
                mod=$( add -s0 $mod - $dvsr ) 
                qcnt=$(( qcnt + 1 ))
            done
            Q_frac=${Q_frac}$qcnt
        fi
    done
    # add leading zeros back to fraction where needed
    qcnt=0
    case $punch in -*)
        while [ $qcnt -lt ${punch#*-} ] ;do Q_frac='0'$Q_frac qcnt=$((qcnt+1)) ;done ;;
    esac
    
    # remove trailing zeros from fraction
    while : ; do  case $Q_frac in *?0) Q_frac=${Q_frac%?*} ;; *) break ;;esac ;done
    
    echo ${Q_sign#*+}$Q_int'.'${Q_frac:-0}
    Q_sign='' Q_int='' Q_frac=''
} ## div
# scale_div= M= oprtr= D= M_sign= D_sign= Q_sign= M_int= D_int= M_frac= D_frac= mod= dvsr= Q_fracsize= Q_int= Q_frac=
# qcnt= this_q= seed= divpad= last_intrm_P= fctr= intrm_P= punch= me= de= sane_mfrac= sane_dfrac= qlimit= rounding= Q=

# as the name says, do nothing. For measuring startup latency, like this: 'time iq do_nothing
do_nothing() { : ;} ## tue_nix

## is_num is used by the execution block below
# but is not used by any of the main functions above
# check if an input is really a value
is_num_help="  'is_num' usage: 'is_num number ; echo \$?'"
is_num_debug() {
    case $1 in 
        '-h') echo "$is_num_help" >&2 ; return 1 ;;
        ''|*[!+0-9.-]*) echo "-> is_num error: non-numeric characters in '$1'" >&2 ; return 1 ;;
        *'.'*'.'*|*+*+*|*-*-*) echo "-> is_num error: multiple dots or signs in '$1'" >&2 ; return 1 ;;
        *'.'|*-|*+) echo "-> is_num error: trailing dot or sign '$1'" >&2 ; return 1 ;;
        *+*-*|*-*+*) echo "-> is_num error: mixed signs in '$1'" >&2 ; return 1 ;;
        [0-9]*-*|[0-9]*+*) echo "-> is_num error: embedded signs in '$1'" >&2 ; return 1 ;;
        #*) echo "-> is_num: '$1' is a valid numeric value" >&2 ; return 0 ;;
        *) return 0 ;;
    esac
} ## is_num

validate_inputs_debug() { fun=$1 ; shift ; vscale=$1 ; shift
    case ${vscale#*-s} in  off) : ;;
        *[!0-9]*) echo "-> validate_inputs: scale is non-numeric or negative '$vscale'" >&2 ; return 1 ;; 
    esac
    raw="$*"
    while [ "$1" ] ; do
        if [ ${#1} = 1 ] ; then
            case $fun in
                add) case $1 in +|-) shift ; continue ;; esac ;; mul) case $1 in x|X) shift ; continue ;; esac ;;
                div) case $1 in '/'|'%'|'m') shift ; continue ;; esac ;; 
            esac
            case $1 in '.') echo "-> validate_inputs: single dot '$1'" >&2 ; return 1 ;;
                [xX/%m^+-]) echo "-> validate_inputs: '$1' is an invalid operator for '$fun'" >&2 ; return 1 ;;
                [xX/%m^+-]) echo "-> validate_inputs: 'or two operators in series for '$fun'" >&2 ; return 1 ;;
            esac
        fi
        case $1 in 'qr') shift ;; esac # allow this 2-char operator
        # allow only well-formed numbers
        case $1 in 
        *[!+0-9.-]*) echo "-> validate_inputs: non-numeric '$1'" >&2 ; return 1 ;; # is not only digits, dots and signs
        *'.'*'.'*|*+*+*|*-*-*) echo "-> validate_inputs: multiple dots or signs in '$1'" >&2 ; return 1 ;; # multiple dots
        *'.'|*-|*+) echo "-> validate_inputs: trailing dot or sign in '$1'" >&2 ; return 1 ;; # traili"$fun" $optsng dot
        *+*-*|*-*+*) echo "-> validate_inputs: mixed signs in '$1'" >&2 ; return 1 ;; # multiple signs, mixed signs
        [0-9]*-*|[0-9]*+*) echo "-> validate_inputs: embedded signs in '$1'" >&2 ; return 1 ;; # signs embedded in digits
        esac
        shift
    done
    # last argument to functions can't be an operator
    case $fun in
        add) case $raw in *+|*-) echo "-> validate_inputs: trailing operator for '$fun'" >&2 ; return 1 ;; esac ;; 
        mul) case $raw in *x|*X) echo "-> validate_inputs: trailing operator for '$fun'" >&2 ; return 1 ;; esac ;;
        div) case $raw in *'/'|*'%'|*'m'|*'qr') echo "-> validate_inputs: trailing operator for '$fun'" >&2 ; return 1 ;; esac ;; 
    esac
}

# defaults for execution environment
src=${src:-0} # don't change this

## math.h.sh for the shell language is the raw mathematics functions from the 'iq' calculator
# iq is mainly designed to replace external calculators in other shell scripts
# To use math.h.sh in your shell scripts, put the same line near the top of your script.
# '. ./math.h.sh' or '. math.h.sh' if this file is in your PATH somewhere

# Using the math functions:
# Everything must be space-separated
# The basic form  is: function-name scale number1 operator number2
# 'scale' is optional with all the math functions. If used,
# it should be the first input after the function name.

# Addition
# example: 'add -s3 23.452 + -1.074 - 2.7182'
# The operators +- are not required, but recommended when scripting

# Multiplication
# example: 'mul -s2 3.14592 x 1.618 x 2.7182'

# For both Addition and Multiplication:
# If scale is left out, no truncation of the result is done.
# When processing a series of numbers, with scaling requested, 
# truncation is only done after the last calculation.

# Division
# example: 'div -s9 3.14592 / 2.7182'
# modulo example: 'div -s6 16758.85427391378 % 13'
# The 'div' function always requires an operator '/' or '%'
# If scale is left out, the default value of "$defprec" will be used.

# Numeric Comparison
# The 'tsst' function works like the shell buitin 'test'
# for comparing two decimal values, and uses the same syntax as 'test'.
# example: 'tsst 1236.87834 -lt 13114'
# As with 'test', 'tsst' returns an exit status on stderr, so it can
# be used within if/then, while/do, '&&', or '||' condtional constructions.

# 'cmp3w' is the backend to 'tsst' and performs the raw comparison.
# It returns, on 'stdout', either '<', '=' or '>' to indicate the
# relationship of the two numbers being compared.
# example: 'cmp3w -14.787 -18.46' returns '>'

# 'is_num' tests whether an input is a valid number for calculation.
# It returns an exit status 0 or 1 on stderr, where 0=valid 1=invalid

# For more detailed information, most functions have useful notes and comments in the 
# function header. Each functions' dependencies are also listed above each function.

# These functions are tested under all common shells, 
# listed below by order of best performance:
# ksh dash busybox-ash bash zsh posh yash
# Compared to bash, math.h.sh is ~2.5X faster on dash and ~6X faster on ksh.

# math.h.sh expects well-formed valid inputs
# most error-handling is left to the shell and GIGO rules apply
# Here are some example error messages from the shell itself, usually caused by
# improper inputs, like non-numeric characters or missing inputs (empty variables?)
# iq: line ?: ? : arithmetic syntax error   #cause--> non-numeric characters in input -do you have a cat?
# iq: 82: [: Illegal number: +11/bin/ls00 # cause--> by now cat is furiously trying to get root
# iq: 142: arithmetic expression: expecting EOF: "1login0+1000050+0" # cause--> cat tries again... time for a nap

# uncommenting the next 2 lines makes this file a runnable program
#cmd=$1 ; shift
#$cmd "$@"
