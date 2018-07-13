--[[
Syntax:
lua time.lua start commentary
lua time.lua end
lua time.lua show
lua time.lua remove id
lua time.lua clear
-- ]]

local json = require 'cjson'
-- local lfs = require 'lfs'

do
  local dir = arg[0]:match('(.+/).*$') or ''
  -- local dir = lfs.currentdir() .. '/'

  local flag = select(1, ...)
  if not flag then
    print('Please, specify start/stop of time tracking and comment')
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

  if flag == 'start' then
    if tracker.start ~= 0 then
      print('[ERROR]: Please, end your previous session with `stop` flag')
      return
    end

    tracker.start = os.time()
    tracker.comment = select(2, ...) or 'None'
    tracker.id = #tracker.logged + 1

    print('Time tracking started, ID: ' .. tracker.id)
  elseif flag == 'stop' then
    if tracker.start == 0 or not tracker.id then
      print('[ERROR]: Please, start session first with `start` flag')
      return
    end

    local secs = os.time() - tracker.start
    local hours = math.floor(secs/(60 * 60))
    local mins = math.ceil(secs/60) - hours * 60

    if tracker.logged[tracker.id] then
      local v = tracker.logged[tracker.id]

      v.hours = v.hours + hours
      v.minutes = v.minutes + mins
    else
      tracker.logged[tracker.id] = {
        hours = hours,
        minutes = mins,
        comment = tracker.comment
      }
    end

    print('Time tracking stopped, ID: ' .. tracker.id)
    print(hours .. 'h ' .. mins .. 'm | ' .. tracker.comment)

    tracker.start = 0
    tracker.comment = ''
    tracker.id = false
  elseif flag == 'edit' then
    local id = tonumber(select(2, ...))
    if not id then
      print('[ERROR]: Please, specify log ID to change comment')
      return
    end

    local comment = select(3, ...)
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
  elseif flag == 'add' then
    if tracker.start ~= 0 or tracker.id then
      print('[ERROR]: Please, end your previous session with `stop` flag')
      return
    end

    local id = select(2, ...)
    if not id then
      print('[ERROR]: Please, specify ID of a log')
      return
    end

    tracker.id = tonumber(id)
    tracker.start = os.time()

    print('Time tracking started, ID: ' .. id)
  elseif flag == 'remove' then
    if #{ ... } < 2 then
      print('[ERROR]: Please, specify position of log after `remove` flag')
      return
    end

    for i = #{ ... }, 2, -1 do
      local id = tonumber(select(i, ...))

      if not tracker.logged[id] then
        print('[ERROR]: Please, specify correct ID on ' .. i - 1  ..
              ' position' )
        return
      end

      print('ID: ' .. id .. ' successfully removed')
      table.remove(tracker.logged, id)
    end
  elseif flag == 'show' then
    if #tracker.logged == 0 then
      print('No time logs')
      return
    end

    -- io.write('ID |  TIME  | COMMENT', '\n')
    for k, v in pairs(tracker.logged) do
      local time = v.hours .. 'h ' .. v.minutes .. 'm'
      io.write(k .. ' | ', time .. ' | ', v.comment, '\n')
    end
  elseif flag == 'clear' then
    for k, v in pairs(tracker.logged) do
      local time = v.hours .. 'h ' .. v.minutes .. 'm'
      io.write(k .. ' | ', time .. ' | ', v.comment, '\n')
    end

    tracker.start = 0
    tracker.comment = ''
    tracker.id = false
    tracker.logged = {}

    print('Logs cleared')
  elseif flag == 'status' then
    if tracker.id or tracker.start ~= 0 then
      print('Time is being tracked')

      local secs = os.time() - tracker.start
      local hours = math.floor(secs/(60 * 60))
      local mins = math.ceil(secs/60) - hours * 60

      print(hours .. 'h ' .. mins .. 'm | ' .. tracker.comment)
    else
      print('Logger stopped')
    end
  elseif flag == '--help' then
    print([[
  Flags:
  start [COMMENT] – starts time log with [COMMENT or 'None']
  stop – finishes time log
  edit ID COMMENT – edites comment of time log
  add ID – sets ID time log as start point and adds to it time when stopped
  remove ID1 ... IDN – removes ID ... IDN time logs
  show – shows all time logs
  clear – removes all time logs
  --help – manual]])
  else
    print('[ERROR]: Wrong flag')
    return
  end

  f = io.open(dir .. 'log.json', 'w')
  f:write(json.encode(tracker))
  f:close()
end
