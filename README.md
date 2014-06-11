#Objective-C mutation tests

####still to do:

work is in progress:

- rewrite scripts in ruby and/or python.
- run tests as build within Xcode?
- output results in consistent way


##Mutation tests for Objective-C

As I could not find any tool to do mutation tests with Objective-C I came up with this simple solution.
Maybe someone is into testing and would like to help in this little, but useful project to create sustainable software.

###How it Works

See also: [http://en.wikipedia.org/wiki/Mutation_testing] 

A small script mutates your testing source code. If for example you have an expression like (a==b) it might be exchanged with (a!=b). If your Unit tests covers well your code it should now break your Unittest, this is called killing a mutant.
If the unit test dooes not fail you did not cover well this case and should write a testcase where this test is covered.

##What you need

Unittests!

You simply need some Unittests in your sourcecode (you do test, do you?). 


Ideally the Testing Code and the affected relative file are following the naming convention:

```
{sourcefile}.m
{sourcefile}.h
{sourcefile}UnitTest.m
```

If you do not follow this convention you have to help the mutantgenereator by providing a setupfile: `mutations.json`.



##Unittest coding convention

Unittests are following a coding convention (I know that it is Objective-C unstylish):

```
- (void) {what}_{goesIn}_{expected}()
{
}
```

##Example Code

I added some example code for unit tests. It is a simple calculator for calculating your Sunrise and Sunset based on your location and date.

##Mutations implemented

| LHS     |  RHS       | remark                    |
|:-------:|:----------:|:--------------------------|
| ==      | !=         |                           |
| *       | /          | invariant if rhs equals 1 |
| +       | -          | invariant if rhs equals 0 |
| ++      | --         | you don't use pointer manipulation|
|(e)?(a):(b)|(e)?(b):(a)| ternary op |
 
  





