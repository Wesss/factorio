
local TestRunner = {}

local Tests = require("test.base-2-0.dependency-graph-tests")

-- given various state, run tests as needed. this is meant to be edited to swap out test suites
function TestRunner.run()
    -- run all tests
    TestRunner.runTests(Tests)

    -- run specific test(s)
    -- TestRunner.runTests({test = Tests.addIronPlateItem})
end

--- Runs a suite of tests and logs the results.
--  @param tests A table where each key is a test name (string) and each value is a function representing a test to run.
--      Each test's returns table should have the following structure:
--      { success = boolean, message = string }
function TestRunner.runTests(tests)
    local successes = 0
    local failures = 0

    -- iterate functions
    for testName, testFunction in pairs(tests) do
        -- Safely execute the test function
        log("Running test=" .. testName)
        local ok, result = pcall(testFunction)

        if not ok then
            -- test call ran into an error
            log("testResult=fail msg=" .. result)
            failures = failures + 1
        elseif type(result) ~= "table" or result.success == nil then
            -- test returned an invalid result
            log("testResult=fail msg=Test did not return a valid test result.")
            failures = failures + 1
        elseif not result.success then
            -- test fail
            log("testResult=fail msg=" .. (result.message or ""))
            failures = failures + 1
        else
            -- test pass
            log("testResult=success msg=" .. (result.message or ""))
            successes = successes + 1
        end
    end

    error("Tests finished! Check logs for output. success=" .. successes .. " fail=" .. failures)
end

return TestRunner;