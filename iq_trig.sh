  #!/bin/sh

# This file is part of the IQ4sh precision calculator

# Copyright Gilbert Ashley 8 June 2023
# Contact: OldGringo9876@gmx.de  Subject-line: IQ4sh

# iq_trig_version=1.79

# trig functions moved here from iq+
# sin cos tan - fixed wrong outputs for some fringe cases
# renamed rdns2dgrs/dgrs2rdns as rad2deg/deg2rad
# new functions - 'atan' and 'atan2' calculate arctangents in degrees/radians
# new function - is_near_int determines if input is close to being an integer

# List of functions included here:
# Main functions: sin cos tan atan atan2 rad2deg deg2rad

iqtrig="sin cos tan atan atan2 rad2deg deg2rad "

### Trigonometry functions

trig_help() {
:
}

# sin - Calculate the Sine of an angle
# depends on: 'sin14' 'cos14' 'deg2rad' 'is_near_int' 'tsst' 'add'
# used by 'tan'
sin_help() {
echo "    'sin' usage: 'sin [-s?] [-rad -irad] angle'
    
    Returns the Sine of an 'angle', which
    can be in degrees (default) or in radians 
    Use the '-rad' or '-irad' option to input radians
    Accuracy: approximately 12 decimal places
    Example usage: 'sin -s6 91.35' = 0.999722
    Example usage: 'sin -s12 23.565' = 0.399789183758
    Example usage: 'sin -s12 -rad 0.411286838232' = 0.399789183757
    "
}
sin(){ out_scale=$defprec inrad=0 outrad=0
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; ''|'-h') sin_help >&2 ; return ;; esac 
    # process other arguments
    case $1 in -rad|-irad) irad=1 ; shift ;;esac
    # raise intermediate scale to retain accuracy
    scale_sin=$((out_scale+2))
    # get the input
    x_sin=$1
    # remove input sign and save
    case $x_sin in '-'*) sin_neg='-' x_sin=${x_sin#*-} ;; 
        '+'*) sin_neg='' x_sin=${x_sin#*+} ;; 
    esac
    # convert input from radians, if chosen
    if [ 1 = "$irad" ] ; then
        x_sin=$( rad2deg -s$scale_sin  $x_sin )
    fi
    # reduce large x to <=360
    while tsst $x_sin -gt 360 ; do
        x_sin=$( add $x_sin - 360 )
    done
    # early exit for special cases
    case $x_sin in 
        0|0.0) echo '0.0' ; return ;;
        30|30.0) echo ${sin_neg}'0.5' ; return ;;
        30.0*|29.9*) is_near_int -s$out_scale $x_sin && { echo ${sin_neg}'0.5' ; return; } ;;
        330|330.0) [ '-' = "$sin_neg" ] && echo '0.5' || echo '-.5' ; return  ;;
        330.0*|329.9*) is_near_int -s$out_scale $x_sin && 
                           { [ '-' = "$sin_neg" ] && echo '0.5' || echo '-.5' ; return ; } ;;
        90|90.0) echo ${sin_neg}'1.0' ; return ;;
        90.0*|89.9*) is_near_int -s$out_scale $x_sin && { echo ${sin_neg}'0.5' ; return; } ;;
        270|270.0) [ '-' = "$sin_neg" ] && echo '1.0' || echo '-1.0' ; return ;;
        270.0*|269.9*) is_near_int -s$out_scale $x_sin &&
                    { [ '-' = "$sin_neg" ] && echo '1.0' || echo '-1.0' ; return ; } ;;
        180|180.0|360|360.0) echo '0.0' ; return ;;
        180.0*|179.9*|360.0*|359.9*|0.0*) is_near_int -s$out_scale $x_sin && { echo '0.0' ; return; } ;;
    esac
    # determine final output sign
    if tsst $x_sin -gt 180 ; then
        [ '-' = "$sin_neg" ] && sin_neg='' || sin_neg='-'
    fi
    # reduce x from any quadrant to <90
    if tsst $x_sin -gt 270 ; then
        x_sin=$( add 360 - $x_sin )
    elif tsst $x_sin -gt 180 ; then
        x_sin=$( add $x_sin - 180 )
    elif tsst $x_sin -gt 90 ; then
        x_sin=$( add 180 - $x_sin )
    fi
    # fit input to fit best range of sin14/cos14 
    if tsst $x_sin -gt 35 ; then
        x_sin=$( add 90 - $x_sin )
        x_sin=$( deg2rad -s$scale_sin $x_sin )
        out_sin=$( cos14 -s$out_scale $x_sin )
    else
        x_sin=$( deg2rad -s$scale_sin $x_sin )
        out_sin=$( sin14 -s$out_scale $x_sin )
    fi
    # add the final sign
    echo ${sin_neg}$out_sin
    
} ## sin4
## out_scale= scale_sin= x_sin= sin_neg= irad=

