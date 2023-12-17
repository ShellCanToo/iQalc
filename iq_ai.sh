#!/bin/sh

# 'iq_ai.sh' is a Module of the iQalc/IQ precision calculator
# It is not an executable program
# It contains various Neural Network Activation Functions 

# Copyright Gilbert Ashley 18 December 2023
# Contact:perceptronic@proton.me  Subject-line: iQalc

# iq_ai_funcs version=1.82

# List of functions and derivative functions included here:
# logistic functions: tanh, tanh_pade, tanh_d1, tanh_d2, sigmoid, sigmoid_tanh, sigmoid_d1, sigmoid_d2
# Other activation functions: softmax, softmax2, softplus, softplus_d1, softsign, softsign_d1, 
# relu, lrelu, swish, mish, logish
# Functions with names ending in '_d1' or '_d2' return 1st and 2nd derivatives of their similarly-named functions

# disable shellcheck style notices and un-helpful suggestions
# shellcheck disable=SC2034,SC2086,SC2295,SC2004,SC1090,SC1091,SC2154,SC2046

iqaimain="sigmoid sigmoid_tanh tanh softsign swish erf erfcx erf_fast one_hot two_hot "
iqaiother="softmax softy softplus relu lrelu sgn tanh_pade swish_exp signrelu sinerelu pelu "
iqaiderivs="sigmoid_d1 sigmoid_d2 tanh_d1 tanh_d2 softplus_d1 "
iqaiderivs2="swish_d1 sinerelu_d1 softsign_d1 relu_d1 lrelu_d1 erf_d1 "

### Functions needing exp or logx
# sigmoid tanh softmax softplus swish_exp logish mish
### Functions needing both iq+ and iq_trig
# sinerelu

# sigmoid_real logistic function -  
# sigmoid (x) = 1 / (1 + e^-x)  -or- sigmoid(x) = (1 + exp(−x))^−1
# depends on: 'exp' 'add' 'div'
sigmoid() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    in=$1  signeg=''
    case $in in '-'*) signeg='-' in=${in#*-} ;; esac
    a=$( exp -s$scale $in )
    b=$( add 1 + $a )
    out=$(div -s$scale 1 / $b)
    case $signeg in 
        '-') echo $out ;;
        *) add 1 - $out ;;
    esac
} ## sigmoid

# the sigmoid logistic function -using tanh
# depends on: 'mul' 'tanh/tanh_pade' 'add' 'div'
# σ(x) = (tanh(@x/2)+1) / 2
# This is used with tanh_pade (from below) in our example Neural Network,
# which gives easy access to both sigmoid and tanh Activations
# without needing anything except add, mul, and div
sigmoid_tanh() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    tscale=$((scale+2))
    x_divided=$( mul -s$tscale $x 0.5 )
    #tanh_beta=$( tanh_pade -s$tscale $x_divided )  # use this to not depend on exp
    tanh_beta=$( tanh -s$scale $x_divided )
    tanh_beta_plus_1=$( add $tanh_beta + 1 )
    div -s$scale $tanh_beta_plus_1 / 2
} ## sigmoid_tanh

# sigmoid 1st derivative
# depends on: 'sigmoid/sigmoid_tanh' 'add' 'mul'
# sigmoid'@(x) = (@*sig@(x)) * (1 - sig@(x))
sigmoid_d1() {  case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    sig_x=$( sigmoid -s$scale $x )
    #sig_x=$( sigmoid_tanh -s$scale $x )    # use this to not depend on exp
    one_less_sig_x=$( add 1 - $sig_x )
    mul -s$scale $sig_x $one_less_sig_x
} ## sigmoid_d1

# sigmoid 2nd derivative
# depedns on: 'sigmoid/sigmoid_tanh' 'add' 'mul'
# sigmoid'@(x) = (@*sig@(x)) * (1 - sig@(x))
sigmoid_d2() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    sig_x=$( sigmoid -s$scale $x)
    #sig_x=$( sigmoid_tanh -s$scale $x )    # use this to not depend on exp
    one_less_sig_x=$( add 1 - $sig_x )
    two_t_sig_x=$( mul 2 $sig_x )
    one_less_2t_sig_x=$( add 1 - $two_t_sig_x )
    sigd2=$( mul $sig_x $one_less_sig_x)
    mul -s$scale $sigd2 $one_less_2t_sig_x
} ## sigmoid_d2

