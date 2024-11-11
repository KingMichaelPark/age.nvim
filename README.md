# age.nvim

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
![GitHub release (latest by SemVer including pre-releases)](https://img.shields.io/github/downloads-pre/KingMichaelPark/age.nvim/0.1.0/total)

A simply utility for loading encrypted secrets from an
[age](https://github.com/FiloSottile/age) encrypted file.

This utility can be required by other plugins as a dependency to load a secret
from your dotfiles to pass to a plugin.

For example, the [llm.nvim](https://github.com/huggingface/llm.nvim) plugin
requires an API key. For those people who keep their dotfiles public but want
to load an API key for its setup.

I take no responsibility for leaked passwords or API keys. It is **on you** to
decide what age is, this approach, and making sure to not commit your identity
keys. Inspired by [pass](https://www.passwordstore.org/) and
[passage](https://github.com/FiloSottile/passage/blob/main/INSTALL)


## Requirements

- [age](https://github.com/FiloSottile/age)

## Non-Neovim Instructions

1. Generate a private key **not** in directory tracked by git.

```bash
mkdir ~/.age
cd ~/.age
age-keygen -o identity.txt
```

The contents of this `identity.txt` file will look like this (Taken from the
tests directory in this project for example).

```
# created: 2023-10-14T17:25:45+01:00
# public key: age1kk84zfvr4whsfdmrg2hk8pf7l3v705a8x9k5khuh0lmtrnuaz4gqnwty3q
AGE-SECRET-KEY-1USUPGW9GDQAQEHM8X3JKQSJMN7YY5T26PXWFHWMRR4Y9TDAHMA5SJDRUUJ
```

2. Encrypt your secret.

```bash
age_public_key='age1kk84zfvr4whsfdmrg2hk8pf7l3v705a8x9k5khuh0lmtrnuaz4gqnwty3q'
echo 'MY_SUPER_COOL_API_KEY' | age -e -r "$age_public_key" -o ~/.dotfiles/api_key.age
```

## Neovim Instructions

### Package manager

#### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

This example is using the excellent
[ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim).

```lua
local identity = vim.fn.expand('$HOME/.age/identity.txt')
local secret = vim.fn.expand('$HOME/.dotfiles/chatgpt.age')

require("lazy").setup({
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
        ...
        "KingMichaelPark/age.nvim" -- Add age dependency
    }
    config = function()
        vim.env.OPENAI_API_KEY = require('age').get(secret, identity) -- Get secret
        require("chatgpt").setup()
    end,
}
})
```

## Usage

At the moment there are 4 options for decryption, I have added SOPs decrypt as
an option for `json` only as there is a built-in json decoder in neovim.

```lua
local age = require('age')

age.get(
    "super-secret.txt.age", -- The file to decrypt
    "identity.txt" -- Your private age key
)

age.list(
    "super-secrets-multiline.txt.age", -- The file to decrypt
    "identity.txt" -- Your private age key
)

-- Returns a table
age.from_json(
    "super-secrets.json.age", -- The file to decrypt
    "identity.txt" -- Your private age key
)

-- Returns a table
age.from_sops("tests/sops_api_keys.json")
-- SOPs uses a special path so you don't need to pass your identity
```

## Running Tests

To run tests:

1. Open neovim
2. Have plenary.nvim installed
3. Run `:PlenaryBustedDirectory tests/`



## Authors

- [@KingMichaelPark](https://www.github.com/KingMichaelPark)

## Contributing

Contributions are always welcome!
