 % IQ_MISC(1) Version 2.0 | IQ_MISC Miscellaneous Functions for IQ

NAME
====

**iq_misc** — Miscellaneous Functions for the **IQ** Precision Decimal Calculator

Utility Functions
-----------------

**factorial** ---- Returns the 'Factorial' of a number

    Requires 1 integer input  
    Example: 'factorial 5' = 120  
    
**gcf** ---- Returns the Greatest Common Factor of 2 numbers

    Requires 2 integer inputs  
    Example: 'gcf 123 396' = 3  
    
**dec2ratio** ---- Converts a Decimal Fraction to a whole-number Ratio

    Requires a decimal fraction input  
    Example: 'dec2ratio 0.1388' = 347/2500
    
**spow** ---- Raise an integer to an integer power

    Usage: 'spow [-s?] base [^] exponent'
  
    'spow' is an enhancement of the exponentiation operator '**'
    'base' and 'exponent' must be integers, positive or negative.
    Example: 'spow 3 ^ 65' = 10301051460877537453973547267843
    
    The scale option only applies when 'exponent' is negative.
    SigFig scaling is used, so spow returns significant digits:
    Example: 'spow -s8 7 ^ -13' = 0.000000000010321087
    If not given, default scale ($defprec) is used:
    Example: 'spow -7 ^ -13' = -0.000000000010321

**pmod_eucl** ---- Returns a Positive Euclidian Modulo

    Usage: 'pmod_eucl [-s?] dividend divisor'
    
    Example: 'pmod_eucl -s0 23 17' = 6
    
**div_floor** ---- Returns the Quotient of Floored Division

    Usage: 'div_floor [-s?] dividend divisor'

    Example: 'div_floor -s0 23 17' = 3

**dot_1d** ---- 1D Multiply Accumulate Engine

    Usage: 'dot_1d [-s?] [-a??] series1 series2'
    
    'dot_1d' multiplies 2 series of numbers by each other,
    summing the products and optionally adding a constant
    amount to the Sum Of Products.
    
    Example - multiply two numbers and add a constant:
    'dot_1d -s8 -a2.7182 3.1416 1.618' = 7.8013088
    ( ( 3.1416* 1.618 ) + 2.7182 ) = 7.8013088
    
    Example Sum Of Products:
    dot_1d -s3 2 3 0.12 0.7 0.5 0.4 = 2.948
    ( (2*0.7) + (3*0.5) + (0.12*0.4) ) = 2.948
    
    Example Matrix Multiplication plus constant:
    dot_1d -s3 -a0.3 2 3 0.12 0.7 0.5 0.4 = 3.248
    ((2*0.7) + (3*0.5) + (0.12*0.4) + 0.3 ) = 3.248

    'dot_1d' expects an even number of inputs to be multiplied
    The two series of numbers are input in sequence, and dot_1d
    splits the inputs into two halves.
        | 2  x  0.7  |  1.4
        | 3  x  0.5  | +1.5
        | 0.12 x 0.4 | +0.48
        |            | ======
        |  SOP       |  2.948
        |  Addend    | +0.3
        |  Output    |  3.248

**mat2** ---- 1D X 2D Matrix Multiplication

    'mat2' is used in our AI projects to perform feed-forward
    Matrix Multiplication on square or non-square matrices.
    
    Example NN fragment with 3 Inputs and 2 Hidden nodes
      Inputs   H1weights  H2weights    Hidden Outputs
                 [0.7       0.3]       [1.4    0.6]
    [2 3 0.12] . [0.5       0.2]   =   [1.5    0.6]
                 [0.4       0.1]       [0.48   0.012]
                                       ==============
    Outputs:                           2.948   1.212
    In Parenthetic Notation:
    ((2*.7) + (3*.5) + (.12*.4)) =  2.948
    ((2*.3) + (3*.2) + (.12*.1)) =  1.212
    
    Example:
    mat2 -l3 -r2  2 3 .12 .7 .5 .4  .3 .2 .1  = 2.948   1.212
    
    where 2, 3 and 0.12 are Inputs,
    0.7, 0.5 and 0.4 are weight values from each
    Input to Hidden Node 1.
    0.3, 0.2 and 0.1 are the values of the weights from each
    Input to Hidden Node 2.
    
    The output is the two Sums Of Prodcuts.
    If a Bias is given, it will be added to each output.
    mat2 -l3 -r2 -b.3 2 3 .12 .7 .5 .4 .3 .2 .1 = 3.248 1.512
    
AUTHOR
======

Gilbert Ashley <https://github.com/ShellCanToo/iQalc>

SEE ALSO
========

**iq(1)** **iq+(1)** **iq_trig(1)**  **iq_misc(1)**  **iq_ai(1)**
