# Cursor Agents Backup/Restore

Этот репозиторий хранит экспорт истории Cursor Agents в `chat-history/` и скрипты для переноса между машинами.

## Что внутри

- `chat-history/*.jsonl` — архив экспортированных чатов
- `scripts/export_agents.ps1` — экспорт чатов из локального Cursor в репозиторий
- `scripts/restore_agents.ps1` — восстановление чатов из репозитория в локальный Cursor

## Шаг 1. На исходной машине (экспорт)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\export_agents.ps1 \
  -ProjectId "c-Users-your-user-Documents-GitHub-your-project"
```

Опционально можно указать точный путь `-ProjectRoot` вместо `-ProjectId`.

## Шаг 2. Отправка в GitHub

```powershell
git add chat-history scripts README.md
git commit -m "Update Cursor agents archive"
git push
```

## Шаг 3. На другой машине (восстановление)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\restore_agents.ps1 \
  -ProjectId "c-Users-your-user-Documents-GitHub-your-project"
```

Если не знаете `ProjectId`, укажите `-ProjectRoot`.

## Шаг 4. Обновить Cursor

- Откройте нужный проект в Cursor
- Если чаты не появились сразу — перезапустите Cursor

## Примечания

- Файлы могут содержать чувствительные данные. Используйте приватный репозиторий.
- Скрипты создают структуру вида `agent-transcripts/<uuid>/<uuid>.jsonl`.

## Рабочие заметки

- `chat-history/` — экспортированные JSONL-логи и служебные отчеты.
- Перед публикацией проверяйте:
  - `git status`
  - `git log --oneline -n 10`
