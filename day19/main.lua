#!/usr/bin/lua

function copyTable(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = copyTable(value)
        else
            copy[key] = value
        end
    end
    return copy
end

function parseInput(filePath)
    local file = io.open(filePath, "r")
    local content = file:read("*a")
    file:close()
    local workflows = {}
    local parts = {}
    for line in content:gmatch("[^\r\n]+") do
        if string.sub(line, 1, 1) == "{" then
            local part = {}
            for key, value in string.sub(line, 2, -2):gmatch("(%w+)=(%d+),?") do
                part[key] = tonumber(value)
            end
            table.insert(parts, part)
        else
            local workflow = {}
            workflow["name"] = string.sub(line, 0, string.find(line, "{")-1)
            workflow["rules"] = {}
            for rule in string.sub(line, string.find(line, "{")+1, -2):gmatch("([^,]+),?") do
                table.insert(workflow["rules"], rule)
            end
            table.insert(workflows, workflow)
        end
    end
    return workflows, parts
end

function findWorkflow(workflows, name)
    for _, workflow in ipairs(workflows) do
        if workflow["name"] == name then
            return workflow
        end
    end
    return nil
end

function applyRule(rules, part)
    for _, rule in ipairs(rules) do
        if string.find(rule, ">") then
            local key, value, name = string.match(rule, "(%w+)>(%d+):(%w+)")
            if part[key] > tonumber(value) then
                return name
            end
        elseif string.find(rule, "<") then
            local key, value, name = string.match(rule, "(%w+)<(%d+):(%w+)")
            if part[key] < tonumber(value) then
                return name
            end
        else
            return rule
        end
    end
    return nil
end

function isPartAccepted(workflows, part)
    local workflowName = "in"
    while true do
        local workflow = findWorkflow(workflows, workflowName)
        local output = applyRule(workflow["rules"], part)
        if output == "R" then
            return false
        elseif output == "A" then
            return true;
        else
            workflowName = output
        end
    end
end

function sumAcceptedParts(workflows, parts)
    local total = 0
    for _, part in ipairs(parts) do
        if isPartAccepted(workflows, part) then
            for _, value in pairs(part) do
                total = total + value
            end
        end
    end
    return total
end

function applyRuleToRange(rules, stack, currentRange)
    for _, rule in ipairs(rules) do
        if string.find(rule, ">") then
            local key, value, name = string.match(rule, "(%w+)>(%d+):(%w+)")
            local min, max = currentRange[key][1], currentRange[key][2]
            value = tonumber(value)
            if min > value then
                return name
            elseif max > value then
                currentRange[key] = {value+1, max}
                local newRange = copyTable(currentRange)
                newRange[key] = {min, value}
                table.insert(stack, newRange)
                return name
            end
        elseif string.find(rule, "<") then
            local key, value, name = string.match(rule, "(%w+)<(%d+):(%w+)")
            local min, max = currentRange[key][1], currentRange[key][2]
            value = tonumber(value)
            if max < value then
                return name
            elseif min < value then
                currentRange[key] = {min, value-1}
                local newRange = copyTable(currentRange)
                newRange[key] = {value, max}
                table.insert(stack, newRange)
                return name
            end
        else
            return rule
        end
    end
    return nil
end

function processRange(workflows, stack, currentRange)
    local workflowName = "in"
    while true do
        local workflow = findWorkflow(workflows, workflowName)
        local output = applyRuleToRange(workflow["rules"], stack, currentRange)
        if output == "R" then
            return false
        elseif output == "A" then
            return true;
        else
            workflowName = output
        end
    end
end

function computeCombinations(range)
    local combinations = 1
    for _, values in pairs(range) do
        combinations = combinations * (1 + values[2] - values[1])
    end
    return combinations
end

function availableCombinations(workflows)
    local combinations = 0
    local initialRange = {
        x = {1, 4000},
        m = {1, 4000},
        a = {1, 4000},
        s = {1, 4000},
    }
    local stack = {}
    table.insert(stack, initialRange)
    while #stack > 0 do
        currentRange = table.remove(stack)
        if processRange(workflows, stack, currentRange) then
            combinations = combinations + computeCombinations(currentRange)
        end
    end
    return combinations
end

function part01(filePath)
    workflows, parts = parseInput(filePath)
    return sumAcceptedParts(workflows, parts)
end

function part02(filePath)
    workflows, _ = parseInput(filePath)
    return availableCombinations(workflows)
end

function main()
    assert(part01("sample.txt") == 19114, "Part 01 incorrect for sample file")
    local part01output = part01("input.txt")
    print("Part 01: " .. part01output)
    assert(part01output == 325952, "Part 01 incorrect for input file")
    assert(part02("sample.txt") == 167409079868000, "Part 02 incorrect for sample file")
    local part02output = part02("input.txt")
    print("Part 02: " .. part02output)
    assert(part02output == 125744206494820, "Part 02 incorrect for input file")
end

main()