# tanh_real - tanh(x) = (e^2x -1) / (e^2x + 1)
# depends on: 'exp' 'add' 'div'
tanh(){ case $1 in -s*) thrprec=${1#-s*} ; shift ;; *) thrprec=$defprec ;;esac
    case $1 in -orad|-rad) orad=1 ; shift ;;esac
    tanh_x=$1 up_scale=$((thrprec+3))
    case $tanh_x in '-'*) tanh_neg='-' tanh_x=${tanh_x#*-} ;; *) tanh_neg= ;; esac
    tanh_z=$( add $tanh_x $tanh_x )
    case $tanh_z in '-'*) tanh_neg='-' tanh_z=${tanh_z#*-} ;; esac
    tanh_z=$( exp -s$thrprec $tanh_z )
    tanh_a=$( add -s$up_scale $tanh_z - 1 )
    tanh_b=$( add -s$up_scale $tanh_z + 1 )
    r_tanh=$( div -s$thrprec $tanh_a / $tanh_b )
    case $orad in
        1) deg2rad $tanh_neg$r_tanh ;;
        *) echo $tanh_neg$r_tanh ;;
    esac
} ## tanh  # thrprec= x= up_scale= tanh_z= tanh_a= tanh_b=

# tanh 1st derivative - tanh′(x) = 1 − tanh(x)^2
# depends on: 'tanh/tan_pade' 'mul' 'add'
tanh_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;;esac
    x=$1 
    trim=$scale scale=$((scale+2))
    a=$( tanh -s$scale $x ) # tanh
    #a=$( tanh_pade -s$scale $x )   # use this to not depend on exp
    a2=$( mul -s$scale  $a $a )
    add -s$trim 1 - $a2
} ## tanh_d1

# tanh 2nd derivative - f′′(x)=−2f(x){1−f(x)2
# depends on: 'tanh_/tanh_pade' 'mul' 'add'
tanh_d2() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;;esac
    x=$1 
    trim=$scale scale=$((scale+2))
    a=$( tanh -s$scale $x ) # tanh
    #a=$( tanh_pade -s$scale $x )   # use this to not depend on exp
    a2=$( mul -s$scale  $a $a )
    a3=$( add -s$trim 1 - $a2 ) # tanh_d1
    
    a4=$( mul -s$scale -2 $a )
    mul -s$trim  $a3 $a4
} ## tanh_d2

# softmax - activation function
# depends on: 'exp' 'add' 'div' 'tsst'
# softmax(x) = e^x_1 / (e^x_1+e^x_2+...e^x_n )  e^x_2 / (e^x_1+e^x_2+...e^x_n )
softmax() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    case $1 in -i) index=1 ; shift ;; esac
    sopws=0 pws=''
    while [ "$1" ] ; do
        pw=$( exp -s$scale $1 )
        # accumulate a sum-of-powers
        sopws=$( add $sopws $pw )
        # and a list of powers
        pws="${pws}${pw} "
        shift
    done
    # calculate outputs and keep list
    out=''
    for pw in $pws ; do
        out="${out}$( div -s$scale $pw / $sopws ) "
    done
     # if requested, return the index of the largest output
    case $index in 
        1)  idx=0 winner=0 largest=0
            for iout in $out ; do
                idx=$((idx+1)) 
                tsst $iout -gt $largest && { largest=$iout winner=$idx ;}
            done
            echo $winner ;;
        *)  echo $out ;;
    esac
} ## softmax

