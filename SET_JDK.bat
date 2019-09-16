@echo off
(echo "%PATH%" & echo.) | findstr /O . | more +1 | (set /P RESULT= & call exit /B %%RESULT%%)
set /A STRLENGTH=%ERRORLEVEL%
echo path length = %STRLENGTH%
if %STRLENGTH% GTR 1024  goto byebye 

echo Old JAVA_HOME: %JAVA_HOME%
java -version
echo =================== 
echo Choose a new Java Version:
echo [8] JDK 1.8.0_221
echo [12] JDK 12.0.2
echo [x] Exit
echo =================== 

:: Add or remove user choices below if you are adding diffrent versions of java. 

:choice
SET /P C=[8,12,x]? 
for %%? in (8) do if /I "%C%"=="%%?" goto JDK_L8 
for %%? in (12) do if /I "%C%"=="%%?" goto JDK_L12
for %%? in (x) do if /I "%C%"=="%%?" goto byebye

goto choice

:JDK_L8   
set JAVA_HOME = "C:\Program Files\Java\jdk1.8.0_221"
setx /m JAVA_HOME "C:\Program Files\Java\jdk1.8.0_221"
goto byebye

:JDK_L12  
set JAVA_HOME = "C:\Program Files\Java\jdk-12.0.2"
setx /m JAVA_HOME "C:\Program Files\Java\jdk-12.0.2"
goto byebye

:byebye

:: Please do not touch anything below this line as it can cause serious harm to your computer
:: +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


echo | set /p dummy="Reading environment variables from registry. Please wait... "

goto main

:: Set one environment variable from registry key
:SetFromReg
    "%WinDir%\System32\Reg" QUERY "%~1" /v "%~2" > "%TEMP%\_envset.tmp" 2>NUL
    for /f "usebackq skip=2 tokens=2,*" %%A IN ("%TEMP%\_envset.tmp") do (
        echo/set %~3=%%B
    )
    goto :EOF

:: Get a list of environment variables from registry
:GetRegEnv
    "%WinDir%\System32\Reg" QUERY "%~1" > "%TEMP%\_envget.tmp"
    for /f "usebackq skip=2" %%A IN ("%TEMP%\_envget.tmp") do (
        if /I not "%%~A"=="Path" (
            call :SetFromReg "%~1" "%%~A" "%%~A"
        )
    )
    goto :EOF

:main
    echo/@echo off >"%TEMP%\_env.cmd"

    :: Slowly generating final file
    call :GetRegEnv "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" >> "%TEMP%\_env.cmd"
    call :GetRegEnv "HKCU\Environment">>"%TEMP%\_env.cmd" >> "%TEMP%\_env.cmd"

    :: Special handling for PATH - mix both User and System
    call :SetFromReg "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" Path Path_HKLM >> "%TEMP%\_env.cmd"
    call :SetFromReg "HKCU\Environment" Path Path_HKCU >> "%TEMP%\_env.cmd"

    :: Caution: do not insert space-chars before >> redirection sign
    echo/set Path=%%Path_HKLM%%;%%Path_HKCU%% >> "%TEMP%\_env.cmd"

    :: Cleanup
    del /f /q "%TEMP%\_envset.tmp" 2>nul
    del /f /q "%TEMP%\_envget.tmp" 2>nul

    :: Set these variables
    call "%TEMP%\_env.cmd"

    echo | set /p dummy="Done"
     
echo.
java -version
pause


