% IQ+(1) Version 2.0 | IQ+ Extended Calculator Documentation

NAME
====

**iq+** — Extended version of the **IQ** Precision Decimal Calculator

SYNOPSIS
========

**iq+** func_name \[-s?] number1 [operator] number2

**iq+** \[**-h**|**--help**]

**iq+** func_name \[**-h**]

DESCRIPTION
===========

**IQ+** Extends the basic math functions provided by the **IQ** calculator. 

It includes functions for computing logarithms in base 2, 3, 4, n/e or 10, roots, powers and exp().

**IQ+** auto-loads the *iq_trig* Trigonometry Module
and the *iq_misc* Module which contains advanced Multiplication and division tools.

See the *iq_trig* and *iq_misc* man-pages for the details of those functions.

OPTIONS
-------

-h, --help

    Prints general usage information

list
    
    Prints a list of avialable functions

STRUCTURE
---------
 *iq+* relies on the basic math functions from *iq*, so *iq* must also be available in the same location as *iq+*.
When run from the CLI, **iq+** automatically 'sources', or includes the basic math functions from **iq**, so they are also available from **iq+**.

SYNTAX
------
None of the functions in **iq+** require an Operator, but the Carat '^' can be used with 'pow', 'ipow' and epow'.

SCALE
-----
Unlike the Basic Math functions of *add*, *mul* and *div*, the functions in **IQ+** do not support arbitrary precision. Instead, they are
all 'tuned' to deliver fast, accurate results within a useful range -usually at least 12 places. The default scale is 6 decimal places. 

FUNCTIONS
=========
**logx** ---- Calculates Logarithms in base 10, 2, 3, 4 or 'e'(natural)

    Usage: 'logx [-s?] base num1'
    Example: 'logx -s8 10 6.7' for base10: log(6.7) or log(10,6.7)
    Example: 'logx -s7 n 6.7' for base'e': ln(6.7) (natural log)
    Example: 'logx -s7 2 6.7' for base2: log2(6.7) or log(2,6.7)
    Example: 'logx -s20 10 3.141592' = 0.49714978234172300499

    Recommended scale: 4-12
    Accurate to at least 20 decimal places.
    Execution times increase when scale >13

**nroot** ---- Calculates the nth-root of a number

    Usage: 'nroot [-s?] Number Nth'
    Example: 'nroot -s6 4.3 10' for: 10th root of 4.3
    Example: 'nroot -s8 43.225 2' for: sqrt of 43.225
    Example: 'nroot -s11 2 2' = 1.41421356237

    'Number' must be positive, integer or decimal.
    'Nth' must be a positive integer.
    
    Recommended scale: 4-12
    Execution times increase when scale >7
    
**exp** ---- Raises Euler's number 'e' to a given power (e^x)

    Usage: 'exp [-s?] exponent'
    Example: 'exp -s12 3.6' = 36.598234443678
    Example: 'exp -s8 1.134' = 3.10806392
    
    Recommended scale: 4-12
    Accurate to ~12 places where X <19

**pow** ---- Raises an integer or decimal number to a given power

    Usage: 'pow [-s?] base [^] exponent'
    
    Raises a number (base) to a power (exponent).
    For integer exponents, 'base' and scale are unlimited.
    Example: 'pow -s9 3.141592 ^ 6' = 961.387993507
    Example: 'pow -s12 12.141592 ^ -6' = 0.000000312137
    
    Fractional exponents are supported, within certain
    ranges, shown roughly below:
    59999.99999 ^ 0.999                     0.99999 ^ 1000009.999
    239.99999 ^ 1.999                       1.09999 ^ 109.999
    35.99999 ^ 2.999    5.99999 ^ 5.999     1.24999 ^ 45.999
    14.99999 ^ 3.999                        1.49999 ^ 26.999
    8.99999 ^ 4.999                         1.99999 ^ 14.999
    
    As seen above, when either 'base' or 'exponent' are <1,
    the allowed range of the other becomes relatively large.
    Above ranges support scales of 6-12, with a slightly wider
    range supporting a reduced scale of 3 less than requested.
    Example: 'pow -s8 7.999999 6.999999'  =  2097145.80409
    
    Recommended scale: 4-12
    Execution times increases dramatically when scale is >8
    Use of the Operator '^' is optional.

**ipow and epow** ----  Both serve as back-end functions to *pow* but can also be used separately.

    Both functions work only with a positive 'base' and integer
    'exponent'. *epow* is particularly useful with very large 
    or small numbers, since it can return answers in E-Notation. 

**ipow** ---- Raise a positive 'base' to an integer power

    Usage: 'ipow [-s?] base [^] exponent'
    
    'base' must be a positive number, integer or decimal.
    Exponents can be negative or positive, but must be integers.
    Example: 'ipow -s20 3.14 ^ -4' = 0.01028682632761480208
    Example: 'ipow -s9  9.35234 16' = 3425504893420641.05730195
    Use of the Operator '^' is optional.

**epow** ---- Raise a positive 'base' to an integer power

    Usage: 'epow [-s?,-S,-e?] base [^] exponent' 
    
    Both 'base' and 'exponent' must be positive numbers.
    'base' can be an integer or decimal, 'exponent' must be integer.
    'epow' returns powers with answers in three forms: normally
    scaled outputs, significant digits or scientific e-notation.
    Output format is controlled with 3 scaling options: -s? -S? or -e?
    
    Example usage for normal scaling: 'epow -s9 0.14 7' = 0.000001054
    Example for significant digits: 'epow -S9 0.14 7' = 0.00000105413504
    Example for e-notation: 'epow -e9 0.14 7' = 1.05413504e-6
    Example for e-notation: 'epow -e12 42.818 7' = 2.638667359224e11
    ~2-Billion-digit Example: epow -e6 0.0105 ^ 1000000000 = 1.174730e-1978810701
    
    'epow' does not accept inputs in E-Notation.

UTILITY FUNCTIONS
=================   
**getConst** ---- Returns a scaled-value of a Constant

    Usage: getConst (constant-name) [scale]
    
    getConst - returns a truncated or standard-length value of these constant:
    'e', 'pi', 'ln(10)', 'pi/2', 'pi/4' or 'phi'
    
    Example: 'getConst e 24' returns 'e' truncated to 24 places
    Example: 'getConst e' alone returns 'e' to 11 places
    
    Maximum precision of Constants is 30.

AUTHOR
======

Gilbert Ashley <https://github.com/ShellCanToo/iQalc>

SEE ALSO
========

**iq(1)** **iq_trig(1)** **iq_misc(1)**
