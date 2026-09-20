# layout-views.yazi

**Layout Views** — плагин для [Yazi](https://github.com/sxyazi/yazi), который переключает пропорции панелей `parent / current / preview` через именованные пресеты.

Меняет `rt.mgr.ratio = { parent, current, preview }`.

## Установка

Из GitHub через менеджер пакетов Yazi:

```sh
ya pkg add artemDvoryadkin/layout-views
```

Плагин окажется здесь:

```text
~/.config/yazi/plugins/layout-views.yazi/
```

### Подключение

В `~/.config/yazi/init.lua`:

```lua
require("layout-views"):setup({
	-- опционально: свои пресеты и порядок
	-- presets = { my = { 0, 40, 60 } },
	-- order = { "default", "files", "dual", "preview", "focus", "list" },
	-- notify = true,
})
```

Горячие клавиши в `~/.config/yazi/keymap.toml` (пример):

```toml
[mgr]
prepend_keymap = [
	{ on = [ "T", "n" ], run = "plugin layout-views -- next", desc = "Layout: next view" },
	{ on = [ "T", "p" ], run = "plugin layout-views -- prev", desc = "Layout: prev view" },
	{ on = [ "T", "r" ], run = "plugin layout-views -- reset", desc = "Layout: reset" },
	{ on = [ "T", "f" ], run = "plugin layout-views -- focus!", desc = "Layout: toggle focus" },
	{ on = [ "T", "l" ], run = "plugin layout-views -- list!", desc = "Layout: toggle list" },
]
```

## Использование

| Команда | Действие |
|---------|----------|
| *(без аргументов)* | Показать список view из `order` |
| `next` / `prev` | Следующий / предыдущий view по `order` |
| `reset` | Вернуть `default` |
| `<name>` | Применить пресет по имени |
| `toggle <name>` или `<name>!` | Переключить view ↔ предыдущий |
| `<p> <c> <pr>` | Задать ratio тремя числами |

Примеры:

```text
plugin layout-views -- dual
plugin layout-views -- focus!
plugin layout-views -- 0 30 70
```

## Пресеты по умолчанию

| Имя | Ratio | Смысл |
|-----|-------|--------|
| `default` | `20 30 50` | Три панели, как в `yazi.toml` |
| `files` | `10 60 30` | Больше список файлов |
| `dual` | `0 50 50` | Список + preview (без parent) |
| `preview` | `0 25 75` | Крупный preview |
| `focus` | `0 0 100` | Только preview |
| `list` | `0 100 0` | Только список |

Порядок цикла `next`/`prev`: `default → files → dual → preview → focus → list`.

## Конфигурация

| Параметр | По умолчанию | Описание |
|----------|--------------|----------|
| `presets` | см. выше | Именованные тройки `{ parent, current, preview }` |
| `order` | список имён выше | Порядок для `next` / `prev` |
| `notify` | `true` | Показывать уведомление при смене layout |

## Требования

- Yazi **26.8.15+** (`@since` в плагине)
