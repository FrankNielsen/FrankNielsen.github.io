REM javac *.java
REM appletviewer   boxstabbing.html
REM javac StabbingPiercingBoxes.java
REM javac -Xlint:deprecation -Xlint:unchecked StabbingPiercingBoxes.java
javac -source 1.4  -Xlint:deprecation -Xlint:unchecked StabbingPiercingBoxes.java  2>errorcompilation.txt
appletviewer  run.html
pause 3000
