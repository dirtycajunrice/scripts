# Utility Scripts

8/22/20 - This repo has had everything moved to the [archived](archived) folder, and
will be brought out one by one as they are deemed still usable or are updated.


## [haste](bash/haste.sh)
cli function to post data to [hastebin.com](https://hastebin.com) or similar.
Add this to your .bash_aliases: 
```
Usage: haste [options] [file]

Options:
  -r, --raw      Get the raw link to the output.
  -h, --help     Print this help text.

Upload the contents of plaintext document to a hastebin.
Invocation with no arguments takes input from pipe.
haste server location can be changed with the $HASTE_SERVER environment variable
```