# softplus - activation function
# depends on: 'exp' 'add' 'logx'
# highly accurate, but slow
# best to use at: domain -5<x<5 , scale=5-8
# softplus (x) =ln(1+exp(x))
softplus() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    a=$1
    z=$( exp -s$scale ${a#*-} )
    w=$( add 1 + $z )
    logx -s$scale e $w
} ## softplus

# softplus 1st derivative
# depends on: 'exp' 'add' 'div'
# softplus'(x) = 1 / (1 + e^-x)
softplus_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    a=$1 
    z=$( exp -s$scale ${a#*-} )
    a2=$( add 1 + $z )
    div -s$scale 1 / $a2
} ## softplus_d1


# swish - activation function
# depends on: 'sigmoid/sigmoid_tanh' 'mul'
# swish(x) = x * sigmoid(beta x) = x / (1+e^(beta x)
swish() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    sigmoid_beta=$( sigmoid -s$scale $x )
    #sigmoid_beta=$(sigmoid_tanh -s$scale $x )
    mul -s$scale $x x $sigmoid_beta
} ## swish
# d1 y = x . (1/(1+e-x))

# swish using exp instead of sigmoid
# depends on: 'exp' 'add' 'div'
swish_exp() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    sigmoid_beta=$( exp -s$scale -"${x#*-}" )
    sigmoid_beta=$( add 1 + $sigmoid_beta )
    div -s$scale $x / $sigmoid_beta
    
} ## swish

# First Derivative of swish
# depends on: 'sigmoid' 'swish' 'add' 'mul'
# https://iq.opengenus.org/swish-activation-function/
# swish_der = ( b * swish_function(b, x)) + (sigmoid(b, x) * (1 - (b * swish_function(b, x)))  )
# we use no 'b' beta here
swish_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    sig=$( sigmoid -s$scale $x )
    sw=$( swish -s$scale $x )
    oneless=$( add 1 - $sw )
    add -s$scale $sw $( mul $sig x $oneless )
}



# sinerelu needs BOTH iq+ and iq_trig
# sinerelu is a new, little-known Activation -one review claimed good results
# https://wilder-rodrigues.medium.com/sinerelu-an-alternative-to-the-relu-activation-function-e46a6199997d
sinerelu() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    # allow a parameter to control wave amplitude
    # 0.0025 or 0.25 for dense layers
    case $1 in -a*) param=${1#*-p} ; shift ;; *) param=1 ;; esac
   
    case $1 in
        0|.0|0.0) echo -1.0 ; return ;;
        -*) s=$( sin -s$scale $1 )
            c=$( cos -s$scale $1 )
            case $param in 
                1) add $s - $c ;;
                *) mul -s$scale $param $( add $s - $c ) ;;
            esac
        ;;
        *) echo $1 ; return ;;
    esac
}
# 1st Derivative of sinerelu
sinerelu_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    case $1 in 0|0.0) echo 1.0 ; return ;; esac
    c=$( cos -s$scale $1 )
    s=$( sin -s$scale $1 )
    add $c + $s
}

# Everything below here does not need iq+, that is exp or logx (or other)

# tanh_pade - Pade's 5/6 approximation of tanh
# depends on: 'mul' 'add' 'div'
# ~4X faster than tanh, accurate to ~4-7 places
# domain -4.41 < x < 4.41 
# p(x) = x*(10395+1260*x**2+21*x**4)/(10395+4725*x**2+210*x**4+x**6)
tanh_pade() { case $1 in -s*) thpscale=${1#-s*} ; shift ;; *) thpscale=$defprec ;;esac
    x=$1
    case $x in '-'*) tanh_neg='-' x=${x#*-} ;; *) tanh_neg= ;; esac
    x2=$( mul -s$thpscale $x $x )
    x4=$( mul -s$thpscale $x2 $x2 )
    x6=$( mul -s$thpscale $x4 $x2 )
    # nom
    a=$( mul -s$thpscale 1260 $x2 )
    b=$( mul -s$thpscale 21 $x4 )
    d=$( add 10395 + $a + $b  )
    e=$( mul -s$thpscale $x $d )
    # denom
    f=$( mul -s$thpscale 4725 $x2 )
    g=$( mul -s$thpscale 210 $x4 )
    j=$( add -s$thpscale  10395 + $f + $g + $x6 )
    
    r_tanh=$( div -s$thpscale $e / $j )
    echo $tanh_neg$r_tanh
} ## tanh_pade

