# Requirements
- Lua 5.1
- cjson
- luafilesystem

# Installation
> luarocks install cjson

> luarocks install luafilesystem

Clone this repo to your computer and add shell alias (Unix) like this:
> alias logt = 'lua _path-to-repo/time.lua_'

# Usage
> lua time.lua start comment

- Start: indicates start of time loggin
- Comment: comment which will be added to you time log after you finish.

> lua time.lua stop

- Stop: stops and saves your time log

> lua time.lua show

- Show: shows all of your time logs

> lua time.lua remove id

- Remove: removes log by `id` from `show`

> lua time.lua clear

- Clear: removes all logs

All your time log are saved in log.json within your script directory.

===============================================================================
Copyright (c) 2018, Philipp Palutin <russdragon9000@gmail.com>
See file COPYRIGHT for the license.
