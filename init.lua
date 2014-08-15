require "ext.appfinder.init"

ext.mjomatic = {}

hydra.alert('mjomatic loaded')

local gridh
local gridw

local function resizetogrid(window, coords)
    -- hydra.alert(string.format('move window %q to %d,%d-%d,%d', window:title(), coords.r1, coords.c1, coords.r2, coords.c2), 20)

    -- collect screen dimensions
    local frame = screen.mainscreen():frame()
    local framew = screen.mainscreen():frame_without_dock_or_menu()

    local h = framew.h
    local w = frame.w
    local x = framew.x
    local y = framew.y
    -- hydra.alert(string.format('screen dimensions %d,%d at %d,%d', h, w, x, y))
    local hdelta = h / gridh
    local wdelta = w / gridw

    -- hydra.alert('hdelta='..hdelta, 5)
    -- hydra.alert('wdelta='..wdelta, 5)
    local newframe = {}
    newframe.x = (coords.c1-1) * wdelta + x
    newframe.y = (coords.r1-1) * hdelta + y
    newframe.h = (coords.r2-coords.r1+1) * hdelta
    newframe.w = (coords.c2-coords.c1+1) * wdelta
    window:setframe(newframe)
    -- hydra.alert(string.format('new frame for %q is %d*%d at %d,%d', window:title(), newframe.w, newframe.h, newframe.x, newframe.y), 20)
end

function ext.mjomatic.go(cfg)
    -- hydra.alert('mjomatic is go')
    local grid = {}
    local map = {}

    local target = grid


    -- FIXME move gsub stuff to separate function (iterator wrapper around io.lines?)
    --       then do parsing in two loops so we don't need to muck about with target
    --       and do some parsing inline
    for i,l in ipairs(cfg) do
        l = l:gsub('#.*','')        -- strip comments
        l = l:gsub('%s*$','')       -- strip trailing whitespace
        -- hydra.alert(l)
        if l:len() == 0 then
            if #grid > 0 then
                if target == grid then
                    target = map
                elseif #map > 0 then
                    error('config has more than two chunks')
                end
            end
        else
            table.insert(target, l)
        end
    end

    -- hydra.alert('grid size '..#grid)
    -- hydra.alert('map size '..#map)

    gridh = #grid
    gridw = nil

    local windows = {}
    local titlemap = {}

    for i, v in ipairs(map) do
        local key = v:sub(1,1)
        local title = v:sub(3)
        -- hydra.alert(string.format('%s=%s', key, title))
        titlemap[title] = key
    end

    for row, v in ipairs(grid) do
        if gridw then
            if gridw ~= v:len() then
                error('inconsistent grid with')
            end
        else
            gridw=v:len()
        end

        for column = 1, #v do
            local char = v:sub(column, column)
            if not windows[char] then
                -- new window, create it with size 1x1
                windows[char] = {r1=row, c1=column, r2=row, c2=column}
            else
                -- expand it
                windows[char].r2=row
                windows[char].c2=column
            end
        end
    end

    -- hydra.alert('grid h='..gridh..' w='..gridw)
    -- hydra.alert('windows:')
    for char, window in pairs(windows) do
        -- hydra.alert(string.format('window %s: top left %d,%d bottom right %d,%d', char, window.r1, window.c1, window.r2, window.c2))
    end
     
    for title, key in pairs(titlemap) do
        -- hydra.alert(string.format("title %s key %s", title, key))
        if not windows[key] then
            error(string.format('no window found for application %s (%s)', title, key))
        end
        app = ext.appfinder.app_from_name(title)
        window = app:mainwindow()
        -- hydra.alert(string.format('application title for %q is %q, main window %q', title, app:title(), window:title()))
        resizetogrid(window, windows[key])
    end
end