## softy - Cheap substitute, ~5X faster than softmax
# depends on: 'mul' 'add' 'div' 'tsst'
# enhances difference between outputs, compared to softmax
# With '-i' option, outputs the Index of the largest output
# softy(x) = x_1^2 / (x_1^2 + x_2^2 + ...x_n^2 )
softy() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    case $1 in -d) withderivs=1 ; shift ;; *) withderivs=0 ;; esac
    sos=0 squares='' exes=''
    while [ "$1" ] ; do
        sq=$( mul $1 $1 )
        # accumulate a sum-of-squares
        sos=$( add $sos $sq )
        # and a list of squares
        squares="${squares}${sq} "
        # keep a list of the inputs
        exes="${exes}${1} "
        shift
    done
    # calculate outputs and keep list
    out='' derivs=''
    for sqr in $squares ; do
        out="${out}$( div -s$scale $sqr / $sos ) "
        # calculate the gradient of this output, if requested
        case $withderivs in 1)
            x=${exes%%' '*}  exes=${exes#*' '}
            # 2(b^2+a^2)x / (x^2+b^2+a^2)^2
            # denominator is sos^2
            denom=$( mul $sos $sos )
            sum=$( add $sos - $sqr )
            # nominator sum leaves out current square
            nom=$( mul 2 $sum $x )
            q=$( div -s$scale $nom / $denom )
            derivs="${derivs}${q} "
            ;;
        esac
    done
    case $withderivs in 1)  echo \'$out\' \'$derivs\' ;;
        *)  echo $out ;;
    esac
   
} ## softy
# x^2 / (x^2+a^2+b^2 )

# softy'(x)  according to : https://www.derivative-calculator.net/
# softy_d1
# 2(b^2+a^2)x / (x^2+b^2+a^2)^2
softy_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1 ; shift
    a=$1 ; shift
    b=$1 ; shift
    x2=$( mul $x $x )
    a2=$( mul $a $a )
    b2=$( mul $b $b )
    numsum=$( add $a2 $b2 )
    num=$( mul 2 $numsum $x )
    
    denomsum=$( add $numsum $x2 )
    denom=$( mul $denomsum $denomsum )
    
    div -s$scale $num / $denom
}

# softsign - activation function
# depends on: 'div' 'add'
# highly accurate 
# softsign(x) = x/(1+|x|)
softsign(){ case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    div -s$scale $1 / "$( add 1 + ${1#*-} )"
} ## softsign

# softsign 1st derivative
# depends on: 'add' 'mul' 'div'
# highly accurate
# softsign'(x) = 1/(1+|x|)^2
softsign_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    a=$( add -s$scale 1 + ${x#*-} )
    a2=$( mul -s$scale $a $a )
    div -s$scale 1 / $a2
} ##  softsign_d1

# sgn
# depends on: 'cmp3w'
# sgn can't be fooled with '-0' -both relu's can
sgn() {
    case $( cmp3w $1 0 ) in '>') echo 1;; '<') echo -1;; '=') echo 0;; esac
} ## sgn

# relu - activation function
# relu(x) = max(0,x)
relu() { case $1 in -s*) shift ;; esac
    case $1 in '-'*) echo 0 ;; *) echo $1 ;; esac
} ## relu

relu_d1() { case $1 in -s*) shift ;; esac
    tsst $1 -gt 0 && echo 1 || echo 0
} ## relu

# lrelu - LeakyRelu activation function
# lrelu(x) = max(0.01,x)
lrelu() { case $1 in -s*) shift ;;esac
    case $1 in '-'*|0) echo 0.01 ;; *) echo $1 ;; esac
} ## lrelu
# lrelu_d1 - LeakyRelu First Derivative
lrelu_d1() { case $1 in -s*) shift ;;esac
    case $1 in '-'*) echo 0.01 ;; *) echo 1 ;; esac
}


## signrelu - 
# https://arxiv.org/pdf/2210.10264v2.pdf
# depends on: 'add' 'mul' 'div'
signrelu() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    case $1 in -a*) alpha=${1#-a*} ; shift ;; *) alpha=1 ;; esac
            #if x>0     x
 # f(x) = 
            # if x<0    alpha * ( x / |(1+x)| )
    x=$1
    case $x in
        0|0.0) echo 0.0 ; return ;;
        1|1.0) echo 0.5 ; return ;;
        -*) #div -s$scale $x / $( add 1 + ${x#*-} ) 
            sum=$( add 1 + ${x#*-} )
            out=$( div -s$scale $x / ${sum} )
            case $alpha in 
                1) echo $out ;;
                *) mul -s$scale $alpha x $out ;;
            esac
        ;;
        *) echo $x ;;
    esac
}