# cos - Calculate the Cosine of an angle
# depends on: 'cos14' 'sin14' 'deg2rad' 'is_near_int' 'add' 'tsst'
# used by: 'tan'
cos_help() {
echo "    'cos' usage: 'cos [-s?] [-rad -irad] angle'
    
    Returns the Cosine of an 'angle', which
    can be in degrees (default) or radians
    Use the '-rad' or '-irad' option to input radians
    Accuracy: approximately 12 decimal places
    Example usage: 'cos -s6 28.573' = 0.878208
    Example usage: 'cos -s12 98.827' = -0.153451510933
    Example usage: 'cos -s8 -rad 0.7417649320' = 0.01286791
    "
}
cos(){ out_scale=$defprec irad=0
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; ''|'-h') cos_help >&2 ; return ;;esac
    # process other input options
    case $1 in -rad|-irad) irad=1 ; shift ;;esac
    # raise intermediate scale to retain accuracy
    scale_cos=$((out_scale+2))
    # get the input
    x_cos=$1
    # remove input sign - output sign determined below
    case $x_cos in '-'*) x_cos=${x_cos#*-} ;; 
        '+'*) x_cos=${x_cos#*+} ;; 
    esac
    # convert input from radians, if chosen
    if [ '1' = "$irad" ] ; then
        x_cos=$( rad2deg -s$scale_cos  $x_cos )
    fi
    # reduce large x to <=360
    while tsst $x_cos -gt 360 ; do
        x_cos=$( add $x_cos - 360 )
    done
    # early exit for special cases
    case $x_cos in
            60|60.0|300|300.0) echo '0.5' ; return ;;
            60.0*|59.9*|300.0*|299.9*) is_near_int -s$out_scale $x_cos && { echo '0.5' ; return; } ;;
            120|120.0|240|240.0) echo '-0.5' ; return ;;
            120.0*|119.9*|240.0*|239.9*) is_near_int -s$out_scale $x_cos && { echo '-0.5' ; return; } ;; 
            0|0.0|90|90.0|270|270.0) echo '0.0' ; return ;;
            0.0*|90.0*|89.9*|270.0*|269.9*) is_near_int -s$out_scale $x_cos && { echo '0.0' ; return; } ;;
            180|180.0) echo '-1.0' ; return ;;
            180.0*|179.*) is_near_int -s$out_scale $x_cos && { echo '-1.0' ; return; } ;;
            360|360.0) echo '1.0' ; return ;;
            360.0*|359.9*) is_near_int -s$out_scale $x_cos && { echo '1.0' ; return; } ;;
    esac
    # determine sign and reduce x to < 90
    if tsst $x_cos -gt 270 ; then
        x_cos=$( add 360 - $x_cos )
        cos_neg=
    elif tsst $x_cos -gt 180 ; then
        x_cos=$( add $x_cos - 180 )
        cos_neg='-'
    elif tsst $x_cos -gt 90 ; then
        x_cos=$( add 180 - $x_cos )
        cos_neg='-'
    else
        cos_neg=
    fi
    # fit input to fit best range of cos14/sin14
    if tsst $x_cos -gt 55 ; then
        x_cos=$( add 90 - $x_cos )
        x_cos=$( deg2rad -s$scale_cos $x_cos )
        out_cos=$( sin14 -s$out_scale $x_cos )
    else
        x_cos=$( deg2rad -s$scale_cos $x_cos )
        out_cos=$( cos14 -s$out_scale $x_cos )
    fi
    # add the final sign
    echo ${cos_neg}$out_cos
} ## cos4
## out_scale= scale_cos= x_cos= cos_neg= irad= out_cos=

