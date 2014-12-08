describe("mjomatic", function()
    local results
    local env
    local mjomatic

    setup(function()
        results = {}

        -- appfinder module
        local grille = {}
	grille.__index = grille
        function grille.new(gw, gh)
            local self = setmetatable({}, grille)
            self.mainscreen = {h=1200, w=1920, x=0, y=0}
            self.mainscreen_frame = {h=1178, w=1916, x=0, y=22}
            self.gw = gw
            self.gh = gh
	    self.cw = self.mainscreen.w/gw
	    self.ch = (self.mainscreen.h - self.mainscreen_frame.y)/gh
            return self
        end

	function grille:window(title)
	   self.title = title
	   return self
	end

	function grille:xpos(x)
	   self.x = x * self.cw + self.mainscreen_frame.x
	   return self
	end

	function grille:ypos(y)
	   self.y = y * self.ch + self.mainscreen_frame.y
	   return self
	end

	function grille:wide(w)
	   self.w = w * self.cw
	   return self
	end

	function grille:tall(h)
	   self.h = h * self.ch
	   return self
	end

	function grille:act()
	   results[self.title] = {x=self.x, y=self.y, w=self.w, h=self.h}
	   return function () end
	end

        package.loaded['mjolnir.grille'] = grille

        -- alert class
        local alert = {}

        package.loaded['mjolnir.alert'] = alert
    end)

    teardown(function()
        package.loaded['mjolnir.grille'] = nil
        package.loaded['mjolnir.alert'] = nil
    end)

    it("does the right things", function()
        stub(package.loaded['mjolnir.alert'], 'show')
        mjomatic = require('mjomatic')
        assert.stub(package.loaded['mjolnir.alert'].show).was.called(1)

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
	local expected = {['iTerm']={ x=1040, w=880, h=706.8, y=22 },
                          ['Google Chrome'] = { x=0, w=1040, h=471.2, y=22 },
                          ['Sublime Text 2'] = { x=0, w=1040, h=706.8, y=493.2 },
                          ['YoruFukurou'] = { x=1040, w=880, h=471.2, y=728.8 } }
        assert.are.same(expected, results)
    end)
end)
