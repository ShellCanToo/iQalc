#!/bin/sh

# 'iq_misc.sh' is a Module of the iQalc/IQ precision calculator
# It is not an executable program

# Copyright Gilbert Ashley 18 December 2023
# Contact: perceptronic@proton.me  Subject-line: iQalc

# iq_misc version=1.82

# new function - invert supports e-notation and SigScale
# new function - shift10 performs multiply/divide by shifting decimal
# spow - removed

# shellcheck disable=SC2034,SC2086,SC2004,SC2154,SC2068,SC2046

# List of functions included here:
iqmisc="factorial gcf dec2ratio invert pmod_eucl div_floor dot_1d mat2 shift10 "

### Miscellaneous functions currently unused elsewhere

# factorial - returns the factorial of an integer input
# depends on: 'mul'
# Example usage: 'factorial 5' returns: '120'
factorial(){ case $1 in -s*) shift ;;esac   # scale is unused and ignored
    case $1 in '') echo "-->factorial: Requires 1 integer input" >&2 ; return 1 ;;
        *.*) echo "-->factorial: Only integer inputs are allowed." >&2 ; return 1 ;;
    esac
    fact_out=$1 fact=$((fact_out-1))
    while [ $fact -gt 1 ] ;do fact_out=$( mul -s0 $fact_out x $fact ) fact=$((fact-1)) ;done
    echo $fact_out
} ## factorial  # fact_out= fact=

# gcf - find the Greatest Common Factor of two integer numbers
# depends on: 'div'
# re-write using 'qr' (divmod) option to div
gcf() {  case $1 in -s*) shift ;;esac   # scale is unused and ignored
    case $2 in '') echo "-->gcf: Requires 2 integer inputs" >&2 ; return 1 ;;esac
    case $1"$2" in *.*) echo "-->gcf: Only integer inputs allowed" >&2 ; return 1 ;;esac
    gcf_n1=$1 gcf_n2=$2
    while [ $gcf_n2 -ne 0 ] ; do
        mod=$( div -s0 $gcf_n1 m $gcf_n2 )
        gcf_n1=$gcf_n2
        gcf_n2=${mod#*' '}
    done
    echo $gcf_n1
} ## gcf2  # gcf_n1= gcf_n2= mod=