# tan - Calcualate the tangent of an angle
# depends on: 'sin' 'cos' 'is_near_int' 'rad2deg' 'div' 'tsst' 'add'
tan_help() {
echo "    'tan' usage: 'tan [-s?] [-rad -irad] angle'
    
    Returns the Tangent of an 'angle', which
    can be in degress (default) or radians
    Use the '-rad' or '-irad' option to input radians
    Accuracy: ~12 decimal places
    Example usage: 'tan -s6 28.573' = 0.544606
    Example usage: 'tan -s6 0.741764' = 0.012946
    Example usage: 'tan -s6 -rad 0.74176' = 0.015992
    "
}
tan() { out_scale=$defprec inrad=0
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; ''|'-h') tan_help >&2 ; return ;; esac
    # process other input options
    case $1 in -rad|-irad) inrad=1 ; shift ;;esac
    # raise intermediate scale to retain accuracyfile:///home/amigo/Downloads/fp_bash/iq4sh/trig-archive/atan-002.sh
    scale_tan=$((out_scale+2))
    # get the input
    x_tan=$1
    # remove and save sign of input
    case $x_tan in '-'*) tan_neg='-' x_tan=${x_tan#*-} ;; 
        '+'*) tan_neg='' x_tan=${x_tan#*+} ;; 
        *) tan_neg='' ;; 
    esac
    # convert input from radians, if chosen
    # using 'inrad' here because sin/cos use 'irad'
    if [ '1' = "$inrad" ] ; then
        x_tan=$( rad2deg -s$scale_tan $x_tan )
    fi
    # reduce large x to 360 or less
    while tsst $x_tan -gt 360 ; do
        x_tan=$( add $x_tan - 360 )
    done
    # early exit for special cases
    case $x_tan in 
        90|90.0|270|270.0) echo "-->tan: NaN" >&2 ; return 1 ;;
        90.0*|89.9*|270.0*|269.9*) is_near_int -s$out_scale $x_tan && { echo "-->tan: NaN" >&2 ; return 1 ; } ;;
        0|0.0|180|180.0|360|360.0) echo '0.0' ; return ;;
        0.0*|180.0*|179.9*|360.0*|359.9*) is_near_int -s$out_scale $x_tan && { echo '0.0' ; return; } ;;
    esac
    # determine sign of output
    if tsst $x_tan -gt 270 ; then
        [ '-' = "$tan_neg" ] && tan_neg='' || tan_neg='-'
    elif tsst $x_tan -gt 180 ; then
        :
    elif tsst $x_tan -gt 90 ; then
        [ '-' = "$tan_neg" ] && tan_neg='' || tan_neg='-'
    fi
    # get the sine and cosine
    si=$( sin -s$scale_tan $x_tan )
    co=$( cos -s$scale_tan $x_tan )
    # calculate the tangent
    out_tan=$( div -s$out_scale $si / $co )
    # add the final sign
    echo ${tan_neg}${out_tan#*-}
} ## tan2
## out_scale= scale_tan= x_tan= tan_neg= si= co= inrad= out_tan=


