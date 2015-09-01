rem TODO: Create another batch that use Registry to setx permanent JDK path
rem STARTING UP
cls
@echo off
title Java Commandline Compiler
echo Java Commandline Compiler [Version 1.0] - by FusDev & echo.

rem CHECKING FOR JAVA JDK
if not exist "%programfiles%\Java\" (
	echo ERROR: No trace of Java instances found.
	exit /b 1
)

setlocal EnableDelayedExpansion

set c=0
for /f "tokens=*" %%f in ('dir "%programfiles%\Java\jdk*" /ad /b') do (
	set /a c=!c!+1
	set jdks[!c!]=%%f
)

if not %c% gtr 0 (
	echo ERROR: No instance of JDK found.
	exit /b 1
)

echo ---------------------------------
echo Found %c% instance(s) of JDK:
for /l %%i in (1, 1, !c!) do (
	echo %%i. !jdks[%%i]!
)
echo ---------------------------------

rem CHOOSING AND INITIALIZING JDK
if %c% equ 1 (
	echo Automatically chose the only JDK as default. & echo.
) else (
	rem TODO: Allow user to opt for JDK
	echo JDK opting is not a feature right now. Automatically chose the first JDK as default. & echo.
)

call :chooseJDK

rem TEST JAVAC FOR THE LAST TIME
javac -version >nul 2>&1 && (
    echo Done initializing.
) || (
    echo ERROR: Cannot run javac command. Make sure there is a javac.exe in your jdk's bin folder.
	exit /b 1
)

rem COMPILING FILE
rem TODO: Put the input to a new line
rem TODO: Clear %input% and check the input
:compiling
set /p input=Drop your goodies in here ^& press [Enter] to proceed: 
set input=%input:"=%

call :isFilePath "%input%"
if %errorlevel% equ 1 (
	rem TODO: Check if the path is valid
	rem TODO: Add flags to check for errors (no file found, fail to compile)
	for /f "tokens=*" %%f in ('dir "%input%\*.java" /b ^2^>NUL') do (
		echo Found %%f
		javac "%input%\%%f" && (
			echo Successfully compiling.
		) || (
			echo ERROR: Fail to compile file %%f
		)
	)
	echo Done compiling process. & echo.
	goto :compiling
) else (
	call :getFileExt "%input%"
	if "!tmpext!"==".java" (
		javac "%input%" && (
			echo Successfully compiling. Attempting to run .class file...
		) || (
			echo Fail to compile file.
			rem TODO: Go to somewhere
		)
		goto :run
	)
	if not "!tmpext!"==".class" (
		echo  Only accept folder path, .java file, .class file. & echo.
		goto :compiling
	)
)

:run
call :getParentFolder "%input%"
cd /d %tmpath%
call :getFileName "%input%"
java "%tmpname%"

pause
exit /b 0

:chooseJDK
set path=%path%;%programfiles%\Java\!jdks[1]!\bin\
if %errorlevel% equ 0 (
	call :checkJDKs
) else (
	echo Fail to set temporary path for %programfiles%\Java\!jdks[1]!. & echo.
	rem TODO: checkJDKs
	exit /b 1
)
rem TODO: Add option to check if user want this indefinately
goto :eof

:checkJDKs
javac -version >nul 2>&1 || (
	echo ERROR: Cannot run javac command. Make sure there is a javac.exe in your jdk's bin folder.
	exit /b 1
)
goto :eof

:getParentFolder
set tmpath=%~dp1
goto :eof

:getFileName
set tmpname=%~n1
goto :eof

:getFileExt
set tmpext=%~x1
goto :eof

:isFilePath
set fext=%~x1
if not defined fext (
	set errorlevel=1
) else (
	set errorlevel=0
)
goto :eof

endlocal
