 % IQ_UTIL(1) Version 2.0 | IQ_UTIL Utility  Functions for IQ

NAME
====
**iq_utility** — Utility Functions for the **IQ** Precision Decimal Calculator

DESCRIPTION
===========
These optional functions can be helpful when using *iq* in scripts.

Utility Functions
-----------------

**is_num** ---- Verify a number as a qualified value

    Returns an exit code on stderr indicating success
    (return value 0) or failure (return value 1).
    Usage: 'is_num Number ...'
    CLI Example: 'is_num 210a.37 ; echo $?' = 1
    Script Example: 'if is_num $Number ; then'

**padchars** ---- Print a string of characters of a given length

    Print a string of characters, 0's by default
    First arg is the desired string length.
    Second argument,if given, is the character to print.
    Example: 'padchars 5'  = 00000 
    Example: 'padchars 4 1'  = 1111
    Example: padchars 3 '<'  =  <<<
    
**incr** ---- Naive Addition for Increment/Decrement 1ulp

    Usage: 'incr [-a?] Number'
    
    Increments or decrements a decimal or integer by 
    1 Unit in the Last Place (ULP) or some 
    other single-digit integer, like 5.
    By default, it functions like away-from-zero rounding:
    Example: 'incr 1.234'   returns: 1.235 
    Example: 'incr -1.234'  returns: -1.235
    where the addend amount is 1. 
    
    Use the '-a' option to specify another amount.
    Example: 'incr -a5 1.234'  returns: 1.239
    Example: 'incr -a-5 1.234' returns: 1.229
    Do not use with numbers longer than 18 digits.
    
**ceil** ---- Self-standing Ceiling Function

    Usage: ceil [-s?] decimal-number
    
    Example: 'ceil -s5 1.234567' = 1.23457
    Example: 'ceil -s5 -1.234567' = -1.23456
    

**floor** ---- Self-standing Floor Function

    Usage: floor [-s?] decimal-number
    
    Example: 'floor -s5 1.234567' = 1.23456
    Example: 'floor -s5 -1.234567' = -1.23457

**trunc** ---- Truncate a number to a given precision

    Usage: trnc (-s?) Number
    
    Example: 'trunc -s5 -1.2345678' = -1.23456


**padit** ---- Print a string of zeroes

    Usage: padit [-s]Number
    
    Example: 'padit -s8'  returns: 00000000
    Example: 'padit 8'    returns: 00000000

AUTHOR
======

Gilbert Ashley <https://github.com/ShellCanToo/iQalc>

SEE ALSO
========

**iq(1)** **iq+(1)** **iq_trig(1)**  **iq_misc(1)**  **iq_ai(1)**