# signrelu First Derivative
# depends on: 'add' 'mul' 'div'
signrelu_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    case $1 in -a*) alpha=${1#-a*} ; shift ;; *) alpha=1 ;; esac
    x=$1
    case $x in
        0|0.0) echo 1.0 ; return ;;
        1|1.0) echo 0.25 ; return ;;
        -*)  sum=$( add 1 + ${x#*-} )
            sum2=$( mul -s$scale $sum x $sum )
            case $alpha in
                1) out=$( div -s$scale 1 / ${sum2} ) ;;
                *) sum2=$( div -s$scale 1 / ${sum2} ) 
                    out=$( mul -s$scale $alpha x $sum2 ) ;;
            esac
            echo $out
        ;;
        *) echo $x ;;
    esac
}

# ELU
# f(x) = x if x > 0
# f(x) = alpha(exp(x)-1) if x <= 0

# PELU
# f(x) = x if cx > 0
# f(x) = a(exp(x/b)-1)
# Where a, b, and c > 0. 
# Here c causes a change in the slope in the positive quadrant,
# b controls the scale of the exponential decay, 
# and a controls the saturation in the negative quadrant.
# Trottier, Giguere, Chaib-draa
# from: https://arxiv.org/pdf/1605.09332.pdf
# f(h) = (a/b)*h if h >=0
# f(h) = a * (exp(a/h)-1) if h <0
# a deriv : 
# f'(h) =  h/b  if h >=0
# f'(h) =  exp(h/b)-1  if h <0
# b deriv:
# f'(h) =  -((a*h)/b^2)  if h >=0
# f'(h) =  -((a/b^2) * exp(h/b))  if h <0
pelu() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    # Three inputs, X (total input), a (learn-able parameter), b (learn-able parameter)
    # when a and b both equal 1, this function mirrors the ELU function
    [ -z "$3" ] && { echo "--> pelu: Requires 3 args - Input ParamA ParamB" ;}
    x=$1
    #a=0.1 b=1
    a=$2 b=$3
    
    b2=$( mul $b $b )
    
    if tsst $x -ge 0 ; then
        # f(h) = (a/b)*h if h >=0
        val=$( mul -s$scale $x $(div -s$scale $a / $b) )
        # a deriv: f'(h) =  h/b  if h >=0
        aderiv=$( div -s$scale $x / $b)
        # b deriv: f'(h) =  -((a*h)/b^2)  if h >=0
        A=$( mul -s$scale $a $x)
        bderiv='-'$( div -s$scale $A / $b2 )
    else
        # f(h) = a * (exp(a/h)-1) if h <0
        A=$( div -s$scale $a / $x )
        B=$( exp -s$scale $A )
        C=$( add $A - 1 )
        val=$( mul -s$scale $a $C)
        # a deriv: f'(h) =  exp(h/b)-1  if h <0
        A=$( div -s$scale $x / $b )
        B=$( exp -s$scale $A )
        aderiv=$( add $B  - 1 )
        # b deriv: f'(h) =  -((a/b^2) * exp(h/b))  if h <0
        C=$( div -s$scale $a / $b2 )
        bderiv='-'$( mul -s$scale $C $B )
    fi
    # parameters should be at least 0.1
    tsst $aderiv -lt 0.1 && aderiv=0.1
    tsst $bderiv -lt 0.1 && bderiv=0.1
    
    echo $val $aderiv $bderiv
}

