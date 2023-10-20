local function read_file(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a"   -- *a or *all reads the whole file
    file:close()
    return content
end



describe("age", function()
    it("can load the first line with no newlone characters", function()
        assert.are.equal(
            'ABC123',
            require('age').get(
                "tests/test_api_key.txt.age",
                "tests/test.txt"
            )
        )
    end)

    it("can load the lines into a list and get the first value", function()
        assert.are.equal(
            'ABC123',
            require("age").list(
                "tests/test_api_key.txt.age",
                "tests/test.txt"
            )[1]
        )
    end)


    it("can get the second value in the list", function()
        assert.are.equal(
            'XYZ789',
            require("age").list(
                "tests/test_api_keys.txt.age",
                "tests/test.txt"
            )[2]
        )
    end)

    it("can get the data from an age encrypted json file", function()
        assert.are.same(
            vim.json.decode(read_file("tests/test_api_keys.json")),
            require("age").from_json(
                "tests/test_api_keys.json.age",
                "tests/test.txt"
            )
        )
    end)

    it("can get the data from an sops encrypted json file", function()
        assert.are.same(
            vim.json.decode(read_file("tests/test_api_keys.json")),
            require("age").from_sops("tests/sops_api_keys.json")
        )
    end)
end)
