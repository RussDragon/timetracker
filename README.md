# Requirements
- Lua 5.1
- cjson

# Installation
> luarocks install cjson

Clone this repo to your computer and add shell alias (Unix) like this:
> alias logt = 'lua _path-to-repo/time.lua_'

# Usage
> lua time.lua start comment

- Start: indicates start of time loggin
- Comment: comment which will be added to you time log after you finish.

> lua time.lua stop

- Stop: stops and saves your time log

> lua time.lua continue id

- Continue: continues time tracking of a log by id

> lua time.lua inc id mins

- Inc: increase (add) time to a log id on `mins` minutes

> lua time.lua dec id mins

- Dec: decrease (remove) time from a log id on `mins` minutes

> lua time.lua show

- Show: shows all of your time logs

> lua time.lua remove id

- Remove: removes log by `id` from `show`

> lua time.lua reset

- Reset: resets current time log

> lua time.lua status

- Status: shows current logged time

> lua time.lua rename id comment

- Rename: edits commentary of log ID

> lua time.lua clear

- Clear: removes all logs

All your time log are saved in log.json within your script directory.

===============================================================================

Copyright (c) 2018, RussDragon <russdragon9000@gmail.com>
See file COPYRIGHT for the license.
