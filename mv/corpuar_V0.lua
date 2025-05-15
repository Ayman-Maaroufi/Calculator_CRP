-- corpuar_V0.lua

local math = require("math")

local function tokenize(expr)
    local tokens = {}
    for token in string.gmatch(expr, "[%d%.]+|[%+%-%*/%^%(%)]|[a-zA-Z_][a-zA-Z0-9_]*") do
        table.insert(tokens, token)
    end
    return tokens
end

local precedence = {
    ["^"] = 4,
    ["*"] = 3, ["/"] = 3,
    ["+"] = 2, ["-"] = 2
}



local function infixToPostfix(tokens)
    local output, stack = {}, {}
    for _, token in ipairs(tokens) do
        if tonumber(token) then
            table.insert(output, token)
        elseif token:match("^[a-zA-Z_]") then
            table.insert(output, token)
        elseif token == "(" then
            table.insert(stack, token)
        elseif token == ")" then
            while stack[#stack] ~= "(" do
                table.insert(output, table.remove(stack))
            end
            table.remove(stack)
        else
            while stack[#stack] and precedence[stack[#stack]] and precedence[stack[#stack]] >= precedence[token] do
                table.insert(output, table.remove(stack))
            end
            table.insert(stack, token)
        end
    end
    while #stack > 0 do
        table.insert(output, table.remove(stack))
    end
    return output
end

local functions = {
    sin = math.sin,
    cos = math.cos,
    tan = math.tan,
    log = math.log,
    exp = math.exp,
    sqrt = math.sqrt,
    abs = math.abs
}

local function evalPostfix(postfix)
    local stack = {}
    for _, token in ipairs(postfix) do
        if tonumber(token) then
            table.insert(stack, tonumber(token))
        elseif functions[token] then
            local a = table.remove(stack)
            table.insert(stack, functions[token](a))
        elseif token == "+" or token == "-" or token == "*" or token == "/" or token == "^" then
            local b = table.remove(stack)
            local a = table.remove(stack)
            if token == "+" then table.insert(stack, a + b)
            elseif token == "-" then table.insert(stack, a - b)
            elseif token == "*" then table.insert(stack, a * b)
            elseif token == "/" then table.insert(stack, a / b)
            elseif token == "^" then table.insert(stack, a ^ b)
            end
        else
            error("Unknown token: " .. tostring(token))
        end
    end
    return stack[1]
end

local function ai_analyze(expr)
    if expr:match("%+%s*0") or expr:match("0%s*%+") then
        print("AI: Adding zero doesn't change the value. You can simplify this expression.")
    elseif expr:match("%*%s*1") or expr:match("1%s*%*") then
        print("AI: Multiplying by one doesn't change the value. You can simplify this expression.")
    elseif expr:match("/%s*0") then
        print("AI: Division by zero detected! This will cause an error.")
    end
end

print("Complex Calculator (type 'exit' to quit)")
while true do
    io.write("> ")
    local input = io.read()
    if input == "exit" then break end
    ai_analyze(input)
    local status, tokens = pcall(tokenize, input)
    if not status then print("Invalid input.") goto continue end
    local status2, postfix = pcall(infixToPostfix, tokens)
    if not status2 then print("Syntax error.") goto continue end
    local status3, result = pcall(evalPostfix, postfix)
    if status3 then
        print("Result:", result)
    else
        print("Evaluation error:", result)
    end
    ::continue::
end

-- Example usage:
-- local expr = "3 + 5 * (2 - 8)"
-- local tokens = tokenize(expr)            


# NFT