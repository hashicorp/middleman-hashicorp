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
  h.name        = "packer"
  h.version     = "0.7.0"
  h.github_slug = "hashicorp/terraform"

  # Disable fetching release information - this is useful for non-product site
  # or local development.
  h.releases_enabled = false

  # Disable some extensions
  h.minify_javascript = false
end
```

Almost all other Middleman options may be removed from the `config.rb`. See a HashiCorp project for examples.

Now just run:

```shell
$ middleman server
```

and you are off running!

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

### IE Compatibility

There are bundled things that make IE behave nicely. Include them like this:

```html
<!--[if lt IE 9]>
  <%= javascript_include_tag "ie-compat" %>
<![endif]-->
```

### Inline SVGs

Getting SVGs out of the asset pipeline and into the DOM can be hard, but not
with the magic `inline_svg` helper!

```erb
<%= inline_svg "my-asset.svg" %>
```

It supports configuring the class, height, width, and viewbox.

### Turbolinks

Turbolinks highjack links on the same domain and use AJAX to dynamically update
only the changed content. This is used by many popular sites, including GitHub.
To enable turbolinks, include the javascript.

```js
// assets/javascripts/application.js
//= require turbolinks
```

### Mega Nav
HashiCorp has a consistent mega-nav used across all project sites. This is insertable into any document using the following:

```erb
<%= mega_nav :terraform %>
```

Additionally, you must import the CSS and Javascript:

```js
// assets/javascripts/application.js
//= require hashicorp/mega-nav
```

```scss
// assets/stylesheets/application.scss
@import 'hashicorp/mega-nav'
```

### Helpers
- `latest_version` - get the version specified in `config.rb` as `version`, but replicated here for use in views.

    ```ruby
    latest_version #=> "1.0.0"
    ```

- `system_icon` - use vendored image assets for a system icon

    ```ruby
    system_icon(:windows) #=> "<img src=\"/images/icons/....png\">"
    ```

- `pretty_os` - get the human name of the given operating system

    ```ruby
    pretty_os(:darwin) => "Mac OS X"
    ```

- `pretty_arch` - get the arch out of an arch

    ```ruby
    pretty_arch(:amd64) #=> "64-bit"
    ```

### Markdown
This extension extends the redcarpet markdown processor to add some additional features:

- Autolinking of URLs
- Fenced code blocks
- Tables
- TOC data
- Strikethrough
- Superscript

In addition to "standard markdown", the custom markdown parser supports the following:

#### Auto-linking Anchor Tags
Since the majority of HashiCorp's projects use the following syntax to define APIs, this extension automatically converts those to named anchor links:

```markdown
- `api_method` - description
```

Outputs:

```html
<ul>
  <li><a name="api_method" /><a href="#api_method"></a> - description</li>
</ul>
```

#### Auto-linking Header Tags

Header links will automatically generate linkable hrefs on hover. This can be used to easily link to sub-sections of a page. This _requires_ the following SCSS.

```scss
// assets/stylesheets/application.scss
@import 'hashicorp/anchor-links'
```

Any special characters are converted to an underscore (`_`).

#### Recursive Markdown Rendering
By default, the Markdown spec does not call for rendering markdown recursively inside of HTML. With this extension, it is valid:

```markdown
<div class="center">
  This will **be bold**!
</div>
```

#### Bootstrap Alerts
There are 4 custom markdown extensions that automatically create Twitter Bootstrap-style alerts:

- `=>` => `success`
- `->` => `info`
- `~>` => `warning`
- `!>` => `danger`

```markdown
-> Hey, you should know...
```

```html
<div class="alert alert-info" role="alert">
  <p>Hey, you should know...</p>
</div>
```

Of course you can use Markdown inside the block:

```markdown
!> This is a **really** advanced topic!
```

```html
<div class="alert alert-danger" role="alert">
  <p>This is a <strong>really</strong> advanced topic!</p>
</div>
```

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