## atan - arctan reverts a tangent to an angle
# depends on: 'rad2deg' 'is_near_int' 'add' 'mul' 'div' 'tsst'
# used by: 'atan2'
# pade[3/4] approximation of atan in degrees from
# Pade_approximants_for_inverse_trigonometric_functi.pdf
atan_help() {
echo "    'atan' usage: 'atan [-s?] [-rad -orad] tangent'
    
    Returns the Arctangent or inverse of a Tangent
    By default, outputs are in degrees
    Use the '-rad' or '-orad' option to output radians
    Accuracy: ~12 decimal places (more in very small x)
    Example usage: 'atan -s6 0.544606' = 28.572976
    Example usage: 'atan -s6 0.012946' = 0.741709
    Example usage: 'atan -s6 -rad 0.015992' = 0.741733
    "
}
atan() { out_scale=$defprec orad=0 reduc1=0 reduc2=0
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; ''|'-h') atan_help >&2 ; return ;; esac
    # process other input options
    case $1 in -rad|-orad) orad=1 ; shift ;;esac
    # raise intermediate scale to retain accuracy
    scale_tan=$((out_scale+4))
    # pre-calculated values for pi/2, pi/4
    half_pi=1.57079632679489661923 #1321691639
    quarter_pi=0.78539816339744830961 #5660845819
    # get the input
    ax=$1
    # remove and store negative signs
    case $ax in '-'*) atan_neg='-' ax=${ax#*-} ;; 
        '+'*) atan_neg='' ax=${ax#*+} ;; 
        *) atan_neg='' ;; 
    esac
    # special cases for x=0
    case $ax in 0|0.0) echo '0.0' ; return ;;
        0.0*) is_near_int -s$out_scale $ax && { echo '0.0' ; return; } ;;
    esac
    # and for x=1
    if tsst $ax -eq 1 ; then
        [ 1 = "$orad" ] && out_atan2=$quarter_pi || out_atan2=45.0
        add -s$out_scale ${atan_neg}$out_atan2
        return
    elif tsst $ax -gt 1 ; then
        # if x>1 reduce
        reduc1=1
        ax=$( div -s$scale_tan 1 / $ax )
    fi
    # atan is not simple to accurately approximate
    # the fast Pade approximation below only has decent precision
    # for very small input values under ~0.1, so we reduce everything 
    # into the range below 0.05, and add pre-calculated values using
    # this identity: arctan (x) = arctan(c) + arctan((x - c) / (1 + x*c))
    case $ax in
        0.9[56789]*) c=.9499999999 ; AA=0.759762754823298411 reduc2=1 ;;
        0.9*) c=.8999999999 ; AA=0.732815101731257973 reduc2=1 ;;
        0.8[56789]*) c=.8499999999 ; AA=0.704494064184162564 reduc2=1 ;;
        0.8*) c=.7999999999 ; AA=0.674740942162577054 reduc2=1 ;;
        0.7[56789]*) c=.7499999999 ; AA=0.643501108729284387 reduc2=1 ;;
        0.7*) c=.6999999999 ; AA=0.610725964322094523 reduc2=1 ;;
        0.6[56789]*) c=.6499999999 ; AA=0.576375220520884911 reduc2=1 ;;
        0.6*) c=.5999999999 ; AA=0.540419500197054744 reduc2=1 ;;
        0.5[56789]*) c=.5499999999 ; AA=0.502843210851085396 reduc2=1 ;;
        0.5*) c=.4999999999 ; AA=0.463647608920806116 reduc2=1 ;;
        0.4[56789]*) c=.4499999999 ; AA=0.42285392604978063 reduc2=1 ;;
        0.4*) c=.3999999999 ; AA=0.38050637702615799 reduc2=1 ;;
        0.3[56789]*) c=.3499999999 ; AA=0.336674819297640322 reduc2=1 ;;
        0.3*) c=.2999999999 ; AA=0.291456794386123973 reduc2=1 ;;
        0.2[56789]*) c=.2499999999 ; AA=0.244978663032746507 reduc2=1 ;;
        0.2*) c=.1999999999 ; AA=0.197395559753726912 reduc2=1 ;;
        0.1[56789]*) c=.1499999999 ; AA=0.148889947511697739 reduc2=1 ;;
        0.1*) c=.0999999999 ; AA=0.0996686523921521264 reduc2=1 ;;
        0.0[56789]*) c=.0499999999 ; AA=0.049983956221921379 reduc2=1 ;;
        # reductions below 0.05 give worse results
        #0.0*) c=.0099999999 ; AA=0.009999666586675237 reduc2=1 ;;
        # inputs below 0.001 yield accuracy to ~20 places without help
        *) : ;;
    esac
    # squash x to under 0.05
    case $reduc2 in 1)
        # arctan (x) = arctan(c) + arctan((x - c) / (1 + x*c))
        #                   A        F       B    E    D  C 
        BB=$( add $ax - $c )
        CC=$( mul -s$scale_tan $ax x $c)
        DD=$( add -s$scale_tan 1 + $CC )
        ax=$( div -s$scale_tan $BB / $DD )
    esac
    # Pade approximation of atan ops: 7Xmul 2Xadd 1Xdiv
    # arctan [3/4] (x) = (55x^3+105x)/ (9x^4+90x^2+105)
    ax2=$( mul -s$scale_tan $ax x $ax)
    ax3=$( mul -s$scale_tan $ax2 x $ax )
    ax4=$( mul -s$scale_tan $ax2 x $ax2 )
    # nom
    A=$( mul -s$scale_tan 55 x $ax3 )
    B=$( mul -s$scale_tan 105 x $ax )
    C=$( add -s$scale_tan $A + $B )
    # denom
    D=$( mul -s$scale_tan 9 x $ax4 )
    E=$( mul -s$scale_tan 90 x $ax2 )
    F=$( add -s$scale_tan $D + $E + 105 )
    # result in radians
    rdns_out=$( div -s$scale_tan $C / $F )
    # end pade4
    # expand second reduction, if used
    case $reduc2 in 1)
        rdns_out=$( add -s$scale_tan $rdns_out + $AA ) ;;
    esac
    # expand first reduction, if used
    case $reduc1 in 1)
        rdns_out=$( add -s$scale_tan $half_pi - $rdns_out )
    esac
    # preserve as radians if requested
    if [ 1 = "$orad" ] ; then
        out_atan=$( add -s$out_scale  $rdns_out )
    else
        out_atan=$( rad2deg -s$out_scale $rdns_out )
    fi
    # add the sign
    echo ${atan_neg}${out_atan#*-}
} ## atan
## out_scale= orad= reduc1= reduc2= scale_tan= 
# half_pi= quarter_pi= ax= atan_neg= ax2= ax3= ax4=
## AA= BB= CC= DD= A= B= C= D= E= F= rdns_out= out_atan=

