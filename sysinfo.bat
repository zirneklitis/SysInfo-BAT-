:: This batch file reveals OS, hardware, and networking configuration.
:: Savāc un parāda ziņas par datoru
@ECHO OFF
chcp 65001 > nul
SET Versija=0.1.0-2023.04.21
:: Licence: GPL3
:: Atsauksmēm, ieteikumiem un labojumie: karlo@latnet.lv

SETLOCAL EnableDelayedExpansion
SETLOCAL EnableExtensions
REM https://www.codeproject.com/articles/17033/add-colors-to-batch-files
IF EXIST "%~dp0\cecho.exe" (
	SET PARASTS=cecho {0F}
	SET PAZINJO=cecho {4E}
	SET SADALJA=cecho {1E}
)
SET "Atdala=	"

:: Noskaidro, kāda ir profila valoda.
FOR /F "tokens=3" %%a IN (
	'reg query "HKCU\Control Panel\Desktop" /v PreferredUILanguages ^| find "PreferredUILanguages"'
) DO set Valoda=%%a
SET Valoda=!Valoda: =!
IF "%Valoda%" == "lv-LV" (
	TITLE Ziņas par datoru
) ELSE (
	TITLE System Info
)

:: Komandrindas parametru apstrāde.
SET Datne=
SET Drukaat=
SET Drukaat2=
SET Kursh=
SET NeGaidi=
FOR %%I IN (%*) DO (
	SET /a Kursh=!Kursh!+1
	IF /I ["%%~I"]==["-h"] (
		GOTO PALIGS
	)
	IF /I ["%%~I"]==["--help"] (
		GOTO PALIGS
	)
	IF /I ["%%~I"]==["-p"] (
		SET Drukaat=!Kursh!
		SET /a Drukaat2=!Drukaat!+1
	)
	IF !Drukaat2! == !Kursh! (
		SET Datne=%%~I
	)
	IF /I ["%%~I"]==["-y"] (
		SET NeGaidi=1
	)
)
IF NOT "!Drukaat!" == "" (
	IF "!Datne!" == "" (
		GOTO PALIGS
	)
	%PAZINJO%
    CALL :RakstaR "Data will be added to the file", "lv-LV", "Ziņas pievienošu datnei"
	ECHO  «!Datne!».
	%PARASTS%
	ECHO.
	SET Galva=DATE_TIME%Atdala%ComputerName
	SET Drukaat=%DATE% %TIME%%Atdala%%ComputerName%
)





:: Ko zinu par šo datoru.
ECHO *
%PAZINJO%
CALL :Raksta "* Please wait... Checking system information.", "lv-LV", "* Esi pacietīgs... Iegūstu ziņas."
%PARASTS%
ECHO *
ECHO.
CALL :RakstaR "User", "lv-LV", "Lietotājs"
ECHO : %USERNAME%
ECHO.

REM ################################################################################
::  #                                                                              #
::  #                                                                              #


:: Par OS.
%SADALJA%
ECHO ·······························································
CALL :Raksta "· Please wait... Checking system information.                 ·", "lv-LV", "· Operētājsistēma                                             ·"
ECHO ·······························································
%PARASTS%
ECHO.

CALL :NoWMIC Apraksts, "path win32_operatingsystem", "description", "P"
CALL :NoWMIC Versija, "path win32_operatingsystem", "Version", "P"
CALL :NoWMIC OSVaards, "path win32_operatingsystem", "Caption", "P"
CALL :NoWMIC Biti, "path win32_operatingsystem", "OSArchitecture", "P"
CALL :NoWMIC Saakneets, "path win32_operatingsystem", "LastBootUpTime", "N"
SET Saakneets=!Saakneets: =!
SET Gads=!Saakneets:~0,4!
SET Meenesis=!Saakneets:~4,2!
SET Diena=!Saakneets:~6,2!
SET Stunda=!Saakneets:~8,2!
SET Minuute=!Saakneets:~10,2!

CALL :RakstaR "·   Computer name:        ", "lv-LV", "·   Datora vārds:         "
ECHO %ComputerName%
CALL :RakstaR "·   Description:          ", "lv-LV", "·   Datora apraksts:      "
ECHO %Apraksts%
CALL :RakstaR "·   OS:                   ", "lv-LV", "·   Operērētāsistēma:     "
ECHO %OSVaards%
CALL :RakstaR "·   OS Version:           ", "lv-LV", "·   OS versija:           "
ECHO %Versija%
CALL :RakstaR "·   OS Architecture:      ", "lv-LV", "·   OS arhitektūra:       "
ECHO %Biti%
CALL :RakstaR "·   Last Boot UpTime:     ", "lv-LV", "·   Ieslēgts kopš:        "
ECHO %Gads%.%Meenesis%.%Diena% %Stunda%:%Minuute%
CALL :RakstaR "·   User home folder:     ", "lv-LV", "·   Lietotāja mājvieta:   "
ECHO %USERPROFILE%
CALL :RakstaR "·   System Folder:        ", "lv-LV", "·   Sistēmas vieta:       "
ECHO %WINDIR%
ECHO.

