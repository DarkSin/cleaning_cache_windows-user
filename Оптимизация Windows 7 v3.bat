REM Last-ик ActivityView. Версия 1 Alpha - адаптировано для Windows 7

@ECHO OFF

REM Надеюсь, сохранить файл в кодировке DOS-866 не забыли
CHCP 866

REM Зеленый на черном - интригующе... опять же, хакеры и все такое
COLOR A

CLS


REM ----------------------------------------------------------------------------------------
REM Проверка на наличие прав администратора 
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
	IF (%adminTest%)==(Отказано) GOTO errNoAdmin
	IF (%adminTest%)==(Access) GOTO errNoAdmin
REM ----------------------------------------------------------------------------------------


REM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

REM При выборе пункта 1 ничего особо плохого произойти, для пользователя, не должно.
REM Но будут удалены сохраненные данные о размерах окон папок в проводнике и настройки их вида (список\эскизы и т.д.)

REM При выборе п.п. 2-3
REM 1. При первой перезагрузке чуть-чуть замедлится запуск Windows т.е. первый, после нее, запуск некоторых программ (в т.ч. в автозагрузке)
REM    из-за удаления файлов оптимизации запуска Prefetch и SuperFetch
REM 2. Будет удалена информация о запуске программ в режиме совместимости или о запуске от имени администратора
REM    но это - если пользователь такое назначал для чего-то и восстанавливается назначением этого заново
REM    или найдите и уберите из скрипта удаление данных из ...AppCompatFlags\Layers
REM 3. Будет удалена накопленная до этого момента информация о производительности и ошибках
REM    но, если в текущий момент с компом все нормально и его не надо "анализировать и чинить", то тоже ничего страшного

REM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

REM ----------------------------------------------------------------------------------------
REM Меню выбора пользователя

ECHO.
ECHO Не обязательно!
ECHO но желательно закрыть все программы и данный файл, если он открыт в текстовом редакторе, а после завершения - перезагрузиться
ECHO.
ECHO.

REM Часть информации останется, и будет таки отображаться в утилитах NirSoft
ECHO 1 - Очистка основных логов в реестре

REM Удалить все, что удалось найти. 
REM (почти вся информация из утилит NirSoft пропадет)
REM При этом:
REM 1. Немного замедлится следующая загрузка ПК и первый, после нее, запуск некоторых программ (из-за удаления Perfect и SuperFetch)
REM 2. Удалятся сведения о ранее возникших ошибках (Minidump)
REM 3. В меню "Пуск" очистится список ранее запущенных программ
REM 4. Будет очищен список тех программ, для которых пользователь задал "запускать в режиме совместимости или от имени администратора". 
REM	  (надо будет задавать для них совместимость заново)
ECHO 2 - Очистка всех логов в реестре, файлов Perfect и Minidump

REM См. п.2 + сотрутся ранее записанные данные журналов Windows
ECHO 3 - Очистка всех логов, файлов Perfect и журналов Windows

REM п.3 + Thumbnail cache удаляется гарантированно при следующей загрузке (PendingFileRenameOperations)
ECHO 4 - То же что п.3 + гарантированная очистка Thumbnail cache (требует перезагрузки)

ECHO или нажмите ENTER для выхода
ECHO.
SET /p doset="Выберите действие: " 
ECHO.
REM ----------------------------------------------------------------------------------------


