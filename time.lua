-- luacheck: max line length 80
--------------------------------------------------------------------------------

--[[
Syntax:
lua time.lua start commentary
lua time.lua end
lua time.lua show
lua time.lua remove id
lua time.lua clear
-- ]]

-- LUA5.1
-- TODO: REMOVE CJSON
local json = require 'cjson'
-- local lfs = require 'lfs'

local print_log = function(tracker, id)
  if not tracker then error('Tracker must be passed to print log') end

  if not tracker.logged[id] then
    print('[ERROR]: Wrong log ID')
    return
  end

  local log = tracker.logged[id]

  local time = log.hours .. 'h ' .. log.minutes .. 'm'
  local com = log.comment
  local date = log.date
  local upd = log.updated_date or log.date

  io.write(id .. ' | ', time .. ' | ', com .. ' | ', date .. ' | ', upd, '\n')
end

local print_all_logs = function(tracker)
  io.write('----------------------------------------\n')

  local tmins = 0
  for i = 1, #tracker.logged do
    print_log(tracker, i)
    tmins = tracker.logged[i].hours * 60 + tracker.logged[i].minutes + tmins
  end

  local h = math.floor(tmins / 60)
  local m = tmins - h * 60

  io.write('----------------------------------------\n')
  io.write('TOTAL: ' .. h .. 'h ' .. m .. 'mins\n')
end

local handlers = { }

handlers.start = function(tracker, args)
  if tracker.start ~= 0 then
    print('[ERROR]: Please, end your previous session with `stop` flag')
    return
  end

  tracker.start = os.time()
  tracker.comment = args[2] or 'None'
  tracker.id = #tracker.logged + 1
  tracker.date = os.date('%x')

  print('Time tracking started, ID: ' .. tracker.id)
  return true
end

handlers.stop = function(tracker, args)
  if tracker.start == 0 or not tracker.id then
    print('[ERROR]: Please, start session first with `start` flag')
    return
  end

  local secs = os.time() - tracker.start
  local hours = math.floor(secs/(60 * 60))
  local mins = math.ceil(secs/60) - hours * 60

  if tracker.logged[tracker.id] then
    local v = tracker.logged[tracker.id]

    v.updated_date = os.date('%x')

    v.hours = v.hours + hours
    v.minutes = v.minutes + mins

    if math.floor(v.minutes / 60) >= 1 then
      local a_hours = math.floor(v.minutes/60)
      v.hours = v.hours + a_hours
      v.minutes = v.minutes - a_hours * 60
    end
  else
    tracker.logged[tracker.id] = {
      hours = hours,
      minutes = mins,
      date = tracker.date,
      comment = tracker.comment
    }
  end

  print('Time tracking stopped, ID: ' .. tracker.id)
  print_log(tracker, tracker.id)

  tracker.start = 0
  tracker.comment = ''
  tracker.date = ''
  tracker.id = false
  return true
end

handlers.rename = function(tracker, args)
  local id = tonumber(args[2])
  if not id then
    print('[ERROR]: Please, specify log ID to change comment')
    return
  end

  local comment = args[3]
  if not comment then
    print('[ERROR]: Please, specify updated comment')
    return
  end

  if id == tracker.id then
    tracker.comment = comment
  elseif tracker.logged[id] then
    tracker.logged[id].comment = comment
  else
    print('[ERROR]: Please, specify correct log ID')
    return
  end

  print('Comment successfully updated, ID: ' .. id)
  return true
end

handlers.continue = function(tracker, args)
  if tracker.start ~= 0 or tracker.id then
    print('[ERROR]: Please, end your previous session with `stop` flag')
    return
  end

  local id = tonumber(args[2])
  if not id then
    print('[ERROR]: Please, specify ID of a log')
    return
  end

  if not tracker.logged[id] then
    print('[ERROR]: Wrong log ID')
    return
  end

  tracker.id = id
  tracker.start = os.time()
  tracker.comment = tracker.logged[id].comment

  print('Time tracking continued, ID: ' .. id)
  return true
end