# atan2 -  2-input-coordinate atan returns arctangent from any quadrant
# depends on: 'atan' 'deg2rad' 'add' 'div' 'tsst'
atan2_help() {
echo "    'atan2' usage: 'atan2 [-s?] [-rad -orad] [-yx] X Y'
    
    Returns the Arctangent of a 2-coordinate position
    'X' and 'Y' are planar (Cartesian) coordinates
    By default, outputs are in degrees
    Use the '-rad' or '-orad' option to output radians
    To change input order to Y X,  use the '-yx' option
    Accuracy: ~10 decimal places
    Example usage: 'atan2 -s10 3.722 3.425' = 42.6203916006
    Example usage: 'atan2 -s10 20.435 30.152' = 55.8732180030
    Example usage: 'atan2 -s10 -orad 20.435 30.152' = 0.9751716178
    Example usage: 'atan2 -s10 -rad -yx 30.152 20.435' = 0.9751716178
    "
}
atan2() { out_scale=$defprec orad=0 use_yx=0
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; ''|'-h') atan2_help >&2 ; return ;;esac
    # process other arguments
    while [ $1 ] ; do
        case $1 in -rad|-orad) orad=1 ; shift ;; -yx) use_yx=1 ; shift ;; *) break ;;esac
    done
    case $2 in '') echo "-->atan2: 2 input coordinates X and Y required" >&2 ; return 1 ;;esac
    # raise intermediate scale to retain accuracy
    atan2_scale=$((out_scale+2))
    # get the 2 coordinates -whether 'x/y' or 'y/x'
    case "$use_yx" in 1) ay=$1 ax=$2 ;; *) ax=$1 ay=$2 ;;esac
    # Early exit for special cases
    if tsst $ax -eq 0 ; then
        # x=0
        if tsst $ay -eq 0 ; then
            # y=0
            echo "-->atan2: NaN" >&2 ; return 1
        elif tsst $ay -lt 0 ; then
            # y<0
            out_atan2='-'90.0
        else
            # y>0
            out_atan2=90.0
        fi
    elif tsst $ax -gt 0 ; then
        # x>0 is positive so result is normal atan(y/x)
        az=$( div -s$atan2_scale $ay / $ax )
        out_atan2=$( atan -s$atan2_scale $az )
    else
        # x<0
        if tsst $ay -gt 0 ; then
            # y>0
            az=$( div -s$atan2_scale $ay / $ax )
            out_atan2=$( atan -s$atan2_scale $az )
            out_atan2=$( add $out_atan2 + 180 )
        elif tsst $ay -lt 0 ; then
            # y<0
            az=$( div -s$atan2_scale $ay / $ax )
            out_atan2=$( atan -s$atan2_scale $az )
            out_atan2=$( add $out_atan2 - 180 )
        else
            # 'y=0'
            out_atan2=180.0
        fi
    fi
    # convert to radians if requested
    if [ 1 = "$orad" ] ; then
        out_atan2=$( deg2rad -s$out_scale $out_atan2 )
    else
        out_atan2=$( add -s$out_scale $out_atan2 )
    fi
    echo $out_atan2
} ## atan2
## out_scale= atan2_scale= orad= ax= ay= az= out_atan2=

