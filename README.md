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
	# --- Layout views: один список режимов ---
	# cycle
	{ on = ["T", "v"], run = "plugin layout-views next", desc = "Layout: next view" },
	{ on = ["T", "V"], run = "plugin layout-views prev", desc = "Layout: previous view" },

	# presets
	{ on = ["T", "d"], run = "plugin layout-views default", desc = "Layout: default [20 30 50]" },
	{ on = ["T", "F"], run = "plugin layout-views files", desc = "Layout: files [10 60 30]" },
	{ on = ["T", "f"], run = "plugin layout-views preview_and_files", desc = "Layout: files [10 30 60]" },
	{ on = ["T", "2"], run = "plugin layout-views dual", desc = "Layout: dual [0 50 50]" },
	{ on = ["T", "p"], run = "plugin layout-views preview", desc = "Layout: preview [0 25 75]" },

	# toggle туда-обратно
	{ on = ["T", "Z"], run = "plugin layout-views toggle focus", desc = "Layout: toggle focus [0 0 100]" },
	{ on = ["T", "z"], run = "plugin layout-views toggle list", desc = "Layout: toggle list [0 100 0]" },
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
