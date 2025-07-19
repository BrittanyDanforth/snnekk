-- test.lua
-- A simple Lua test file

-- Print a greeting
print("Hello from test.lua!")

-- Define a function
function greet(name)
    return "Hello, " .. name .. "!"
end

-- Test the function
local message = greet("World")
print(message)

-- Some basic Lua examples
local numbers = {1, 2, 3, 4, 5}
local sum = 0

for i, num in ipairs(numbers) do
    sum = sum + num
end

print("Sum of numbers: " .. sum)

-- Table example
local person = {
    name = "Alice",
    age = 30,
    city = "New York"
}

print("\nPerson details:")
for key, value in pairs(person) do
    print(key .. ": " .. value)
end