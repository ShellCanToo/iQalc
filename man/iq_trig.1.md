 % IQ_TRIG(1) Version 2.0 | IQ_TRIG Trigonometry Functions for IQ

NAME
====

**iq_trig** — Trigonometry Functions for the **IQ** Precision Decimal Calculator

SYNOPSIS
========

**iq+** func_name \[-s?] number1  \[number2]

**iq+** \[**-h**|**--help**]

**iq+** func_name \[**-h**]

DESCRIPTION
===========

**IQ_TRIG** Extends the basic math functions provided by the **IQ** calculator. 

It includes these common Trigonometry functions:

*sin*  *cos*  *tan*  *atan* *atan2* *deg2rad* *rad2deg*

**sin** ---- Calculates the sine of an angle

    Usage: 'sin [-s?] [-rad -irad] angle'
    
    Returns the Sine of an 'angle', which
    can be in degrees (default) or in radians 
    Use the '-rad' or '-irad' option to input radians
    Accuracy: approximately 12 decimal places
    Example usage: 'sin -s6 91.35' = 0.999722
    Example usage: 'sin -s12 23.565' = 0.399789183758
    Example usage: 'sin -s12 -rad 0.411286838232' = 0.399789183757

**cos** ---- Calculates the cosine of an angle

    Usage: 'cos [-s?] [-rad -irad] angle'
    
    Returns the Cosine of an 'angle', which
    can be in degrees (default) or radians
    Use the '-rad' or '-irad' option to input radians
    Accuracy: approximately 12 decimal places
    Example usage: 'cos -s6 28.573' = 0.878208
    Example usage: 'cos -s12 98.827' = -0.153451510933
    Example usage: 'cos -s8 -rad 0.7417649320' = 0.01286791

**tan** ---- Calculates the tangent of an angle

    Usage: 'tan [-s?] [-rad -irad] angle'
    
    Returns the Tangent of an 'angle', which
    can be in degress (default) or radians
    Use the '-rad' or '-irad' option to input radians
    Accuracy: ~12 decimal places
    Example usage: 'tan -s6 28.573' = 0.544606
    Example usage: 'tan -s6 0.741764' = 0.012946
    Example usage: 'tan -s6 -rad 0.74176' = 0.015992

**atan** ---- Calculates the arctangent (inverse) of a tangent

    Usage: 'atan [-s?] [-rad -orad] tangent'
    
    Returns the Arctangent or inverse of a Tangent
    By default, outputs are in degrees
    Use the '-rad' or '-orad' option to output radians
    Accuracy: ~12 decimal places (more in very small x)
    Example usage: 'atan -s6 0.544606' = 28.572976
    Example usage: 'atan -s6 0.012946' = 0.741709
    Example usage: 'atan -s6 -rad 0.015992' = 0.741733

**atan2** ---- Calculates the arctangent of a planar coordinate position

    Usage: 'atan2 [-s?] [-rad -orad] X Y'
    
    Returns the Arctangent of a 2-coordinate position
    'X' and 'Y' are planar (Cartesian) coordinates
    By default, outputs are in degrees
    Use the '-orad' option to output radians
    To change input order to Y X,  use the '-yx' option
    'atan2' usage: 'atan2 [-s?] [-orad] -yx Y X'
    
    Accuracy: ~10 decimal places
    Example usage: 'atan2 -s10 3.722 3.425' = 42.6203916006
    Example usage: 'atan2 -s10 20.435 30.152' = 55.8732180030
    Example usage: 'atan2 -s10 -orad 20.435 30.152' = 0.9751716178
    Example usage: 'atan2 -s10 -rad -yx 30.152 20.435' = 0.9751716178

**deg2rad and rad2deg** ---- Convert degrees to/from radians

    Utility functions used by *sin* *cos* *tan* and *atan*
    Example: 'deg2rad 135.724' = 2.36883
    Example: 'rad2deg 1.6538' = 94.75576

AUTHOR
======

Gilbert Ashley <https://github.com/ShellCanToo/iQalc>

SEE ALSO
========

**iq(1)** **iq+(1)** **iq_util(1)**  **iq_misc(1)**  **iq_ai(1)**
