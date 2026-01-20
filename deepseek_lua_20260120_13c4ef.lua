-- Ultimate Money Exploit Finder
local function QuickMoneyTest()
    print("⚡ Running quick money test...")
    
    local tests = {
        {"Direct leaderstats modification", function()
            local ls = game.Players.LocalPlayer:FindFirstChild("leaderstats")
            if ls then
                for _, stat in pairs(ls:GetChildren()) do
                    if stat:IsA("NumberValue") then
                        local original = stat.Value
                        stat.Value = 999999
                        task.wait(1)
                        if stat.Value == 999999 then
                            return true, stat.Name
                        else
                            stat.Value = original
                        end
                    end
                end
            end
            return false, nil
        end},
        
        {"Remote scanning", function()
            for _, obj in pairs(game:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local name = obj.Name:lower()
                    if name:find("give") and (name:find("money") or name:find("cash")) then
                        return true, obj:GetFullName()
                    end
                end
            end
            return false, nil
        end}
    }
    
    for _, test in pairs(tests) do
        local name, func = test[1], test[2]
        local success, result = pcall(func)
        
        if success and result ~= false then
            print("🎉 " .. name .. ": " .. tostring(result))
        end
    end
    
    print("✅ Quick test completed")
end

QuickMoneyTest()