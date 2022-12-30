function browser_active_tab_with_name(name)
    return function()
        local result, object = hs.osascript.javascript([[
            function main() {
                // below is javascript code
                var browser = Application('Microsoft Edge');
                browser.activate();
                var wins = browser.windows;

                // loop tabs to find a web page with a title of <name>
                // sentinel value
                var index = -1;
                for (var i = 0; i < wins.length; i++) {
                    index = i;
                    var win = wins.at(i);
                    var tabs = win.tabs;
                    for (var j = 0; j < tabs.length; j++) {
                    var tab = tabs.at(j);
                    if (tab.title().indexOf(']] .. name .. [[') > -1) {
                            win.activeTabIndex = j + 1;
                            // it is easiest to find the tab in javascript
                            // but it's a total bitch to focus the right window
                            // i simply couldn't get AXRaise or any of those search
                            // results to work. i thought it had to do with accessibility
                            // or general permissions or i just couldn't get the syntax
                            // right. either way, in hammerspoon we can actually do this
                            // se lets return the window 0-based index to the outside world.
                            // why not do all of this on the hammerspoon/lua side?
                            // beause tabs have a different meaning. you can find windows and
                            // all that, but you can't actually traverse the browser tabs.
                            return {windowIndex: index};
                        }
                    }
                }
                return;
            }
            main();
            //JSON.stringify(main());
            // end of javascript
        ]], {"-s"})
        --print(result)
        --print(object)
        -- two things to note:
        -- this uses a 1-based index, where 1 refers to the currently foremost window
        -- when you change the focus, the list gets updated
        -- doesn't matter in this case though, but calling e.g. focus repeatedly
        -- on the second window when there are only 2 windws will effectively
        -- toggle between them
        if object ~= nil then
            --index = hs.json.decode(object).windowIndex + 1
            index = object.windowIndex + 1
            --print(index)
            browser = hs.application("Microsoft Edge")
            browser:allWindows()[index]:focus()
        end
    end
end

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "M", browser_active_tab_with_name("Meet"))
