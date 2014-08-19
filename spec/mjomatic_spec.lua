describe("mjomatic", function()
    local results
    local window, application, appfinder, screen, hydra, ext
    local env
    local mjomatic

    setup(function()
        results = {}
        env = {}

        -- window class
        local window = {}
        window.__index = window
        function window.new(name)
            local self = setmetatable({}, window)
            self.name = name
            return self
        end

        function window:setframe(frame)
            results[self.name] = frame
        end

        env.window = window

        -- application class
        application = {}
        application.__index = application
        function application.new(name)
            local self = setmetatable({}, application)
            self.name = name
            return self
        end

        function application:mainwindow()
            return window.new(self.name)
        end

        env.application = env

        -- appfinder module
        appfinder = {}
        function appfinder.app_from_name(name)
            return application.new(name)
        end

        env.appfinder = appfinder
        
        -- screen class
        screen = {}
        screen.__index = screen
        function screen.new(name, frame, framew)
            local self = setmetatable({}, screen)
            self.name = name
            self.framefull = frame
            self.framew = framew
            return self
        end

        function screen.mainscreen()
            return screen.new('mainscreen', {h=1200, w=1920, x=0, y=0}, {h=1178, w=1916, x=0, y=22})
        end

        function screen:frame()
            return self.framefull
        end

        function screen:frame_without_dock_or_menu()
            return self.framew
        end

        env.screen = screen

        -- hydra module
        hydra = {}

        env.hydra = hydra

        ext = {}
        ext.appfinder = appfinder
        ext.appfinder.init = {}

        env.ext = ext

        package.loaded['ext.appfinder.init'] = ext.appfinder.init
    end)

    teardown(function()
        package.loaded['ext.appfinder.init']=nil
    end)

    it("does the right things", function()
        stub(hydra, 'alert')
        mjomatic = require('spec/mjomatic_wrapper')(env)
        assert.stub(hydra.alert).was.called(1)

        mjomatic.go({
            "CCCCCCCCCCCCCiiiiiiiiiii      # <-- The windowgram, it defines the shapes and positions of windows",
            "CCCCCCCCCCCCCiiiiiiiiiii",
            "SSSSSSSSSSSSSiiiiiiiiiii",
            "SSSSSSSSSSSSSYYYYYYYYYYY",
            "SSSSSSSSSSSSSYYYYYYYYYYY",
            "",
            "#  foc                     # <-- Three 3-letter commands to remember: Focus, Directory, Run",
            "#  dir ~                   # <-- Unlinked directory, becomes default for all undefined panes",
            "C Google Chrome            # <-- window C has application():title() 'Google Chrome'",
            "i iTerm",
            "Y YoruFukurou",
            "S Sublime Text 2"})
        assert.are.same(results, {['iTerm']={ x=1040, w=880, h=706.8, y=22 },
                                  ['Google Chrome'] = { x=0, w=1040, h=471.2, y=22 },
                                  ['Sublime Text 2'] = { x=0, w=1040, h=706.8, y=493.2 },
                                  ['YoruFukurou'] = { x=1040, w=880, h=471.2, y=728.8 } }) 
    end)
end)