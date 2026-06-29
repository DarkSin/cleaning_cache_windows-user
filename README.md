# Очистка следов активности Windows
> Windows Activity Cleaner — batch scripts for removing user activity artifacts

Batch-скрипты для очистки истории и следов активности пользователя в **Windows 7** и **Windows 10/11**.  
Удаляют артефакты, отображаемые утилитами NirSoft: LastActivityView, RecentFilesView, ExecutedProgramsList, ShellBagsView и др.

---

## Файлы

| Файл | ОС |
|------|----|
| `bat/Оптимизация Windows 10 v3.bat` | Windows 10 / 11 |
| `bat/Оптимизация Windows 7 v3.bat` | Windows 7 SP1+ |
| `bat/Оптимизация Windows.txt` | Оригинальная v1 (архив) |

---

## Требования

- Запуск **от имени администратора**
- Windows 7 SP1+ / Windows 10 / 11
- PowerShell 2.0+ (для пункта 4 — встроен в Windows 7 и новее)

---

## Использование

1. Запустите нужный `.bat` файл → **правой кнопкой мыши → «Запуск от имени администратора»**
2. Выберите пункт меню `1`–`4` или нажмите `Enter` для выхода
3. Дождитесь завершения
4. **Перезагрузите компьютер**

---

## Уровни очистки

| Пункт | Что очищает |
|-------|-------------|
| **1** | Основные ключи реестра |
| **2** | Пункт 1 + Prefetch, SuperFetch, Minidump |
| **3** | Пункт 2 + все журналы событий Windows |
| **4** | Пункт 3 + гарантированное удаление Thumbnail cache при следующей загрузке ¹ |

> ¹ Пункт 4 регистрирует файлы `thumbcache_*.db` в `PendingFileRenameOperations` — `smss.exe` удаляет их на ранней стадии загрузки до старта Explorer, что гарантирует результат даже для заблокированных файлов. После выполнения **обязательна перезагрузка**.

---

## Что очищается

### Реестр
| Ключ | Описание | Пункты |
|------|----------|--------|
| `Shell\MuiCache`, `BagMRU`, `Bags` | ShellBag — история папок и приложений | 1–4 |
| `Explorer\RunMRU` | Диалог «Выполнить» | 1–4 |
| `Explorer\RecentDocs` | MRU последних документов | 1–4 |
| `Explorer\TypedPaths` | История адресной строки Проводника | 1–4 |
| `ComDlg32\OpenSavePidlMRU` | Диалоги открытия/сохранения файлов | 1–4 |
| `ComDlg32\LastVisitedPidlMRU` | Последние посещённые папки | 1–4 |
| `Explorer\UserAssist` | Список запущенных программ в меню «Пуск» | 2–4 |
| `AppCompatCache` | Кэш совместимости приложений | 1–4 |
| `RADAR\HeapLeakDetection` | Диагностика утечек памяти | 1–4 |
| `Search\RecentApps` | История поиска Windows | 1–4 |
| `Services\bam\UserSettings` | Background Activity Moderator *(только Win10)* | 1–4 |
| `AppCompatFlags\Compatibility Assistant` | История проверок совместимости | 1–4 |
| `AppCompatFlags\Layers` | Настройки режима совместимости программ | 2–4 |
| `Explorer\MountPoints2` | История подключённых дисков | 1–4 |

### Файловая система
| Путь | Описание | Пункты |
|------|----------|--------|
| `%APPDATA%\Microsoft\Windows\Recent\` | Недавние файлы и Jump Lists | 1–4 |
| `%LOCALAPPDATA%\...\Explorer\thumbcache_*.db` | Кэш превью файлов | 1–4 |
| `%TEMP%\` | Временные файлы | 1–4 |
| `%SystemRoot%\Panther\` | Логи установки/обновления Windows | 1–4 |
| `%SystemRoot%\appcompat\Programs\` | База данных совместимости | 1–4 |
| `%SystemRoot%\Prefetch\` | Prefetch, SuperFetch, ReadyBoot | 2–4 |
| `%SystemRoot%\Minidump\` | Дампы ошибок | 2–4 |
| Журналы событий Windows | Все каналы через `wevtutil` | 3–4 |

---

## Предупреждения

> ⚠️ Скрипт выполняет необратимые операции. Перед запуском закройте все программы.

- **Prefetch / SuperFetch** — первый запуск после очистки будет немного медленнее, Windows перестроит кэш автоматически
- **AppCompatFlags\Layers** — сбрасываются настройки «режима совместимости» и «запуска от администратора» для программ; нужно назначить заново
- **Thumbnail cache** — при следующем просмотре Windows перестроит кэш превью
- **Minidump** — удаляются записи о предыдущих ошибках; это затрудняет последующую диагностику системы
- **Журналы событий** — полная очистка всех каналов, включая Security, System, Application

---

## Отличия версий

| Параметр | Windows 10 | Windows 7 |
|----------|-----------|-----------|
| BAM | ✅ очищается | ⛔ отсутствует, пропускается |
| AppCompatFlags | `\Store` | `\Persisted` |
| DiagnosedApplications | ✅ | ⚠️ ключ может отсутствовать |
| Search\RecentApps | ✅ | ⚠️ ключ может отсутствовать |
| PowerShell | 5.x | 2.0 |

---

## Лицензия

[MIT License](LICENSE)