:: Dzelži.
%SADALJA%
ECHO ·······························································
CALL :Raksta "· HARDWARE INFO                                               ·", "lv-LV", "· Kas lācītim vēderā.                                         ·"
ECHO ·······························································
%PARASTS%
ECHO.

CALL :NoWMIC Razhotaajs, "computersystem", "Manufacturer", "P"
CALL :NoWMIC Modelis, "computersystem", "Model", "P"
CALL :NoWMIC Dators, "computersystem", "SystemFamily", "P"
CALL :NoWMIC TAG, "bios", "SerialNumber", "P"
CALL :NoWMIC CPU, "cpu", "name", "P"
CALL :NoWMIC RAM, "computersystem", "TotalPhysicalMemory", "P"
:: Atmiņas izmērs pārsniedz 32-bitus (SET /A ierobežojums).
:: Vispirms jāizmet tukšumi, tad var nogriezt ciparus no beigām.
SET RAM=!RAM: =!
SET RAM=!RAM:~0,-6!
CALL :NoWMIC RAMbriivs, " path win32_operatingsystem", "FreePhysicalMemory", "N"
SET RAMbriivs=!RAMbriivs: =!
SET RAMbriivs=!RAMbriivs:~0,-3!
CALL :NoWMIC_where DisksSisteemaiBriivs, "logicaldisk" , "Name like '%%SYSTEMDRIVE%%'", "FreeSpace", "N"
SET DisksSisteemaiBriivs=!DisksSisteemaiBriivs: =!
SET DisksSisteemaiBriivs=!DisksSisteemaiBriivs:~0,-6!
CALL :NoWMIC_where DisksDatiemBriivs, "logicaldisk" , "Name like '%%HOMEDRIVE%%'", "FreeSpace", "N"
SET DisksDatiemBriivs=!DisksDatiemBriivs: =!
SET DisksDatiemBriivs=!DisksDatiemBriivs:~0,-6!


CALL :RakstaR "·   Computer:             ", "lv-LV", "·   Dators:               "
ECHO %Razhotaajs% %Modelis% %Dators%
CALL :RakstaR "·   S/N:                  ", "lv-LV", "·   S/N:                  "
ECHO %TAG%
CALL :RakstaR "·   Processor:            ", "lv-LV", "·   Procesors:            "
ECHO %CPU%
CALL :RakstaR "·   RAM:                  ", "lv-LV", "·   Atmiņa:               "
ECHO %RAM% Mb
CALL :RakstaR "·   Free RAM:             ", "lv-LV", "·   Brīva atmiņa:         "
ECHO %RAMbriivs% Mb
CALL :RakstaR "·   Free SystemSpace:     ", "lv-LV", "·   Brīva vieta sistēmai: "
ECHO %DisksSisteemaiBriivs% Mb
CALL :RakstaR "·   Free UserSpace:       ", "lv-LV", "·   Brīva vieta datiem:   "
ECHO %DisksDatiemBriivs% Mb
ECHO.

:: Nosaka datorā esošos diskus.
CALL :NoWMIC_multi VisiDiski, "diskdrive", ^
	"MediaType like 'Fixed%%%%'", ^
	"DeviceID", ^
	"diskdrive", ^
	"Model Size", ^
	"P"

:: Tīkla lietas.
%SADALJA%
ECHO ·······························································
CALL :Raksta "· NETWORK INFO                                                ·", "lv-LV", "· Tīkls                                                       ·"
ECHO ·······························································
%PARASTS%
ECHO.

:: Nosaka strādāošo tīkla karti, bet ne VirtullBox un Windows radītās
CALL :NoWMIC_multi VisiTiikli, "nic", ^
	"netconnectionid like '%%%%' AND NOT Manufacturer like 'Oracle Corporation' AND NOT Manufacturer like 'Microsoft'", ^
	"MACAddress", ^
	"path win32_networkadapterconfiguration", ^
	"Description IPAddress MACAddress", ^
	"P"


::  #                                                                              #
::  #                                                                              #
REM ################################################################################

ECHO ·······························································
ECHO *

