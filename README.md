HashiCorp Middleman Customizations
==================================
A wrapper around [Middleman][] for HashiCorp's customizations.

Installation
------------
Add this line to the Gemfile:

```ruby
gem 'middleman-hashicorp', github: 'hashicorp/middleman-hashicorp'
```

And then run:

```shell
$ bundle
```


Usage
-----
To generate a new site, follow the instructions in the [Middleman docs][]. Then add the following line to your `config.rb`:

```ruby
activate :hashicorp
```

If you are a HashiCorp employee and are deploying a HashiCorp middleman site, you will probably need to set some options. Here is an example from Packer:

```ruby
activate :hashicorp do |h|
  h.version      = '0.1.0'
  h.bintray_repo = 'mitchellh/packer'
  h.bintray_user = 'mitchellh'
  h.bintray_key  = ENV['BINTRAY_API_KEY']

  # Filter packages
  h.bintray_exclude_proc = Proc.new do |os, filename|
    os == 'windows' # Exclude windows packages
  end

  # Packages are not product-prefixed
  # TODO: Remove this in the future...
  h.bintray_prefixed = false
end
```

As you see, this is just Ruby, so any credentials (such as API keys and passwords) should be read from the `ENV` hash. You can read more about the Bintray integration below.

Almost all other Middleman options may be removed from the `config.rb`. See a HashiCorp project for examples.


Customizations
--------------
### Default Options
- Syntax highlighting (via [middleman-syntax][]) is automatically enabled
- Asset directories are organized like Rails:
    - `assets/stylesheets`
    - `assets/javascripts`
    - `assets/images`
    - `assets/fonts`
- The Markdown engine is redcarpet (see the section below on Markdown customizations)
- During development, live-reload is automatically enabled
- During build, css, javascript and HTML are minified
- During build, assets are hashed
- During build, gzipped assets are also created

### Bintray
- If applicable, Bintray product versions are automatically downloaded during build. In development, a default HashiOS product is used to avoid API calls. If you have a Bintray API key, you can set the environment variable `FETCH_PRODUCT_VERSIONS` to query the API in development.

### Helpers
- `latest_version` - get the version specified in `config.rb` as `version`, but replicated here for use in views.

    ```ruby
    latest_version #=> "1.0.0"
    ```

- `system_icon` - use vendored image assets for a system icon

    ```ruby
    system_icon(:windows) #=> "<img src=\"/images/icons/....png\">"
    ```

- `arch_for_filename` - get the arch out of a URL or filename (bintray)

    ```ruby
    arch_for_filename('/packer_darwin_amd64.zip') #=> "amd64"
    ```

### Markdown
This extension extends the redcarpet markdown processor to add some additional features:

- Auto-linking of code anchor tags
- Autolinking of URLs
- Fenced code blocks
- Tables
- TOC data
- Strikethrough
- Superscript

### Bootstrap
Twitter Bootstrap (3.x) is automatically bundled. Simply activate it it in your CSS and Javascript:

```scss
@import 'bootstrap-sprockets';
@import 'bootstrap';
```

```javascript
//= require jquery
//= require bootstrap
```

Contributing
------------
1. [Fork it](https://github.com/hashicorp/middleman-hashicorp/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[Middleman]: http://middlemanapp.com/
[Middleman docs]: http://middlemanapp.com/basics/getting-started/
[middleman-syntax]: http://github.com/middleman/middleman-syntax/
