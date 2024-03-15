#### Testing locally

To view your changes as they will appear in the final website, you need to install Hugo.
You can find instructions on the Hugo website: [https://gohugo.io/](https://gohugo.io/)

If you're using Mac OSX, it's recommended to use [Homebrew](https://brew.sh/) -
if homebrew is already set up, installing Hugo is just a case of:

```bash
brew install hugo
```

Once Hugo is installed, simply run the following command in the Hugo project root directory:

```console
$ hugo serve
Start building sites …
hugo v0.128.3+extended darwin/amd64 BuildDate=unknown

                   | EN
-------------------+-----
  Pages            | 77
  Paginator pages  |  0
  Non-page files   |  0
  Static files     | 54
  Processed images |  0
  Aliases          |  0
  Sitemaps         |  1
  Cleaned          |  0

Built in 83 ms
Watching for changes in ...
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

Use the URL printed at the bottom of this message (here, it's `http://localhost:1313/`) to view the site.
Every time you save a file, the page will automatically refresh in the browser.