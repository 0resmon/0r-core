R.VersionCheck = function(name, ver)
    if not ver then ver = GetResourceMetadata(name, "version") end
    PerformHttpRequest(Config.Version.DB, function (err, data, headers)
        local versions = json.decode(data)
        for k,v in pairs(versions) do
            if v.script == name and ver ~= v.version then 
                print("["..v.script.."] "..Config.Lang["NeedUpdate"])
                while Config.Version.Loop do 
                    print("["..v.script.."] "..Config.Lang["NeedUpdate"])
                    Citizen.Wait(Config.Version.LoopTime)
                end
               break
            end
        end
    end)
end