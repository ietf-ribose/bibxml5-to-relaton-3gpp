require "rexml"
require "yaml"
require_relative "mapping"

SOURCE="bibxml-nist"
DESTINATION="relaton-data-nist-main"

class CreateMapping
  attr_accessor :bibxml_mapping, :relaton_mapping

  def initialize(bibxml_mapping, relaton_mapping)
    @bibxml_mapping = bibxml_mapping
    @relaton_mapping = relaton_mapping
  end

  def self.series_info_value_from_bibxml(content)
    element = REXML::Document.new(content).get_elements("reference/seriesInfo").first
    "#{element.attributes["name"].gsub('3GPP ', '')} #{element.attributes["value"]}"
  end

  def series_info_value_to_relaton_filename(value)
    # matches = /(?<number>\d+\.\d+) (?<rel>\d)\.(?<revision>[\d.]+)/.match(value)
    matches = /(?<serie>TR|TS) (?<number>\d+\.[\da-z-]+)(?: (?<rel>\d)\.(?<revision>[\d.]+))?/.match(value)
    # use mapping here
    @relaton_mapping.each do |filename, docid|
      if matches[:revision]
        next unless docid.include?("3GPP #{matches[:serie]} #{matches[:number]}") &&
          docid.include?("#{matches[:rel]}\.#{matches[:revision]}")
        # next unless /^3GPP #{matches[:serie]} #{matches[:number]}.*#{matches[:rel]}\.#{matches[:revision]}/.match?(docid)
      else
        next unless docid.include?("3GPP #{matches[:serie]} #{matches[:number]}")
        # next unless /^3GPP #{matches[:serie]} #{matches[:number]}/.match?(docid)
      end
      return filename
    end

    warn "no matches found for #{value}"
    nil
  end

  def self.doi_from_relaton(content)
    YAML.load(content)["docid"].select { |d| d["type"] == "DOI" }.first["id"]
  end

  def self.source_from_bibxml(content)
    REXML::Document.new(content).get_elements("reference")
      .first.attributes["target"]
  end

  def self.source_docid_from_relaton(content)
    yaml_content = YAML.load(content)
    yaml_content["docid"].select { |d| d["type"] == "3GPP" && d.key?("primary") }.first["id"]
  end

  def mapping
    @bibxml_mapping.map do |bibxml_file, series_info_value|
      relaton_filename = series_info_value_to_relaton_filename(series_info_value)
      # return nil unless relaton_filename

      mapping = Mapping.new(bibxml_file, relaton_filename ? @relaton_mapping[relaton_filename] : nil)
      # hack: delete matched keys to speedup regexps
      # @relaton_mapping.delete(relaton_filename)
      mapping
    rescue NoMethodError => e
      raise "File #{bibxml_file} parsing error: #{e}"
    end
  end

  def lookup_source_by(doi)
    nil
  end
end