handlers.inc = function(tracker, args)
  local id = tonumber(args[2])
  if not id then
    print('[ERROR]: Please, specify ID of a log')
    return
  end

  if not tracker.logged[id] then
    print('[ERROR]: Wrong log ID')
    return
  end

  local mins = tonumber(args[3])
  if not mins then
    print('[ERROR]: Please, specify minutes to inc')
    return
  end

  tracker.logged[id].minutes = tracker.logged[id].minutes + mins
  if tracker.logged[id].minutes >= 60 then
    local h = math.floor(tracker.logged[id].minutes / 60)

    tracker.logged[id].minutes = tracker.logged[id].minutes - h * 60
    tracker.logged[id].hours = tracker.logged[id].hours + h
  end

  print('Time successfully increased, ID: ' .. id)
  return true
end

handlers.dec = function(tracker, args)
  local id = tonumber(args[2])
  if not id then
    print('[ERROR]: Please, specify ID of a log')
    return
  end

  if not tracker.logged[id] then
    print('[ERROR]: Please, specify existing log ID')
    return
  end

  local mins = tonumber(args[3])
  if not mins then
    print('[ERROR]: Please, specify minutes to dec')
    return
  end

  if tracker.logged[id].minutes >= mins then
    tracker.logged[id].minutes = tracker.logged[id].minutes - mins
  else
    local tmins = tracker.logged[id].minutes + tracker.logged[id].hours * 60
    if tmins >= mins then
      tmins = tmins - mins
      tracker.logged[id].hours = math.floor(tmins/60)
      tracker.logged[id].minutes = tmins - tracker.logged[id].hours * 60
    else
      print('[ERROR]: Can not decrease time on more minutes than logged')
      return
    end
  end

  print('Time successfully decreased, ID: ' .. id)
  return true
end

handlers.remove = function(tracker, args)
  if #args < 2 then
    print('[ERROR]: Please, specify position of log after `remove` flag')
    return
  end

  for i = #args, 2, -1 do
    local id = tonumber(args[i])

    if not tracker.logged[id] then
      print('[ERROR]: Please, specify correct ID on ' .. i - 1  ..
            ' position' )
      return
    end

    print('ID: ' .. id .. ' successfully removed')

    print_log(tracker, id)
    table.remove(tracker.logged, id)
  end
  return true
end

handlers.show = function(tracker, args)
  if #tracker.logged == 0 then
    print('No time logs')
    return true
  end

  print_all_logs(tracker)

  return true
end

handlers.clear = function(tracker, args)
  print_all_logs(tracker)

  tracker.start = 0
  tracker.comment = ''
  tracker.id = false
  tracker.logged = {}

  print('Logs cleared')
  return true
end

handlers.reset = function(tracker, args)
  tracker.start = 0
  tracker.comment = ''
  tracker.id = false

  print('Time log reset')
  return true
end

handlers.status = function(tracker, args)
  if tracker.id or tracker.start ~= 0 then
    print('Time is being tracked')

    local secs = os.time() - tracker.start
    local hours = math.floor(secs/(60 * 60))
    local mins = math.ceil(secs/60) - hours * 60

    print(hours .. 'h ' .. mins .. 'm | ' .. tracker.comment)
  else
    print('Logger stopped')
  end
  return true
end

do
  local dir = arg[0]:match('(.+/).*$') or ''
  -- local dir = lfs.currentdir() .. '/'

  local args = { ... }
  local flag = args[1]
  if not flag then
    print('Please, specify flag')
    return
  end

  local tracker = {}

  local f = io.open(dir .. 'log.json', 'r')
  if f then
    tracker = json.decode(f:read('*a'))
    f:close()
  else
    tracker.start = 0
    tracker.comment = ''
    tracker.id = false
    tracker.logged = {}
  end

  if flag == '--help' then
    print([[
  Flags:
  start [COMMENT] – starts time log with [COMMENT or 'None']
  stop – finishes time log
  renames ID COMMENT – renames comment of time log
  continue ID – continues time tracking of log ID
  remove ID1 ... IDN – removes ID ... IDN time logs
  show – shows all time logs
  clear – removes all time logs
  --help – manual]])
      return
  elseif not handlers[flag] then print('[ERROR]: Wrong flag')
  else handlers[flag](tracker, args) end

  f = io.open(dir .. 'log.json', 'w')
  f:write(json.encode(tracker))
  f:close()
end
