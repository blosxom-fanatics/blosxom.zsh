# blosxom.zsh

A minimal static blog engine written in Zsh. This script generates blog pages from plain text files under the `data/` directory, using simple HTML templates.

## Features
- Pure Zsh implementation (no external dependencies)
- Blog entries are just text files (1st line: title, rest: body)
- Supports nested directories for organizing posts
- Simple template system using `head.html`, `story.html`, and `foot.html`
- Filters posts by `PATH_INFO` (for CGI or static generation)
- Sorts posts by modification time (newest first)

## Directory Structure
```
blosxom.zsh
head.html
story.html
foot.html
data/
  first.txt
  second.txt
  2024/12/last-year.txt
  examples/hello.txt
  tips/zsh-tips.txt
```

## How It Works
1. **Collects posts**: Recursively finds all `*.txt` files under `data/`, sorts by modification time.
2. **Parses posts**: Each file's first line is the title, the rest is the body.
3. **Renders templates**: Fills variables into the HTML templates for head, each story, and foot.
4. **PATH_INFO filtering**: If `PATH_INFO` is set, only matching posts are shown.

## Templates
- `head.html`: Blog header (receives variables like `title`, `home`)
- `story.html`: Each post (receives variables like `title`, `body`, `date`, `name`, etc.)
- `foot.html`: Blog footer (receives variables like `version`)

## Example Post File
```
First Post
This is the very first post on my blosxom.zsh blog.
Welcome to the world of Zsh blogging!
```

## Usage

This script is designed to work as a CGI program (for example, with Apache or nginx + fcgiwrap), so it reads environment variables such as `PATH_INFO` and outputs the result to standard output. You can also use it to generate static HTML files.

### Run as CGI with Python's built-in server (for testing)

You can easily test this script as a CGI program using Python 3:

```sh
cd cgi-bin
python3 -m http.server --cgi 8000
```

Then access: [http://localhost:8000/cgi-bin/blosxom.zsh](http://localhost:8000/cgi-bin/blosxom.zsh)

> **Note:** This is for local testing and demonstration purposes only.

### Generate static HTML

```sh
zsh blosxom.zsh > index.html
```

Or deploy as a CGI script with a web server that supports Zsh CGI.

## Note
This is a "toy" or "joke" script for fun and demonstration purposes. Not intended for production use.

## License
MIT
