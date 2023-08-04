require "ecr/macros"
require "yaml"

# A simple class interface for managing licenses.
class License
  VERSION = "0.1.0"

  # A tuple of all available licenses.
  IDENTIFIERS = {
    "0bsd",
    "afl-3.0",
    "agpl-3.0",
    "apache-2.0",
    "artistic-2.0",
    "bsd-2-clause",
    "bsd-3-clause-clear",
    "bsd-3-clause",
    "bsd-4-clause",
    "bsl-1.0",
    "lgpl-2.1",
    "lgpl-3.0",
    "mit-0",
    "mit",
    "mpl-2.0",
    "wtfpl",
  }

  include YAML::Serializable

  @[Flags]
  enum Permissions
    COMMERCIAL_USE
    DISTRIBUTION
    MODIFICATIONS
    PATENT_USE
    PRIVATE_USE
  end

  @[Flags]
  enum Conditions
    DOCUMENT_CHANGES
    DISCLOSE_SOURCE
    INCLUDE_COPYRIGHT
    INCLUDE_COPYRIGHT_SOURCE
    NETWORK_USE_DISCLOSE
    SAME_LICENSE
    SAME_LICENSE_FILE
    SAME_LICENSE_LIBRARY
  end

  @[Flags]
  enum Limitations
    LIABILITY
    PATENT_USE
    TRADEMARK_USE
    WARRANTY
  end

  # An array of all available licenses. This can only be used after running the `License.init` method
  # which will load all available licenses at compile time. Attempting to use this method before
  # loading will raise an exception.
  class_getter licenses : Array(License) { raise "Licenses were not compiled with License.init" }

  # The title of the license.
  getter title : String

  # The SPDX license identifier. See https://spdx.org/licenses/ for more information.
  @[YAML::Field(key: "spdx-id")]
  getter spdx_id : String

  # The nickname of the license. This is generally a variation of the license name or SPDX identifier.
  getter nickname : String?

  # The description of the license.
  getter description : String

  # A hash of sources that use the license.
  @[YAML::Field(key: "using")]
  getter used_by : Hash(String, String)

  # A `Permissions` enum containing the permissions for the license.
  getter permissions : Permissions

  # A `Conditions` enum containing the conditions permitted by the license.
  getter conditions : Conditions

  # A `Limitations` enum containing the limitations enforced by the license.
  getter limitations : Limitations

  # The license content (or body).
  @[YAML::Field(ignore: true)]
  getter body : String { raise "unreachable" }

  # Loads all available licenses at compile time and initializes the `licenses` method.
  # This method must be ran *before* attempting to use the `licenses` method.
  def self.init : Nil
    @@licenses = load_all
  end

  # :nodoc:
  def self.unsafe_load(source : String)
    _, data, content = source.split "---\n", 3
    license = from_yaml data
    pointerof(license.@body).value = content.strip

    license
  end

  # Renders the license content and returns a string. If the *year* or *author* parameters are not
  # specified, a default will be rendered in place.
  #
  # ```
  # license = License.load "mit"
  # license.render year: 2023 # => "MIT License ..."
  # ```
  def render(*, year = nil, author = nil) : String
    String.build { |io| self.render(io, year: year, author: author) }
  end

  # Renders the license content to the *io*. If the *year* or *author* parameters are not
  # specified, a default will be rendered in place.
  #
  # ```
  # io = IO::Memory.new
  # license = License.load "mit"
  # license.render io, year: 2023
  # io.to_s # => "MIT License ..."
  # ```
  def render(io : IO, *, year = nil, author = nil) : Nil
    year ||= "<enter the year here>"
    author ||= "<enter the author here>"
    io << body.gsub("<%= year %>", year).gsub("<%= author %>", author)
  end

  # Loads a license by its SPDX identifier at compile time. If the license is not found, the
  # program will not compile.
  #
  # ```
  # License.load "0bsd" # => #<License:0x...>
  # License.load "asdf" # => Error: Unknown license SPDX-ID: asdf
  # ```
  macro load(id)
    {% if IDENTIFIERS.includes?(id) %}
      License.unsafe_load {{ read_file("./src/licenses/#{id.id}.txt") }}
    {% else %}
      {% id.raise "Unknown license SPDX-ID: #{id.id}" %}
    {% end %}
  end

  # Returns an array of licenses loaded by their SPDX identifiers at compile time. If one of the
  # licenses are not found, the program will not compile.
  #
  # ```
  # License.load "0bsd", "agpl-3.0" # => [#<License:0x...>, #<License:0x...>]
  # License.load "asdf"             # => Error: Unknown license SPDX-ID: asdf
  # ```
  macro load(*ids)
    [{% for id in ids %}
      License.load({{ id }}),
    {% end %}]
  end

  # Returns an array of all available licenses loaded at compile time.
  macro load_all
    [{% for key in IDENTIFIERS %}
      License.unsafe_load({{ read_file("./src/licenses/#{key.id}.txt") }}),
    {% end %}]
  end

  # Returns a string of the license rendered at compile time. If the license is not found, the
  # program will not compile.
  #
  # ```
  # License.render "mpl-2.0", year: 2023 # => "Mozilla Public License Version 2.0 ..."
  # License.render "asdf", year: 2023    # => Error: Unknown license SPDX-ID: asdf
  # ```
  macro render(id, *, year = nil, author = nil)
    {% if IDENTIFIERS.includes?(id) %}
      year = {{ year || "<enter the year here>" }}
      author = {{ author || "<enter the author here>" }}

      %data = ECR.render {{ "./src/licenses/#{id.id}.txt" }}
      %data.split("---\n", 3).last.strip
    {% else %}
      {% id.raise "Unknown license SPDX-ID: #{id.id}" %}
    {% end %}
  end
end
