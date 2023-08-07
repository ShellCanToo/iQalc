% IQ(1) Version 2.0 | IQ Calculator Documentation

NAME
====

**iq** An arbitrary precision decimal calculator

SYNOPSIS
========

**iq** func_name \[-s?] number1 operator number2

**iq** func_name \[**-h**]

**iq** \[**-h**|**--help**]

**iq** **-i**


DESCRIPTION
===========

**IQ** is an arbitrary precision decimal calculator, which performs the Basic Math operations of Addition, Subtraction, Multiplication, Division, Remainder, Modulo, Numeric-comparison and Rounding.

*iq* can be run interactively or used as a one-shot command-line calculator. And, it can be  'sourced' into the shell environment for 'on-line' use.
*iq* was designed especially to replace other CLI calculators in shell scripts where precision math and good performance is needed.

The Basic operations are also the basis for several extensions or modules. They perform more complex operations or mathematical functions, like powers, roots, logarithms, trigonometry, calculus or neural-networking. 

More than 60 functions are available, grouped into 5 Modules. Each module depends only on the **IQ** Basic Math operations, so there are no complex inter-dependencies.

OPTIONS
-------

-h, --help

    Prints general usage information

-i

    Runs 'iq' in Interactive Mode

list
    
    Prints a list of avialable functions
    
NUMBERS
-------
Input numbers can  be integers or decimal numbers of nearly any length.
Maximum number length is limited only by the shells' maximum variable length.

Inputs and outputs are in normal decimal notation:

1726    -1726    1726.34869   -1726.5736
    
    
STRUCTURE
---------
*iq* consists of shell functions, each of which performs a basic math operation. The main functions are intuitively-named and mostly follow the same basic syntax and usage.
        
Externally, *iq* has *Zero Dependencies*, other than the shell itself. Internally, each public function acts like a separate program and takes care of its' own input/output, to minimize dependencies between functions.

*iq* is written completely in minimal shell language, so it runs under all popular Linux/Unix shells, like *bash*, *zsh*, *dash*, *ksh* and *busybox-ash*. It neither reads nor writes to any file and calls no external programs.

SYNTAX
------
The basic command syntax of the *iq* functions is: 
    
**Function-Name**   **Number1**   **Operator**   **Number2**

where Function-Name is one of: *add* *mul* *div* *tsst*

The functions *add*, *mul* and *div* support scaling of the output, with the '-s?' option, which truncates answers to the desired precision. When used, the scaling option should be the first parameter after Function-name.

When calculating a series of inputs with *add* or *mul*, scaling is only performed after the last operation. Otherwise they return the full answer without truncating. 

If specified scale is zero '-s0', output is returned in integer form. 

Final results from *mul* and *div* can be rounded using any one of 5 methods:
    
*half-up*, *half-even*, *floor*, *ceiling* or *truncation*
    
Rounding is done only if requested.
    
See below for syntax and usage of *cmp3w* and *round*.

OPERATORS
---------
*div* always requires one the operators '/' '%' 'm' or 'qr'

*mul* doesn't require an operator, but allows either 'x' or 'X -do not use the asterisk  '\*'

*add* doesn't need operators, except when to avoid double-negatives in scripting

*tsst* uses the same numeric comparison operators as the shell's 'test' builtin:

 '-lt' '-le' '-eq' '-ge' '-gt' or '-ne'


SCALE
-----
Scale values must be positive integers, and signify the number of places of precision after the Decimal Point.

There are no hard limits on scale/precision for any of the Basic Arithmetic operations, but larger scales do take longer to calculate.

EXPRESSIONS
===========

**iq** takes advantage of the shell's native white-space separation of operators and values, so
expressions use syntax similar to the shell itself or the 'expr' program.

All input elements must be space-separated: 'add 2.347 + 3.7' not: 'add 2.347+3.7'

**iq** does not process parenthetic expressions like (242+(3*4)). But nesting can be done using the shells built-in capabilities, like this:

    iq add 242 $(iq mul 3 4)
    var=$(iq add 242 $(iq mul 3 4))
    In scripts or in-session mode:
    add 242 $(mul 3 4)
    var=$(add 242 $(mul 3 4))