# cos14 - backend for sin, cos
# depends on: 'mul' 'add'
# used by: 'sin' 'cos'
# the 14.7-digit approximation of cos, from:
# http://www.ganssle.com/item/approximations-for-trig-c-code.htm
# x2 = x*x
# cos(x) = c1 + x2(c2 + x2(c3 + x2(c4 + x2(c5 + x2(c6 + x2(c7 + x2*c8))))))
# inputs are in radians
cos14(){ out_scale=$defprec
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; esac
    x_cos=$1
    scale_cos=$((out_scale+2))
    # x2 = x*x
    x2=$( mul -s$scale_cos $x_cos $x_cos )
    # 8 constants
    c1=0.99999999999999806767
    c2=-0.4999999999998996568
    c3=0.04166666666581174292
    c4=-0.001388888886113613522
    c5=0.000024801582876042427
    c6=-0.0000002755693576863181
    c7=0.0000000020858327958707
    c8=-0.000000000011080716368
    #cos(x)= c1 + x2(c2 + x2(c3 + x2(c4 + x2(c5 + x2(c6 + x2(c7 + x2*c8))))))
    #     out_cos p2  s2  p3  s3  p4  s4  p5  s5  p6  s6  p7  s7   p8
    prod8=$( mul -s$scale_cos $x2 $c8 )
    sum7=$( add $prod8 + $c7 )
    prod7=$( mul -s$scale_cos $x2 $sum7 )
    sum6=$( add $prod7 + $c6 )
    prod6=$( mul -s$scale_cos $x2 $sum6 )
    sum5=$( add $prod6 + $c5 )
    prod5=$( mul -s$scale_cos $x2 $sum5 )
    sum4=$( add $prod5 + $c4 )
    prod4=$( mul -s$scale_cos $x2 $sum4 )
    sum3=$( add $prod4 + $c3 )
    prod3=$( mul -s$scale_cos $x2 $sum3 )
    sum2=$( add $prod3 + $c2 )
    prod2=$( mul -s$scale_cos $x2 $sum2 )
    out_cos=$( add -s$out_scale $prod2 + $c1 )
    echo $out_cos
} ## cos14
# ops 8X mul, 7X add

