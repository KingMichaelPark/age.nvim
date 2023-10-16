# age.nvim

A simply utility for loading encrypted secrets from an
[age](https://github.com/FiloSottile/age) encrypted file.

This utility can be required by other plugins as a dependency
to load a secret from your dotfiles to pass to a plugin.

For example, the [llm.nvim](https://github.com/huggingface/llm.nvim) plugin
requires an API key. For those people who keep their dotfiles public but want
to load an API key for its setup.

I take no responsibility for leaked passwords or API keys. It is **on you**
to decide what age is, this approach, and making sure to not commit
your identity keys. Inspired by [pass](https://www.passwordstore.org/)
and [passage](https://github.com/FiloSottile/passage/blob/main/INSTALL)


## Requirements

- [age](https://github.com/FiloSottile/age)

## Non-Neovim Instructions

1. Generate a private key **not** in directory tracked by git.

```bash
mkdir ~/.age
cd ~/.age
age-keygen -o identity.txt
```

The contents of this `identity.txt` file will look like this
(Taken from the tests directory in this project for example).

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

This example is using the excellent [ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim).

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