BASIC MATH FUNCTIONS
====================

Items inside square brackets '[]' are optional

Required Items are shown in parentheses '()'

**add** ---- Addition and Subtraction of 2 or more numbers

    Usage: 'add [-s?] num1 [+-] num2 ... numN' 
  
    If scale is omitted or '-soff', no truncation is done
    Example: 'add 2.340876 + 1827.749048' = 1830.089924
    Example: 'add 2.340876 - 1827.749048' = -1825.408172
    
    Otherwise, result is truncated to the given scale
    Example: 'add -s4 2.340876 + 1827.749048' = 1830.0899
    
    If scale is zero '-s0', output is in integer form
    Example: 'add -s0 2.340876 1827.749048' = 1830
    
    When summing a series of inputs, results are only 
    truncated after the last calculation. Operators are
    optional. Currently, no rounding is done by 'add'.

**mul** ---- Multiplication of 2 or more numbers

    Usage: 'mul [-s?] [-r...] num1 [xX] num2 ... numN'
    
    If the scale option is omitted or set to off '-soff',
    no truncation or rounding of the result is done.
    Example: 'mul 2.340876445 x 1827.74904' = 4278.5346751073628
    
    If scale is set to zero, result is truncated to integer.
    Example: 'mul -s0 2.340876445 x 1827.74904' = 4278
    
    Otherwise, final result is truncated to the given scale.
    Example: 'mul -s4 2.340876445 X 1827.74904' = 4278.5346
    
    Or, use the '-r...' options to round results, using
    one method from: -rhfev , -rhfup , -rceil, -rflor, -rtrnc
    for half-up, half-even, ceiling, floor or truncate.
    
    Example(normal): 'mul -s4 2.340876445 1827.74904' = 4278.5346
    Example: 'mul -s2 -rceil 2.340876445 1827.74904' = 4278.54
    
    If the result is shorter than the given scale, then the
    answer is exact and no rounding or truncation is done.
    Results are only truncated or rounded after the final
    calculation of a series of inputs. Operators are optional.

**div** ---- Division, Remainder and Modulo

    Usage: 'div [-s?] [-r..] num1 ( / % m qr ) num2'
    
    'div' requires an operator: / % m or 'qr'
    Example: 'div -s8 3.52 / 1.4' = 2.51428571
    
    If not given, the default scale value 5 is used:
    Example: 'div 3.52 / 1.4' = 2.51428
    Example: 'div -s0 3.52 / 1.4' = 2
    
    Remainder and Modulo operations:
    div -s8 -3.52 / 1.4 = -2.51428571 {normal division}
    
    '%' returns the shell-and-C-style remainder
    div -s2 -3.52 % 1.4 = -0.72
    
    'm' returns the floored python-style modulo
    div -s2 -3.52 m 1.4 = 0.68
    
    'qr' (divmod) returns quotient and remainder
    div -s2 -3.52 qr 1.4  =  -2.0 -0.72
    
    The '-r...' options perform rounding after full division,
    using one method from: -rhfup, -rhfev, -rceil, -rflor, -rtrnc
    for half-up, half-even, ceiling, floor or truncate.
    div -s20  -2.340876 / 17.749048         = -0.13188741165159956748
    div -s17 -2.340876 / 17.749048          = -0.13188741165159956
    div -s17 -rhfup  -2.340876 / 17.749048  = -0.13188741165159957
    
    If the result is shorter than the given scale, then the
    answer is exact and no rounding or truncation is done.
    No rounding is done during modulo/remainder operations.

