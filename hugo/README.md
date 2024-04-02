#### Testing locally

To view your changes as they will appear in the final website, you need to install Hugo.
You can find instructions on the Hugo website: [https://gohugo.io/](https://gohugo.io/)

If you're using Mac OSX, it's recommended to use [Homebrew](https://brew.sh/) -
if homebrew is already set up, installing Hugo is just a case of:

```bash
brew install hugo
```

Once Hugo is installed, simply run the following command in the Hugo project root directory (you may need to `cd hugo`):

```console
$ hugo server --disableFastRender --noHTTPCache --ignoreCache
Start building sites … 
hugo v0.124.1-db083b05f16c945fec04f745f0ca8640560cf1ec+extended linux/amd64 BuildDate=2024-03-20T11:40:10Z VendorInfo=snap:0.124.1


                   | EN   
-------------------+------
  Pages            |  20  
  Paginator pages  |   0  
  Non-page files   |   0  
  Static files     | 601  
  Processed images |   0  
  Aliases          |   0  
  Cleaned          |   0  

Built in 84 ms
Environment: "development"
Serving pages from disk
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1) 
Press Ctrl+C to stop
```

Use the URL printed at the bottom of this message (here, it's `http://localhost:1313/`) to view the site.
Every time you save a file, the page will automatically refresh in the browser.


### Making search work 

The search bar included in the header uses [pagefind](https://pagefind.app/) in order to work. In order to use search the site has to first be indexed which can be done as follows:

```console
npx -y pagefind --site public 
```

To preview the site straight away, you can modify the above command by adding the `--serve` flag to see the view site. This will however not check for updates you later make to the hugo site, so it is instead recommended to instead run the following commands:


```console
hugo 
npx -y pagefind --site public 
hugo server --disableFastRender --noHTTPCache --ignoreCache
```