:: Ieraksta datnē.
IF NOT "%Datne%" == "" (
	IF NOT EXIST "%Datne%" ECHO %Galva% > "%Datne%"
	ECHO !Drukaat! >> "%Datne%"
	%SADALJA%
	CALL :Raksta "* The file «%Datne%» was updated.", "lv-LV", "* Datne «%Datne%» tika papildināta."
	%PARASTS%
)
 

ECHO *
IF "%NeGaidi%" == "" (
	%PAZINJO%
	CALL :Raksta "* Hit Any Key to close this Window... ", "lv-LV", "* Kad esi izlasījis, uzklikšķini uz atstarpes... "
	%PARASTS%
	ECHO *
	PAUSE > nul
)

EXIT /B %ERRORLEVEL%

REM ################################################################################
REM ##########################    BEIGAS         ###################################
REM ################################################################################

:: Kad pieejams tikai viens ieraksts.
:NoWMIC
	SET numursM=1
	FOR /F "tokens=* USEBACKQ" %%M IN (`wmic %~2 get %~3`) DO (
		SET "var!numursM!=%%M"
		SET /a numursM=!numursM!+1
	)
	SET "%~1=%var2%"
	IF "%~4" == "P" (
		SET "Drukaat=%Drukaat%%Atdala%%var2%"
		SET "Galva=%Galva%%Atdala%%~3"
	)
	EXIT /B 0

:: Kad jāatlasa viens ieraksts.
:NoWMIC_where
	SET numursW=1
	FOR /F "tokens=* USEBACKQ" %%W IN (`wmic %~2 where "%~3" get %~4`) DO (
		SET "var!numursW!=%%W"
		SET /a numursW=!numursW!+1
	)
	SET "%~1=%var2%"
	IF "%~5" == "P" (
		SET "Drukaat=%Drukaat%%Atdala%%var2%"
		SET "Galva=%Galva%%Atdala%%~4"
	)
	EXIT /B 0

:: Kad jāatlasa vairāki ieraksti.
:NoWMIC_multi
	SET "TEMP_visi=§"
	FOR /F "tokens=* USEBACKQ skip=1" %%M IN (`wmic %~2 where "%~3" get %~4`) DO (
		SET "PAZIIME=%%M"
		SET "PAZIIME=!PAZIIME: =!"
		SET "PAZIIME=!PAZIIME:\=\\!"
		IF NOT "!PAZIIME:~1,3!" == "" (
			FOR %%L IN (%~6) DO (
				CALL :NoWMIC_where, Atrasts, "%~5", "%~4 like '!PAZIIME!'", "%%L"
				ECHO %~2 :: %%L :: !Atrasts!
				SET "TEMP_visi=!TEMP_visi!¦!Atrasts!"
			)
			ECHO.
			SET "TEMP_visi=!TEMP_visi!×"
		)
	)
	SET "TEMP_visi=%TEMP_visi%§"
	SET "%~1=%TEMP_visi%"
	IF "%~7" == "P" (
		SET "Drukaat=%Drukaat%%Atdala%%TEMP_visi%"
		SET "Galva=%Galva%%Atdala%%~2"
	)
	EXIT /B 0

:: Izdrukā tekstu vadoties no vides valodas.
:Raksta
	IF "%~2" == "%Valoda%" (
		ECHO %~3
	) ELSE (
		ECHO %~1
	)
	EXIT /B 0

:: Izdrukā tekstu vadoties no vides valodas.
:: Nepāriet uz jaunu rindiņu.
:RakstaR
	IF "%~2" == "%Valoda%" (
		<NUL SET /P=%~3
	) ELSE (
		<NUL SET /P=%~1
	)
	EXIT /B 0

:PALIGS
	%PAZINJO%
	CALL :RakstaR "This batch file reveals OS, hardware, and networking configuration.", "lv-LV", "Savāc ziņas par datoru"
	ECHO ; %Versija%
	%SADALJA%
	ECHO.
	CALL :Raksta "Usage:", "lv-LV", "Lietošana:"
	CALL :Raksta "%~0 [-h] [-p file] [-y]", "lv-LV", "%~0 [-h] [-p datne] [-y]"
	ECHO.
	<NUL SET /P=»       -h         -
	CALL :Raksta " This help message.", "lv-LV", " Šis redzamais lietošanas paskaidrojuma teksts."
	<NUL SET /P=»       -p
	CALL :Raksta " file    - Append to the text file.", "lv-LV", " datne   - Pievieno teksta datnei."
	<NUL SET /P=»       -y         -
	CALL :Raksta " Don't wait at the end.", "lv-LV", " Programma pati beidz darbu."
	%PARASTS%
	EXIT /B