**tsst** ---- Numeric Comparison of integer or decimal numbers

    Usage: 'tsst num1 (operator) num2'
    Operators: -lt -le -eq -ge -gt -ne

    'tsst' is used like the shells' 'test' or '[' built-ins
    returning a true/false condition of the comparison.
    Examples as used from the command-line:
    Example: 'tsst 4.22 -lt 6.3 ; echo $?'
    Example: 'tsst 4.22 -lt 6.3 && echo less'
    
    In scripts, 'tsst' can be used in if/while/until structures:
    if tsst 4.22 -lt 6.3 ; then ....
    while tsst 4.22 -lt 6.3 ; do ....

**cmp3w** ---- 3-way Global Comparison of integer or decimal numbers
    
    Usage: 'cmp3w num1 num2'
    
    Relatively compares 2 decimal numbers, returns: '<' '=' or '>'
    Example: 'cmp3w -234.57 -234.55' returns: '<' (to stdout)
    
    'cmp3w' is the back-end for 'tsst' and is also used alone
    by other functions, especially where 3 different actions
    are wanted, for each of the 3 conditions.
    
**round** ---- Rounding of decimal Numbers
    
    Usage: round (method) [-s?] decimal-number
  
    Where 'method' is 'ceil' 'flor' 'hfup' 'hfev' or 'trnc'. 
    That is, ceiling, floor, half-up, half-even or truncation.
    Note that 'method' comes before the '-s?' scale option.
    
    Example: 'round ceil -s0 4.001' returns '5'
    Example: 'round flor -s2 -4.001' returns '-4.01'
    Example: 'round hfup -s2 4.005' returns '4.01'
    Example: 'round hfev -s9 0.9999999985' returns '0.999999998'
    Example: 'round hfev -s9 0.9999999995' returns '1.000000000'
    
    Input must be at least 1 digit longer than requested scale.
    Otherwise, no rounding is done. Integer inputs are
    returned without rounding.
    
    Half-up is the 'normal' most-used method of rounding. 
    Half-even rounding is used in financial calculations.
    Truncation is effectively toward-zero rounding.
    
INTERACTIVE MODE
================

When run using the *-i* option, *iq* will start in Interactive Mode, allowing you to make a series of calculations, before exiting the program.

You can also load any of the extra Modules for more functionality. 

The available Modules are *iq+*, *iq_trig*, *iq_misc*, *iq_util* and *iq_ai*.

ONE-SHOT MODE
=============
*iq* is easy to use from the CLI as a one-shot calcuclator and needs no echo or piping of inputs as with 'bc', 'dc' or 'awk'.
    
    Instead of: echo "scale=5; 2.7182*3.1416" |bc
    iq mul -s5 2.7182 3.1416 

Assigning results to a variable is also easier:
    
    Instead of: a=$(echo "scale=5; 2.7182*3.1416" |bc)
    a=$(iq mul -s5 2.7182 3.1416)
    
ON-LINE MODE
============
To 'source' iq into your shell session with the '.' (dot) builtin:

    src=1 . iq

This makes the *iq* functions available anytime during your shell session,
but they stay in the background when not used.

SCRIPTING
=========
**IQ** was especially designed for heavy use in scripts, so this way of using it provides the most benefits.

    Normally, when a script uses a calculator like 'bc' or 'awk', 
    that program has to be run in a separate process. When many
    calculations are needed, the start-up latency for those adds up.
    
    By sourcing *iq* into your script instead, the latency for loading
    *iq* occurs only once. After that, the functions are available for
    execution in your script. But, since they are shell functions, they
    are run in-line in the main process and do not cause the spawning
    of new processes.

To include *iq* in your shell script, simply 'source' it into your script. 
    
    Just put a line like this near the beginning:
    src=1 . iq
    or:
    src=1 . /path/to/iq
 
Then, any further needed functions or modules can be sourced or copied into your script.

The comments above each function list the dependencies of that function.

A slightly altered version of the Main Functions is contained in the file *math.h.sh*, for easier, more-compact inclusion in scripts. See the
bottom of *math.h.sh* for complete instructions for using it.

AUTHOR
======

Gilbert Ashley <https://github.com/ShellCanToo/iQalc>

SEE ALSO
========

**iq+(1)** **iq_trig(1)** **iq_misc(1)** **iq_util(1)**