# sin14 - backend to sin, cos
# depends on: 'mul' 'add' 'div'
# used by: 'sin' 'cos'
##num[x_] = 12671/4363920*x^5 - 2363/18183*x^3 + x;
##den[x_] = 1 + 445/12122*x^2 + 601/872784*x^4 + 121/16662240*x^6;
##si[x_] = num[x]/den[x]
# inputs are in radians
sin14(){ out_scale=$defprec
    case $1 in -s*) out_scale=${1#*-s} ; shift ;; esac
    x_sin=$1
    scale_sin=$((out_scale+2))
    
    # pre-calculated ratios nominator side
    #rat1=( 12671 / 4363920 )   #rat2=( 2363 / 18183 )
    rat1=0.0029035821004968 #01041
    rat2=0.1299565528240664 #35681
    # pre-calculated ratios denominator side
    #rat3=( 445 / 12122 )    #rat4=( 601 / 872784 )   #rat5=( 121 / 16662240 )
    rat3=0.0367101138426002 #30984
    rat4=0.0006886010742635 #06205
    rat5=0.0000072619287682 #80855
    
    # calculate the needed powers of x from x^2 to x^6 
    x2=$( mul -s$scale_sin $x_sin x $x_sin )
    x3=$( mul -s$scale_sin $x2 x $x_sin )
    x4=$( mul -s$scale_sin $x3 x $x_sin )
    x5=$( mul -s$scale_sin $x4 x $x_sin )
    x6=$( mul -s$scale_sin $x5 x $x_sin )
    
    # calculate the numerator 'num'
    prod1=$( mul -s$scale_sin $rat1 x $x5 )
    prod2=$( mul -s$scale_sin $rat2 x $x3 )
    num=$( add  $prod1 - $prod2 + $x_sin )
    
    # calculate the denominator 'den'
    prod3=$( mul -s$scale_sin $rat3 x $x2 )
    prod4=$( mul -s$scale_sin $rat4 x $x4 )
    prod5=$( mul -s$scale_sin $rat5 x $x6 )
    den=$( add 1 + $prod3 + $prod4 + $prod5 )
    
    # rational result
    out_sin=$( div -s$out_scale $num / $den )
    # add the final sign
    echo $out_sin
} ## sin14
## scale_sn= scale_sin= x_sin= sin_neg= negintrmed= out_sin=
## rat1..5=  x2..6=  prod1..5=  num=  den=  r_sin=
# ops 10X mul, 2X add, 1X div

# deg2rad - convert degrees to radians    # x(pi/180)
# depends on: 'mul'
# used by: 'sin' 'cos' 'tan' 'atan' 'atan2'
# accurate to ~17 places
deg2rad(){ scale_dg2rd=$defprec
    case $1 in -s*) scale_dg2rd=${1#*-s} ; shift ;; 
        ''|'-h') echo "-->deg2rad: Converts Degrees to Radians" >&2 ; return 1 ;;
    esac 
    mul -s$scale_dg2rd $1 x 0.01745329251994329576 #9236907684 88613
} ## deg2rad

# rad2deg - convert radians to degrees     # x(180/pi)
# depends on: 'mul'
# used by: 'sin' 'cos' 'tan' 'atan'
# accurate to ~15 places
rad2deg(){ scale_rd2dg=$defprec
    case $1 in -s*) scale_rd2dg=${1#*-s} ; shift ;; 
        ''|'-h') echo "-->rad2deg: Converts Radians to Degrees" >&2 ; return 1 ;;
    esac 
    mul -s$scale_rd2dg $1 57.29577951308232087679 #815481410517
} ## rad2deg

# is_near_int - back-end helper for sin/cos/tan/atan
# determines if input is close to a round integer value, at scale
# depends on: 'add' 'tsst'
# used by: 'sin' 'cos' 'tan' 'atan'
is_near_int() { out_scale=$defprec
    case $1 in -s*) out_scale=${1#*-s} ; shift ;;esac
    # truncate input to scale for checking
    dummy=$( add -s$out_scale $1 )
    # separate the fraction
    dummy=${dummy#*.}
    # if all zeros -success
    tsst ${dummy#*.} -eq 0 && return 0
    # if all 9's, success, otherwise fail
    case ${dummy#*.} in *[0-8]*) return 1 ;; *) return 0 ;;esac
} ## is_near_int # out_scale= dummy=

### End trigonometry functions
