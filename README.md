# license

A simple shard for using and managing licenses in your Crystal project. All licenses have been made available via the [choosealicense.com repository](https://github.com/github/choosealicense.com) by GitHub and is freely available under the MIT license.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     license:
       github: devnote-dev/license
   ```

2. Run `shards install`

> **Warning**
> This shard only works with Crystal version 1.9.0 and above. This is due to how enum members are parsed from certain string formats.

## Usage

Licenses are loaded at compile time depending on the methods you use. [Click here](/src/licenses/) for the full list of available licenses.

A single license can be loaded using the `License.load` method:

```crystal
require "license"

license = License.load "mit" # case-insensitive!
```

This will return a license instance which contains the license contents as well as metadata about the license such as the title, SPDX identifier, description and more. See [license.cr](/src/license.cr) for available methods.

Multiple licenses can be loaded using the same method, which will return an array of the license instances:

```crystal
licenses = License.load "bsd-2-clause", "bsd-3-clause"
# => [#<License:0x...>, #<License:0x...>]
```

> **Warning**
> Unknown licenses will cause a compilation error.

You can also get all available licenses at runtime by using the `License.init` method then access them via `License.licenses`:

```crystal
License.init # loads everything at compile time
License.licenses # => [#<License:0x...>, ...]
```

If you wish to do this yourself then you can use the `License.load_all` macro method which will return an array of all available licenses.

### Rendering

Licenses can be rendered at compile time or at runtime via the `License.render` macro or `License#render` instance method.

```crystal
# via macro
License.render "mpl-2.0", year: 2023, author: "devnote-dev"
# => "Mozilla Public License Version 2.0 ..."

# via instance method
license = License.load "mpl-2.0"
license.render year: 2023, author: "devnote-dev"
# => "Mozilla Public License Version 2.0 ..."
```

Keep in mind that the `render` macro method can also raise a compile time error like the other macro methods if the license is not found.

## Contributing

1. Fork it (<https://github.com/devnote-dev/license/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Devonte W](https://github.com/devnote-dev) - creator and maintainer

This repository is managed under the MIT license.

© 2023 devnote-dev