REM ----------------------------------------------------------------------------------------
REM Проверка выбора пользователя. Если не 1 и не 2 и не 3 - выход
IF %doset% NEQ 1 (
	IF %doset% NEQ 2 (
		IF %doset% NEQ 3 (
			IF %doset% NEQ 4 EXIT
		)
	)
)
REM ----------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM Очистка всех журналов Windows, если пользователь выбрал в меню 3. Проводим вначале, чтоб в логах не осталось вызовов wevtutil
REM утилиты NirSoft - LastActivityView
IF %doset% GEQ 3 (
	ECHO.
	ECHO ОЧИСТКА ВСЕХ ЖУРНАЛОВ Windows
	FOR /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
	ECHO.
	ECHO Выполнено
	ECHO.
)
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM ShellBag. История запуска приложений и доступа к папкам, связанная с "оболочкой"
REM утилиты NirSoft - LastActivityView, ExecutedProgramsList, ShellBagsView
ECHO.
ECHO ОЧИСТКА ИСТОРИИ ShellBag - реестр
REG DELETE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /va /f
REG DELETE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f
REG DELETE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BagMRU" /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags" /f
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM Explorer. История запуска приложений связанная с "Проводником"
ECHO.
ECHO ОЧИСТКА ИСТОРИИ Explorer - реестр
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM RecentDocs. MRU последних документов в реестре - отдельно от папки Recent в ФС
REM утилиты NirSoft - RecentFilesView
ECHO.
ECHO ОЧИСТКА ИСТОРИИ RecentDocs - реестр
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" /va /f
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM TypedPaths. История ручного ввода пути в адресной строке Проводника
ECHO.
ECHO ОЧИСТКА ИСТОРИИ TypedPaths - реестр
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" /va /f
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM ComDlg32. История диалогов "открыть\сохранить" и "последних мест посещений"
REM утилиты NirSoft - LastActivityView
ECHO.
ECHO ОЧИСТКА ИСТОРИИ OpenSave и LastVisited - реестр
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\FirstFolder" /va /f >NUL 2>NUL
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /va /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRULegacy" /va /f >NUL 2>NUL
REM (утилиты NirSoft - OpenSaveFilesView)
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU"
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM если пользователь выбрал в меню не 1 т.е. 2 или 3
IF %doset% NEQ 1 (	
	REM UserAssist. Очистка списока запущенных программ в меню "Пуск"
	REM утилиты NirSoft - UserAssistView
	ECHO.	
	ECHO ОЧИСТКА ИСТОРИИ UserAssist - реестр
	REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f
	REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
	ECHO.
)


REM ------------------------------------------------------------------------------------------
REM AppCompatCache
ECHO.
ECHO ОЧИСТКА ИСТОРИИ AppCompatCache - реестр
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" /va /f
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\AppCompatCache" /va /f
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM DiagnosedApplications. Диагностика утечек памяти в приложении ОС Windows
ECHO.
ECHO ОЧИСТКА ИСТОРИИ DiagnosedApplications - реестр
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RADAR\HeapLeakDetection\DiagnosedApplications" /f >NUL 2>NUL
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RADAR\HeapLeakDetection\DiagnosedApplications" >NUL 2>NUL
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM Получение SID - идентификатор безопасности текущего пользователя 
FOR /F "tokens=2" %%i IN ('whoami /user /fo table /nh') DO SET usersid=%%i
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM Search. История поиска 
ECHO.
ECHO ОЧИСТКА ИСТОРИИ Search - реестр
	REG DELETE "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f >NUL 2>NUL
	REG ADD "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" 2>NUL
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM BAM. 
REM По идее, при перезагрузке затрется само.  
REM Но можно сделать отдельный bat и запускать, например, после работы с portable-приложениями
ECHO BAM - отсутствует в Windows 7, секция пропущена
REM BAM (Background Activity Moderator) отсутствует в Windows 7 - пропускаем
REM REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\bam\UserSettings\%usersid%" /va /f
REM REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\bam\UserSettings\%usersid%" /va /f
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM AppCompatFlags
ECHO.
ECHO ОЧИСТКА ИСТОРИИ AppCompatFlags - реестр
REM утилиты NirSoft - ExecutedProgramsList
REG DELETE "HKEY_USERS\%usersid%\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Persisted" /va /f

