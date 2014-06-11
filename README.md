#Objective-C-mutationtests

##Mutation tests for Objective-C

As I could not find any tool to do mutation tests with Objective-C I came up with this simple solution.
Maybe someone is into testing and would like to help in this little, but useful project to create sustainable software.


##What do you need

Unittests!

You simply need some Unittests in your sourcecode (you do test, do you?). 
Ideally the Testing Code and the affected relative file are following the naming convention:
{sourcefile}.m
{sourcefile}.h
{sourcefile}UnitTest.m


##How it Works
A small script mutates your testing source code. If for example you have an expression like (a==b) it might be exchanged with (a!=b). If your Unittests covers well your code it should now break your Unittest, this is called killing a mutant.
If the unit test dooes not fail you did not cover well this case and should write a testcase where this test is covered.

##Unittest coding convention

Unittests are following a coding convention (I know that it is Objective-C unstylish):
{what} _ {goesIn} _ {expected}


##Example Code

I added some example code for unit tests. It is a simple calculator for calculating your Sunrise and Sunset based on your location and date.




