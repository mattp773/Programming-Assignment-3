# Lab 3: Writing parallel programs using GPU 
## Due 5/8/2022 (by midnight)

  In  this  project,  you  will  write  a  parallel  application using  GPUs.    You  will  still  work  in  groups. 
Your  grade  for  the  project  will  be  based  on  the  code,  your  documentation,  and  your  testing 
results.   You should turn  in a  report  about  your  code,  how  it  works,  and  the  testing  results  with 
screenshots.  Your  code  should  be  included  with  the  report,  and  it  should  be  well  structured  and 
documented code.   You should include tests you used with your code.  Please include all you are 
turning  in  for  the  project as  a  single  tar  or  zip  file  that you upload to Canvas.   (For each group, 
only one member needs to upload.)

  The  goal  of  this  project  is  to  turn  a  sequential  version  of  an  application  into  parallel  version 
running  on GPUs,  and  evaluate its  performance  gains.  You  need  to  first  implement a  sequential 
version  for  your  program,  then  a  parallel  version.  You  should  demonstrate  the  performance 
improvements brought  by  the parallel version of your program.   If you carry out the experiments 
in  the  department  lab,  the  machines there  are equipped  with  Intel  quad-core  CPUs  with  Nvidia 
GeForce CUDA-Capable GPUs.

  Following are  two  tasks that  you  may choose one  to  implement and  test.  For  each program, you 
need to write a serial version of the program, as well as a GPU-enabled parallel version. You will 
then  need  to  test  both  versions  with  proper  input  with  your  choices,  to  demonstrate speedups, if 
any, by using GPUs.

## Task 1
  Your program will add up each group of N consecutive elements of a large array of single 
precision floating point numbers to find which of these groups has the largest sum.  In other words, 
you will consider the sum from array indices 0 to  N-1, compared to 1 to N, 2 to N+1, etc. so that 
each of the  possible subsets is computed, and the largest of each is found and reported. Note that 
here,  N  is  an  input  parameter  provided  by  the  user.  It  is  suggested  that  your  program  should  be 
able  to  handle  both  small  and  large  Ns.  Therefore,  you  may  test  with  N  values  such  as  10,  50, 
100,  or  1000,  etc.  You  should  be  able  to  handle  arrays  that  are  big  (up  to  tens  of  millions  of 
elements).   The  array  elements  will  be  input  from  a  file.  You  will  need  to generate such input 
files,  where each number is  a  floating point number (for simplicity and  testing purposes, you  can 
limit each value to be within (0, 100), for this project).  Your host program will print out the final 
largest sum and the starting index.

## Task  2
  Your  program  will  calculate  the  sum  of  prime  numbers  that  are  less  than  a  certain 
threshold,  N.    In  other  words,  you  will  need  to  find  the  prime  numbers  up  to  N,  and  add  them 
together.  To  find  prime  numbers,  you  may  use  different  ways  for  testing  if  a  number  is  prime, 
e.g., by testing from 2 to the square root of N. Your program will take N as input, and provide the 
sum  as  output.  Note  that  your  program  needs  to  be  tested  with  large  N  values,  such  as  up  to  1 
billion.  In such cases, it is beneficial to use GPU to make the computation to be parallel.
Note  that  none  of  the  code  for  this  project  is  to  be  developed  by  others  (no  finding  other 
resources  or  sharing  code).  Violation  of  this  will  result  in  a  zero  for  the  project  and  potential 
referral to judicial affairs.