## erf Gaussian Error Function
# depends on: 'exp' 'add' 'mul' 'div'
# https://stackoverflow.com/questions/457408/is-there-an-easily-available-implementation-of-erf-for-python
# accurate to ~7 places over 0 < X < 3.7
# Maximum X = 3.7
# accepts a Z-score input
erf() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    case $1 in -z*) zscore=${1#-z*} ; shift ;; *) zscore=1 ;; esac
    [ $scale -gt 7 ] && trim=7 || trim=$scale
    scale=$((scale+2))
    x=$1
    case $x in -*) neg='-' x=${x#*-} ;; *) neg='' ;; esac
    # this maxes out at x > ~3.7
    if tsst $x -gt 3.7 ; then
        echo 1.0 ; return
    fi
    a1=0.254829592
    a2=-0.284496736
    a3=1.421413741
    a4=-1.453152027
    a5=1.061405429
    p=0.3275911
    
    # A&S formula 7.1.26  (erf)
    # t = 1.0/(1.0 + p*x)
    # y = 1.0 - (((((a5*t + a4)*t) + a3)*t + a2)*t + a1)*t*math.exp(-x*x)
    #         out      A  B    C   D    E  F    G  H    I J  expx2    x2
    case $zscore in 
        1) t=$( div -s$scale 1 / $(add 1 + $(mul $p $x)) ) ;;
        *) t=$( div -s$scale 1 / $(add 1 + $(mul $p $x $zscore)) )
    esac
    x2=$( mul -s$scale $x $x )
    expx2=$( exp -s$scale '-'$x2 )
    A=$( mul -s$scale $a5 $t ) B=$( add $A $a4 )
    C=$( mul -s$scale $B $t ) D=$( add $C $a3 )
    E=$( mul -s$scale $D $t ) F=$( add $E $a2 )
    G=$( mul -s$scale $F $t ) H=$( add $G $a1 )
    I=$( mul -s$scale $H $t )
    J=$( mul -s$scale $I $expx2 )
    out=$( add -s$trim 1 - $J )
    # erf(-x) = -erf(x)
    echo ${neg}$out
}

# erf_fast - low-precision
# depends on: 'tanh/tanh_pade' 'add' 'mul' 'div'
# f(x) = tanh[ (167x/148) + (11x^3/109) ]
# accurate to only 2-3 places
# ~3X faster than erf above (7-digit precison)
erf_fast() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    case $x in -*) neg='-' x=${x#*-} ;; *) neg='' ;; esac
    # f(x) = tanh[ (167x/148) + (11x^3/109) ]
    #                 A B         C   D
    A=$( mul 167 $x )
    B=$( div -s$scale $A / 148 )
    x3=$( mul -s$scale $x $x $x )
    C=$( mul 11 $x3 )
    D=$( div -s$scale $C / 109 )
    # 2.5X faster with Pade' instead of real tanh
    out=$( tanh_pade -s3 $( add $B + $D ) )
    echo ${neg}$out
}

