@echo off

set currentDir="%CD%"
set uploadDir="%CMDER_ROOT%\uploads"
 
set configArchiveName=Config.7z
set setupScriptsArchiveName=SetupScripts.zip
set gitconfigPath="%HOME%\.gitconfig"
:: Do not put quotes around the folder name here
set uploadFolderInDropbox=Cmder Uploads

:: Remove old uploads folder and recreate
rmdir /q /s %uploadDir%
mkdir %uploadDir%
cd /d %uploadDir%

:: These are the files/folders that will be added to the config archive
:: Use -xr! to ignore files and folders
7za a %configArchiveName% "%CMDER_ROOT%\config"
7za a %configArchiveName% "%HOME%" -xr!"personal\vscode\Data\code\Cache*\"
7za a %configArchiveName% "%CMDER_ROOT%\vendor\conemu-maximus5\ConEmu.xml"

:: Create a separate archive for the "Setup" batch scripts
7za a %setupScriptsArchiveName% "%HOME%\batch scripts\Setup"

set /p slowConnection=Are you uploading from a slow connection? (y/n) 
if [%slowConnection%] == [y] (
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

echo. && echo Upload(s) completed.

:Finish
cd /d %currentDir%
exit /b 0

:Upload
pneumatictube -f %1 -p /"%uploadFolderInDropbox%"
exit /b 0