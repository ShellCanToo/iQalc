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
None of the functions in **iq+** require an Operator, but the Carat '^' can be used with 'pow' and epow'.

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

    Usage: 'pow [-s?] [-S?] base [^] exponent'
    
    Raises a number (base) to a power (exponent).
    When the exponent is an integer, base and exponent
    can be any size and precision is unlimited.
    Example: 'pow -s9 3.141592 ^ 6' = 961.387993507
    Example: 'pow -s12 12.141592 ^ -6' = 0.000000312137
    Supports Significant Digit scaling, with -S? option.
    Example: 'pow -S12 12.141592 ^ -6' = 0.000000312137674316
    
    Decimal exponents are supported, within a limited range.
    Output precision is limited to 12 decimal places.
    
    If base < 1, exponent can be any positive number:
    Example: 'pow -S6 0.53428 ^ 19.9345' = 0.00000374291
    
    If exponent < 1, base must be less than 100:
    Example: 'pow -s12 99.5342862 ^ 0.9345' = 73.638595054326
    
    If base and exponent are both greater than 1, base must
    be <10, and base+exponent must be less than 14:
    Example: 'pow -s6 5.3765 3.8184' = 615.658477
    Example: 'pow -s8 2.718282 ^ 9.141592' = 9335.620993414
    Example: 'pow -s9 2.718282 ^ -9.141592' = 0.000107116
    Example: 'pow -S9 2.718282 ^ -9.141592' = 0.00010711660

**epow** ---- Raise 'base' to an integer power

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