# dec2ratio - convert a decimal fraction to a whole-number ratio
# depends on: 'div'
dec2ratio() { case $1 in -s*) shift ;;esac   # scale is unused and ignored
    case $1 in .?*|0.?*) Nom=${1#*.} ;;
        ''|'-h') echo "-->dec2ratio: Requires a decimal fraction input: .12781 or 0.1388" >&2 ; return 1 ;;
        *) echo "-->dec2ratio: Only fractions allowed" >&2 ; return 1 ;; 
    esac
    # strip any trailing zeros from the fraction
    while : ;do case $Nom in *'0') Nom=${Nom%?*} ;; *) break ;;esac ;done
    # if now null, it was all zeros
    case $Nom in '') echo "0" ; return ;; esac
    # pad up the denom to one extra digit
    Denom_size=$(( ${#Nom} + 1 ))  Denom=1
    while [ ${#Denom} -lt $Denom_size ] ; do Denom=$Denom'0' ;done
    # strip any leading zeros in the frac
    while : ;do case $Nom in '0'*) Nom=${Nom#*?} ;; *) break ;;esac ;done
    # if number is non-divisible by 5 4 or 2, return fast
    case $Nom in *1|*3|*7|*9) echo $Nom/$Denom ; return ;; esac
    
    cnt=0 runs=$(( (Denom_size/3) + 1 ))
    if [ $Denom_size -lt 19 ] ;then
        while [ $cnt -lt $runs ] ;do
            cnt=$((cnt+1))
            for sim_try in 25 16 8 5 4 2 ;do
                if [ $(( $Nom % $sim_try )) -eq 0 ] && [  $(( $Denom % $sim_try )) -eq 0 ] ;then
                    Nom=$(( $Nom / $sim_try )) ; Denom=$(( $Denom / $sim_try ))
                fi
                [  $Nom -eq 1 ] && break 2 
            done
            [ ${#Denom} -eq $Denom_size ] && break 1
            Denom_size=${#Denom}
        done
    else
        while [ $cnt -lt $runs ] ; do
            cnt=$((cnt+1))
            for sim_try in 25 16 8 5 4 2  ;do
                N_test_sf=$( div $Nom % $sim_try)
                D_test_sf=$( div $Denom % $sim_try )
                if [ "$N_test_sf" = '0' ] && [ "$D_test_sf" = '0' ] ;then
                    Nom=$( div -s0 $Nom / $sim_try ) Denom=$( div -s0 $Denom / $sim_try )
                fi
                [  "$Nom" = 1 ] && break 2
            done
            [ ${#Denom} -eq $Denom_size ] && break 1
            Denom_size=${#Denom}
        done
    fi
    echo $Nom/$Denom
} ## dec2ratio
# Nom= Denom= Denom_size= cnt= runs= sim_try= N_test_sf= D_test_sf=
### End Miscellaneous functions

# bn_scale= base_bnp= exp_bnp= bnp_neg= out_bnp=
# invert - returns the inversion of a number (1/X)
# depends on: 'div' 'tsst'
invert_help() {
echo "   'invert' usage: 'invert [-s?,-S?,-e?] Number'
    
    Returns the inversion (1/X) of any number. Number
    can be positive or negative, expressed as an integer,
    decimal or in Exponential Notation.
    
    'invert' returns answers in normally scaled outputs or in
    Significant Digits using the scaling options: -s? or -S?
    Example: 'invert -s1 -.99999995' = -1.0
    Example: 'invert -S1 -.99999995' = -1.00000005
    Example: 'invert -s8 12.99999999' = 0.07692307
    Example: 'invert -S8 12.99999999' = 0.076923076
    
    Inputs in Exponential Notation are automatically detected
    and answers are returned in Exponential Notation:
    Example: 'invert -S8 1.2e10' = 8.33333333e-11
    Example: 'invert -S8 1.2e-10' = 8.33333333e9
    (works with any of the scaling types -s? -S? or -e?)
    "
}
invert() { invprec=$defprec   SigScale=0 E_note=0 invneg=''
    case $1 in -s*) invprec=${1#*-s} ; shift ;; -S*) invprec=${1#*-S}  SigScale=1 ; shift ;;
        -e*) invprec=${1#*-e} ; shift ;; ''|-h) invert_help >&2 ; return 1 ;;
    esac
    case $1 in -*) invneg='-' num=${1#*-} ;; *) num=$1 ;;esac
    case $num in 
        [1-9].?*e-?*) E=${num#*e-}
            inv=$( div -s$invprec 10 / $invneg${num%e*} )
            echo ${inv}'e'$((E-1)) ;;
        [1-9].?*e?*) E=${num#*e}
            inv=$( div -s$invprec 10 / $invneg${num%e*} )
            echo ${inv}'e-'$((E+1)) ;;
        *e*) echo "->invert: Invalid Exponential Notation in '$1'" ; return 1 ;; 
        0.?*|.?*) 
            if [ 1 = "$SigScale" ] ; then
                frac=${num#*.} # fractions smaller than .4762 coule be ignored
                if [ ${#frac} -ge $invprec ] ; then
                    # raise precision by adding the fraction size
                    res=$( div -s$((invprec+${#frac})) 1 / $invneg${num} )
                    # parse fractionional part left-to-right
                    stub=${res#*.} out=''
                    # add any leading zeros to the fraction output
                    while : ; do 
                        case $stub in 
                            0*) mask=${stub#*?} out=${out}${stub%"${mask}"*} stub=$mask ;; 
                            *) break ;; 
                        esac
                    done
                    scayle=0
                    # add digits to output until SigScale is reached
                    while [ $scayle -lt $invprec ] ; do
                        scayle=$((scayle+1)) mask=${stub#*?}
                        out=${out}${stub%"${mask}"*} stub=$mask
                    done
                    echo ${res%.*}'.'$out
                else
                    div -s$invprec 1 / $invneg${num}
                fi
            else
                div -s$invprec 1 / $invneg${num}
            fi
        ;;
        *)  if [ 1 = "$SigScale" ] ; then
                tsst $num -gt 10 && { int=${num%.*} invprec=$(( $invprec + ${#int} - 1 )) ;}
            fi
            div -s$invprec 1 / $invneg$num ;;
    esac

} ##invert

# positive Euclidian Modulo
# from: https://stackoverflow.com/questions/14997165/fastest-way-to-get-a-positive-modulo-in-c-c
#int modulo_Euclidean2(int a, int b) {
#  if (b == 0) TBD_Code(); // Perhaps return -1 to indicate failure?
#  if (b == -1) return 0; // This test needed to prevent UB of `INT_MIN % -1`.
#  int m = a % b;
#  if (m < 0) {
#    // m += (b < 0) ? -b : b; // Avoid this form: it is UB when b == INT_MIN
#    m = (b < 0) ? m - b : m + b;
#  }
#  return m;
#}
# positive Euclidian Modulo
pmod_eucl() { case $1 in -s*) pmscale=${1#*-s} ; shift ;; *) pmscale=0 ;; esac
    a=$1 b=$2
    case $b in 0|0.0) echo "->pmod_eucl: Division by Zero" >&2 ; return 1 ;; 
        -1|-1.0) echo 0 ; return ;; 
    esac
    m=$(div -s$pmscale $a % $b)
    case $m in -*)
            case $b in -*) m=$( add -s$pmscale $m - $b ) ;;
                *) m=$( add -s$pmscale $m + $b )
            esac ;;
    esac
    echo $m
}


# floored division
div_floor () { 
    case $1 in -s*) dfscale=${1#*-s} ; shift ;; *) dfscale=0 ;; esac
    a=$1 
    case $2 in '/'|'//') shift ;; esac
    b=$2
    case $b in 0|0.0) echo "->div_floor: Division by Zero" >&2 ; return 1 ;; 
        -1|-1.0) echo 0 ; return ;; 
    esac
    divmod="$( div -s$dfscale $a qr $b )"
    q=${divmod%' '*} r=${divmod#*' '}
    rsig=$(cmp3w $r 0) bsig=$(cmp3w $b 0)
    # combine signals to form patterns for case
    # no '>>' '<<'  # yes '=>' '=<' '<>' '><'
    case ${rsig}${bsig} in 
        '>>'|'<<') : ;;
        *)  q=$( add -s$dfscale $q - 1 )
            r=$( add -s$dfscale $r + $b ) ;;
    esac
    #echo $q $r
    echo $q
}

# dot - multiplies 2 series of numbers by each other, 
# and sums the products. An additional value can be
# included in the sum. So this can be used for SOP,
# fused-multiply-add and 1D matrix multiplication
# or one-dimensional dot product
# SOP: dot -s3 2 3 0.12 0.7 0.5 0.4 = 2.948
# fused-multiply-add: dot_1d -s3 -a0.3 2 3 0.12 0.7 0.5 0.4 = 3.248
dot_1d() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;;esac
    case $1 in -a*) addend=${1#-a*} ; shift ;; *) addend=0 ;;esac
    # split inputs in two halves
    split=0
    # count the entries
    for it in $@ ; do split=$((split+1)) ;done
    [ $((split%2)) = "0" ] || { echo "-> dot_1d: Number of multiplicands must be even." >&2 ; return 1 ;}
    split=$((split/2))
    
    # shift through the first half of inputs, and
    # assign them to a single variable
    cnt=0 col=''
    while [ $cnt -lt $split ] ; do
        col="${col}${1} "
        cnt=$((cnt+1)) ; shift
    done
    # expand the variable to a list of elements,
    # multiplying each times the next member of $@
    sum=0
    for item in $col ; do
        # fused-multiply-add disallows truncating products
        sum=$( add -soff $sum + $(mul -soff $item x $1) )
        shift
    done
    # final
    add -s$scale $sum $addend
}
#dot_1d $@
#dot_1d -s6 -b3 2 2

# 1D-to-2D matrix multiplication
# feedforward cross-multiplier - creates a Sum of Products
# for each node on the right-side (forward) layer of an NN
# the dimensions of each layer must be specified
# if a bias is specified it is added to the SOP of each column
mat2() { scale=$defprec 
    out=''
    while [ "$1" ] ; do
        case $1 in 
            -s*) scale=${1#-s*} ; shift ;;
            -l*) inputlen1=${1#-l*} ; shift ;;
            -r*) inputlen2=${1#-r*} ; shift ;;
            -b*) bias=${1#-b*} ; shift ;;
            *) break ;;
        esac
    done
    
    bias=${bias:-0}
    cnt=0 ; col1=''
    while [ $cnt -lt $inputlen1 ] ; do
        col1="${col1}${1} " ; cnt=$((cnt+1)) 
        shift
    done
    while [ "$1" ] ; do
        sum=$bias
        for l in $col1 ; do
            prod=$( mul -s$scale $l x $1 )
            sum=$( add $sum $prod)
            shift
        done
        out="${out}${sum} "
    done
    echo $out
} ## mat2
# mat2 -l3 -r2 2 3 0.12 0.7 0.5 0.4 0.3 0.2 0.1
#mat2 -s6 -l3 -r2  0.05 0.1 0.01 .052 .205 .091 .106 .277 .183
# outputs a space separated array of each sum

# shift10 - perform multiplication by 10's shifting the decimal place
shift10() { s=$1 n=$2
    case $n in *.*) nint=${n%.*} nfrac=${n#*.} ;; *) nint=$n nfrac='' ;; esac
    bite=''
    case $s in 
    -*) while [ ${#bite} -lt ${s#*-} ] ; do
            mask=${nint%?*}  char=${nint#*"${mask}"}
            bite=${char:-0}${bite}  nint=$mask
        done
        echo ${nint:-0}'.'${bite}${nfrac} ;;
    *)  while [ ${#bite} -lt $s ] ; do
            mask=${nfrac#?*}  char=${nfrac%"${mask}"*}
            bite=${bite}${char:-0}  nfrac=$mask
        done
        echo ${nint}${bite}'.'${nfrac:-0} ;;
    esac
} ## shift10
# shift10 4 1.2345  returns: 1245.0
# shift10 -2 1.2345  returns 0.012345
