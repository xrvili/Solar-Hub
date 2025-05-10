local RiskyFunctions = {
  "hookmetamethod",
  "getrawmetatable",
  "hookfunction",
  "restorefunction",
  "isfunctionhooked",
  "setrawmetatable",
  "setreadonly"
}

for i, v in ipairs(RiskyFunctions) do
  if getgenv()[v] then
    getgenv()[v] = nil
  end
end
