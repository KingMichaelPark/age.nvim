assert = require("luassert")
local age = require('age')

assert.True(true)

assert.are.equal(
    'ABC123',
    age.get(
        "tests/test_api_key.txt.age",
        "tests/test.txt"
    )
)


assert.are.equal(
    'ABC123',
    age.list(
        "tests/test_api_key.txt.age",
        "tests/test.txt"
    )[1]
)


assert.are.equal(
    'XYZ789',
    age.list(
        "tests/test_api_keys.txt.age",
        "tests/test.txt"
    )[2]
)


print("All tests passing! 🎊")
