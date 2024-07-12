# Task 2 

Write an assembly program for the i8086 microprocessor that would read two binary numbers from two separate files, perform the bitwise AND operation on these numbers, and write the result as a binary number to a third file. The input binary numbers can be of arbitrary length.

Additional requirements:

1. Procedures should be used to ensure reusability.
1. The user should be able to specify the file names for both input files and output file through argument line when launching the program in a `<input1.txt> <input2.txt> <output.txt>` format.
1. The program should read in blocks of a constant, defined inside the program. The application should alter its behavior if the constant is modified from its default value.
1. On executing console command `/?` a custom help message would be displayed.
1. On success, the user should be prompted for where they should look for the results.
1. If binary numbers are of different lengths, append binary zeros to match the longer length number.