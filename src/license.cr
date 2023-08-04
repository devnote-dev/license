require "ecr/macros"
require "yaml"

class License
  VERSION = "0.1.0"

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

  class_getter licenses : Array(License) { raise "Licenses were not compiled with License.init" }

  getter title : String
  @[YAML::Field(key: "spdx-id")]
  getter spdx_id : String
  getter nickname : String?
  getter description : String
  @[YAML::Field(key: "using")]
  getter used_by : Hash(String, String)
  # TODO: make these enums
  getter permissions : Array(String)
  getter conditions : Array(String)
  getter limitations : Array(String)
  @[YAML::Field(ignore: true)]
  getter body : String { raise "unreachable" }

  def self.init : Nil
    @@licenses = load_all
  end

  def self.unsafe_load(source : String)
    _, data, content = source.split "---\n", 3

    license = from_yaml data
    pointerof(license.@body).value = content.strip

    license
  end

  def render(*, year = nil, author = nil) : String
    String.build { |io| self.render(io, year: year, author: author) }
  end

  def render(io : IO, *, year = nil, author = nil) : Nil
    year ||= "<enter the year here>"
    author ||= "<enter the author here>"
    io << body.gsub("<%= year %>", year).gsub("<%= author %>", author)
  end

  macro load(id)
    {% if IDENTIFIERS.includes?(id) %}
      License.unsafe_load {{ read_file("./src/licenses/#{id.id}.txt") }}
    {% else %}
      {% id.raise "Unknown license SPDX-ID: #{id.id}" %}
    {% end %}
  end

  macro load(*ids)
    [{% for id in ids %}
      License.load({{ id }}),
    {% end %}]
  end

  macro load_all
    [{% for key in IDENTIFIERS %}
      License.unsafe_load({{ read_file("./src/licenses/#{key.id}.txt") }}),
    {% end %}]
  end

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
