require "ecr/macros"
require "yaml"

class License
  VERSION = "0.1.0"

  IDENTIFIERS = {
    "0bsd",
    "agpl-3.0",
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
  property! body : String

  def self.init : Nil
    @@licenses = load_all
  end

  def self.unsafe_load(source : String)
    _, data, content = source.split "---\n", 3

    license = from_yaml data
    license.body = content

    license
  end

  macro load(id)
    {% if IDENTIFIERS.includes?(id) %}
      License.unsafe_load {{ read_file("./src/licenses/#{id.id}.txt") }}
    {% else %}
      {% raise "Unknown license SPDX-ID: #{id.id}" %}
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
end
