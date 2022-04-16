require_relative "create_mapping"
require "json"

def read_bibxml(file)
  # hack for broken xml files with content like:
  # <author initials='Carol' surname='O'Connor' fullname='Carol O'Connor'><organization /></author>
  "<?xml version='1.0' encoding='UTF-8'?>#{
    File.readlines(file).select { |l| l.include?('seriesInfo') || l.include?('reference') }.join}"
end

STDERR.puts "reading bibxml5 library..."
bibxml_mapping = Dir["/tmp/bibxml-to-relaton-3gpp/bibxml5/reference.3GPP*.xml"]
                   .sort_by { |x| File.mtime(x) }.map do |f|
  [File.basename(f), CreateMapping.series_info_value_from_bibxml(read_bibxml(f))]
rescue REXML::ParseException, NoMethodError => e
  raise "File #{f} parsing error: #{e}"
end.to_h

warn "reading relaton-data-3gpp library..."
relaton_mapping = Dir["/tmp/bibxml-to-relaton-3gpp/relaton-data-3gpp-main/data/*"]
                    .sort_by { |x| File.mtime(x) }.map do |f|
  [File.basename(f), CreateMapping.source_docid_from_relaton(File.read(f))]
end.to_h

warn "creating map..."
map = CreateMapping.new(bibxml_mapping, relaton_mapping)

if ARGV.empty?
  map.mapping.each do |mapping|
    puts mapping.to_yaml unless mapping.pubid.nil?
  end
else
  case ARGV[0]
  when "--to-json"
    res = { mapping: map.mapping.reject { |m| m.pubid.nil? } }
    puts res.to_json
  when "--missing"
    map.mapping.each do |mapping|
      puts "missing #{mapping.source} to relaton-data-3gpp" if mapping.pubid.nil?
    end
  end
end
