@echo off

set currentDir="%CD%"
set uploadDir="%CMDER_ROOT%\uploads"

set configArchiveName=Config.7z
set setupScriptsArchiveName=SetupScripts.zip
set gitconfigPath="%HOME%\.gitconfig"
:: Do not put quotes around the folder name here
set uploadFolderInDropbox=Cmder Uploads

:: Remove old uploads folder and recreate
if exist %uploadDir% (
	rmdir /s /q %uploadDir%
)
mkdir %uploadDir%
cd /d %uploadDir%

:: These are the files/folders that will be added to the config archive
:: Use -xr! to ignore files and folders
echo Adding files to "%configArchiveName%", please wait...
:: Add Cmder config folder
7za a %configArchiveName% "%CMDER_ROOT%\config" > nul
set vsCodeIgnoreRoot=personal\vscode\data\user-data
:: Add VSCode folder but exclude some internal folders
7za a %configArchiveName% "%HOME%" -xr!"%vsCodeIgnoreRoot%\Cache*\" -xr!"%vsCodeIgnoreRoot%\logs\" > nul
set conEmuRoot=%CMDER_ROOT%\vendor\conemu-maximus5
:: Add the ConEmu.xml file - this stores all settings
7za a %configArchiveName% "%conEmuRoot%\ConEmu.xml" > nul
:: Add the Consolas-NF.ttf file - this is the font Cmder uses - found here: https://github.com/Znuff/consolas-powerline
7za a %configArchiveName% "%conEmuRoot%\ConEmu\Consolas-NF.ttf" > nul

:: Create a separate archive for the "Setup" scripts
echo Adding files to "%setupScriptsArchiveName%", please wait...
7za a %setupScriptsArchiveName% "%SCRIPTS_DIR%\Setup" > nul

choice /t 5 /d "N" /m "Uploading from a slow connection? Defaults \"N\" in 5 seconds."
:: %ERRRORLEVEL% == 1 is "Y"
if [%ERRORLEVEL%] == [1] (
	copy %gitconfigPath% %uploadDir%
	echo. && echo Take the files in %uploadDir% and manually upload to Dropbox.
	pause

	:: Replace any spaces in the upload folder name with %20 to create the URL
	setlocal enabledelayedexpansion
	set uploadFolderInDropbox=!uploadFolderInDropbox: =%%20!
	start "" "https://www.dropbox.com/home/%uploadFolderInDropbox%"
	explorer %uploadDir%

	goto Finish
)

:: Upload
call :Upload %configArchiveName%
call :Upload %setupScriptsArchiveName%
call :Upload %gitconfigPath%

echo Uploads completed. If any uploads failed, manually upload them to Dropbox.

:Finish
cd /d %currentDir%
exit /b 0

:Upload
pneumatictube -f %1 -p /"%uploadFolderInDropbox%"
exit /b 0