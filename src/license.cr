require "ecr/macros"
require "yaml"

class License
  VERSION = "0.1.0"

  IDENTIFIERS = {
    "0bsd",
    "agpl-3.0",
  }

  include YAML::Serializable

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
  property! body : String

  def self.unsafe_load(source : String)
    _, data, content = source.split "---\n", 3

    license = from_yaml data
    license.body = content

    license
  end

  macro get_by_id(name)
    {% if IDENTIFIERS.includes?(name) %}
      License.unsafe_load {{ read_file("./src/licenses/#{name.id}.txt") }}
    {% else %}
      {% raise "Unknown license SPDX-ID: #{name.id}" %}
    {% end %}
  end

  macro find_by_id(name)
    {% name = name.downcase %}
    {% if key = IDENTIFIERS.find &.includes?(name) %}
      License.unsafe_load {{ read_file("./src/licenses/#{key.id}.txt") }}
    {% else %}
      nil
    {% end %}
  end
end