## erfcx - Universal erf-family function outputs: erf erfc erfcx
# depends on: 'nroot' 'exp' 'add' 'mul' 'div'
# higher-precision alternative from here:
# https://rmets.onlinelibrary.wiley.com/doi/full/10.1002/asl.154
# f(x) = a / ( (a-1)*(sqrt(pi*x^2)) + ( sqrt( pi*x^2 + a^2 ) )
# Maximum X = 5.999999 
# for simple erf, near zero @~2-3, increasing accuracy to @~9 at x=3.7 (normal erf's limit)
# for simple erf greater between 3.7 & 5.999999, accuracy increases from 9 places to 18
# for x 3.5 to 5.999999, this will guarantee at least 9-places
# use -c option to calculate erfc (complementary erf)
# use -cx option to calculate erfcx (scaled complementary erf) e^(x^2)*erfc(x)
## Ideal parameter values given by authors and their comments
## a=2.75193839388 a2=7.573164923710834 #0214544 # Negative errors for erf(x), positive errors for erfc(x) and e^(x^2)erfc(x)
## a=2.7889 a2=7.7780 # Smallest relative errors for erf
## a=2.7749 a2=7.70007 # Smallest relative errors for all
## a=2.9110 a2=8.4740 # Smallest relative errors for erfc and ex^2erfc
## a=3 a2=9 # neat formula
# By default, returms erf 
erfcx() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    opt=1   # opt1 is erf  opt2 is erfc  opt3 is erfcx
    case $1 in -c) opt=2 ; shift ;; -cx) opt=3 ; shift ;;  -n) opt=4 ; shift ;; esac

    trim=$scale
    scale=$((scale+5))
    x=$1
    case $x in -*) neg='-' x=${x#*-} ;; *) neg='' ;; esac
    
    # unlike above, we get better results for erf using 2.9110
    case $opt in
        #1) a=2.7889 a2=7.7780 ;;
        1|2|3) a=2.9110 a2=8.4740 ;;
        4) a=3 a2=9 ;;
    esac
    echo a=$a a2=$a2
    # f(x) = a / ( (a-1)*(sqrt(pi*x^2)) + ( sqrt( pi*x^2 + a^2 ) )
    #                   A                       C        B
    x2=$( mul -s$scale $x $x )
    a_lessone=$( add $a - 1 )
    pix2=$( mul -s$scale $pi $x2 )
    sqrtpix2=$( nroot -s$scale $pix2 2 )
    A=$( mul -s$scale $a_lessone $sqrtpix2 )
    B=$( add $pix2 + $a2 )
    C=$( nroot -s$scale $B 2 )
    denom=$( add $A + $C )
    # erfcx
    case $opt in 3) div -s$trim $a / $denom ; return ;;
        *) erfcx=$( div -s$scale $a / $denom ) ;;
    esac
    # erfc
    expx2=$( exp -s$scale $x2)
    case $opt in 2) div -s$trim $erfcx / $expx2 ; return ;;
        *) erfc=$( div -s$scale $erfcx / $expx2 ) ;;
    esac
    # erf
    erf=$( add -s$trim '-'$erfc + 1 )
    echo ${neg}$erf
}

# erf_d1
# depends on: 'exp' 'mul'
# f'(x) = ( 2/(sqrt(pi)) ) * e^-(x^2)
erf_d1() { case $1 in -s*) scale=${1#-s*} ; shift ;; *) scale=$defprec ;; esac
    x=$1
    # 2/(sqrt(pi))
    half_sqrt_pi=1.128379167095512573896
    x2=$( mul -s$scale $x $x )
    expx2=$( exp -s$scale '-'$x2 )
    mul -s$scale $half_sqrt_pi $expx2
}
# erf(z)=(2/(sqrt(pi)) * (z − z^3/3 + z^5/10 − z^7/42 + z^9/216− ⋯)

## one_hot - returns the index of the largest value in a set of inputs
#   or a binary bit representation of the set ranking
one_hot() { case $1 in -i) index=1 ; shift ;; *) index=0 ;; esac
    idx=0 winner=0 largest=0
    for iout in "$@" ; do
        idx=$((idx+1)) 
        if tsst $iout -gt $largest ; then
            largest=$iout winner=$idx
        fi 
    done
    case $index in
        1) echo $winner ;;
        *) cnt=0 pattern=''
            while [ $cnt -lt $idx ] ; do
                cnt=$((cnt+1))
                [ $cnt -eq $winner ] && out="${out}1" || out="${out}0"
            done
            echo $out ;;
    esac
}

# two_hot - returns the index of the two largest values in a set of inputs
#   or a binary bit representation of the set rankings
two_hot() { case $1 in -i) index=1 ; shift ;; *) index=0 ;; esac
    idx=0 winner=0 largest=0 winner2=0 second=0
    copy="$*"
    for iout in "$@" ; do
        idx=$((idx+1)) 
        if tsst $iout -gt $largest ; then
            largest=$iout winner=$idx
        fi 
    done
    idx=0
    for iout in $copy ; do
        idx=$((idx+1))
        [ "$iout" = $largest ] && continue
        if tsst $iout -gt $second ; then
            second=$iout winner2=$idx
        fi 
    done
    
    case $index in
        1) echo $winner $winner2 ;;
        *) cnt=0 pattern=''
            while [ $cnt -lt $idx ] ; do
                cnt=$((cnt+1))
                if [ $cnt -eq $winner ] ; then
                    out="${out}1" 
                elif [ $cnt -eq $winner2 ] ; then
                    out="${out}1"
                else
                    out="${out}0"
                fi
            done
            echo $out ;;
    esac
}

