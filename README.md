# Dnster

Dnster manages your .dev DNS with ease.  She'll proxy port 80 to your app's port so you don't have to type it in.  She'll even terminate SSL if you ask.

## Usage

```
$ sudo dnster run
```

## History and Credits

Dnster is 100% the offspring of [local-tld](https://github.com/hoodiehq/local-tld).  I chose to rewrite rather than fork for a few reasons: I found the codebase to be pretty gnarly, it did not support Linux, and it did not offer SSL termination.

