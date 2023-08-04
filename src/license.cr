require "yaml"

class License
  VERSION = "0.1.0"

  include YAML::Serializable

  getter title : String
  @[YAML::Field(key: "spdx-id")]
  getter spdx_id : String
  getter nickname : String?
  getter description : String
  getter used_by : Hash(String, String)
  # TODO: make these enums
  getter permissions : Array(String)
  getter conditions : Array(String)
  getter limitations : Array(String)

  private def initialize(@title, @spdx_id, @nickname, @description, @used_by,
                         @permissions, @conditions, @limitations)
  end
end