REM если пользователь выбрал в меню не 1 т.е. 2 или 3
IF %doset% NEQ 1 (
	REM Список программ, для которых задан "режим совместимости" или "запускать от имен администратора"
	REM утилиты NirSoft - AppCompatibilityView
	REG DELETE  "HKEY_USERS\%usersid%\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /va /f
)
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM История "монтирования" дисков в т.ч. и TrueCrypt
ECHO.
ECHO ОЧИСТКА ИСТОРИИ MountedDevices - реестр
ECHO.
REG DELETE "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" /f
REG ADD "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
REM Очистка списков быстрого перехода
ECHO.
REM утилиты NirSoft - JumpListsView, RecentFilesView
ECHO ОЧИСТКА ИСТОРИИ Recent - файловая система
DEL /f /q %APPDATA%\Microsoft\Windows\Recent\*.*
DEL /f /q %APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*.*
DEL /f /q %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.*
ECHO Выполнено
ECHO.
REM ------------------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------------------
ECHO.
ECHO ОЧИСТКА КЭША Thumbnail cache - файловая система
REM Файлы заблокированы Проводником - требуется перезапуск Explorer
taskkill /f /im explorer.exe >NUL 2>&1
ping localhost -n 2 >NUL
DEL /f /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>NUL
start explorer.exe
ECHO Выполнено
ECHO.
REM ------------------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------------------
REM Отложенная очистка Thumbnail cache - только при выборе пункта 4
IF %doset% NEQ 4 GOTO skip_pending_thumb
SET _TCDIR=%LOCALAPPDATA%\Microsoft\Windows\Explorer
ECHO.
ECHO РЕГИСТРАЦИЯ Thumbnail cache для удаления при следующей загрузке - реестр
powershell -NoProfile -Command "$r='HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'; $ex=(Get-ItemProperty $r -Name PendingFileRenameOperations -EA SilentlyContinue).PendingFileRenameOperations; if(-not $ex){$ex=@()}; $n=@(); Get-ChildItem ""$env:_TCDIR\thumbcache_*.db"" -EA SilentlyContinue | ForEach-Object {$n+='\??\'+ $_.FullName; $n+=''}; if($n.Count -gt 0){Set-ItemProperty $r PendingFileRenameOperations ($ex+$n) -Type MultiString; Write-Host ('Зарегистрировано файлов: '+($n.Count/2))} else {Write-Host 'Файлы thumbcache не найдены (удалены при немедленной очистке)'}"
ECHO.
:skip_pending_thumb
REM ------------------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------------------
ECHO.
ECHO ОЧИСТКА ИСТОРИИ Panther - файловая система
DEL /f /q %systemroot%\Panther\*.*
ECHO Выполнено
ECHO.
REM ------------------------------------------------------------------------------------------

REM ------------------------------------------------------------------------------------------
ECHO.
ECHO ОЧИСТКА ИСТОРИИ AppCompat - файловая система
DEL /f /q %systemroot%\appcompat\Programs\*.txt
DEL /f /q %systemroot%\appcompat\Programs\*.xml
DEL /f /q %systemroot%\appcompat\Programs\Install\*.txt
DEL /f /q %systemroot%\appcompat\Programs\Install\*.xml
ECHO Выполнено
ECHO.
REM ----


REM ------------------------------------------------------------------------------------------
ECHO.
ECHO ОЧИСТКА ВРЕМЕННЫХ ФАЙЛОВ - %TEMP%
DEL /f /s /q "%TEMP%\*" 2>NUL
FOR /D %%p IN ("%TEMP%\*") DO RD /s /q "%%p" 2>NUL
ECHO Выполнено
ECHO.
REM ------------------------------------------------------------------------------------------


REM ------------------------------------------------------------------------------------------
IF %doset% NEQ 1 (
	ECHO.
	REM Prefetch. Удаление файлов, оптимизирующих запуск приложений. Windows в следующий раз загрузится медленнее
	REM утилиты NirSoft - LastActivityView, ExecutedProgramsList
	ECHO ОЧИСТКА ИСТОРИИ Prefetch - файловая система
	DEL /f /q %systemroot%\Prefetch\*.pf
	DEL /f /q %systemroot%\Prefetch\*.ini
	DEL /f /q %systemroot%\Prefetch\*.7db
	DEL /f /q %systemroot%\Prefetch\*.ebd
	DEL /f /q %systemroot%\Prefetch\*.bin
	REM SuperFetch. Удаление баз оптимизации SuperFetch
	DEL /f /q %systemroot%\Prefetch\*.db
	REM Trace. Удаление файлов трассировки
	DEL /f /q %systemroot%\Prefetch\ReadyBoot\*.fx
	ECHO Выполнено
	ECHO.

	ECHO.
	ECHO ОЧИСТКА ИСТОРИИ Minidump - файловая система
	REM Удаление дампов ошибок
	REM утилиты NirSoft - LastActivityView
	DEL /f /q %systemroot%\Minidump\*.*
	ECHO Выполнено
)
ECHO.
REM ------------------------------------------------------------------------------------------


IF %doset% NEQ 4 GOTO skip_reboot_warn
COLOR 4F
ECHO.
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO ВНИМАНИЕ: Зарегистрирована отложенная очистка Thumbnail cache.
ECHO Для завершения очистки ПЕРЕЗАГРУЗИТЕ компьютер!
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO.
:skip_reboot_warn
PAUSE
EXIT

:do_clear
ECHO Очистка журнала %1
wevtutil.exe cl %1
GOTO :eof

:errNoAdmin
COLOR 4
ECHO Необходимо запустить этот скрипт от имени администратора
ECHO.
PAUSE