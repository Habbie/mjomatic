describe("mjomatic", function()

    setup(function()
        results = {}

        -- window class
        window = {}
        window.__index = window
        function window.new(name)
            local self = setmetatable({}, window)
            self.name = name
            return self
        end

        function window:setframe(frame)
            results[self.name] = frame
        end

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

        -- appfinder module
        appfinder = {}
        function appfinder.app_from_name(name)
            return application.new(name)
        end
        
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

        -- hydra module
        hydra = {}

        ext = {}
        ext.appfinder = appfinder
        ext.appfinder.init = {}

        package.loaded['ext.appfinder.init'] = ext.appfinder.init
    end)

    teardown(function()
        window = nil
        application = nil
        appfinder = nil
        screen = nil
        hydra = nil

        ext = nil

        package.loaded['ext.appfinder.init']=nil
    end)

    it("can require mjomatic, and mjomatic alerts on load", function()
        stub(hydra, 'alert')
        require 'init'
        assert.stub(hydra.alert).was.called(1)
    end)

    it("can GO", function()
        ext.mjomatic.go({
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
    end)

    it("puts iTerm in the right place", function()
        assert.are.same(results['iTerm'], { x=1040, w=880, h=706.8, y=22 })
    end)
    it("puts Google Chrome in the right place", function()
        assert.are.same(results['Google Chrome'], { x=0, w=1040, h=471.2, y=22 })
    end)

    it("puts Sublime Text 2 in the right place", function()
        assert.are.same(results['Sublime Text 2'], { x=0, w=1040, h=706.8, y=493.2 })
    end)

    it("puts YoruFukurou in the right place", function()
        assert.are.same(results['YoruFukurou'], { x=1040, w=880, h=471.2, y=728.8 })
    end)
end)