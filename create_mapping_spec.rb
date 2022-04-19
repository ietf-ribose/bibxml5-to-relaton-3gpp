require_relative "create_mapping"

RSpec.describe CreateMapping do
  let(:series_info_value_tr) { "TR 25.999 7.1.0" }
  let(:series_info_value_ts) { "TS 09.02dcs 3.0.0" }
  let(:relaton_docid_tr) { "3GPP TR 25.999:Rel-7/7.1.0" }
  let(:relaton_docid_ts) { "3GPP TS 09.02dcs:Ph1-DCS/3.0.0" }

  let(:bibxml_mapping) {
    { bibxml_filename_tr => series_info_value_tr,
      bibxml_filename_ts => series_info_value_ts,
      "reference.3GPP.33.917.xml" => "TR 33.917",
      "reference.3GPP.02.04.xml" => "TS 02.04 3.7.1",
      "reference.3GPP.29.949.xml" => "TS 29.949 0.1.0"
    }
  }

  let(:relaton_mapping) {
    { relaton_filename_tr => relaton_docid_tr,
      relaton_filename_ts => relaton_docid_ts,
      "TR_33.917_REL-6_0.0.1.yaml" => "3GPP TR 33.917:Rel-6/0.0.1",
      "TR_33.917_REL-6_0.0.2.yaml" => "3GPP TR 33.917:Rel-6/0.0.2",
      "TS_02.04_PH1_3.7.1.yaml" => "3GPP TS 02.04:Ph1/3.7.1",
      "TR_29.949_REL-12_0.1.0.yaml" => "3GPP TR 29.949:Rel-12/0.1.0"
      }
    # { relaton_filename => relaton_docid }
  }

  let(:relaton_filename_tr) { "TR_25.999_REL-7_7.1.0.yaml" }
  let(:bibxml_filename_tr) { "reference.3GPP.25.999.xml" }
  let(:relaton_filename_ts) { "TS_09.02DCS_PH1-DCS_3.0.0.yaml" }
  let(:bibxml_filename_ts) { "reference.SDO-3GPP.09.02dcs.xml" }

  let(:bibxml_content_tr) do
    <<~XML
      <?xml version='1.0' encoding='UTF-8'?>
      
      <reference anchor='3GPP.25.999'>
        <front>
        <title>High Speed Packet Access (HSPA) evolution; Frequency Division Duplex (FDD)</title>
        <author><organization>3GPP</organization></author>
        <date day='20' month='March' year='2008' />
        </front>
        
        <seriesInfo name='3GPP TR' value='25.999 7.1.0' />
        <format type='HTML' target='http://www.3gpp.org/ftp/Specs/html-info/25999.htm' />
      </reference>
    XML
  end

  let(:bibxml_content_ts) do
    <<~XML
      <?xml version='1.0' encoding='UTF-8'?>
      <reference anchor='SDO-3GPP.09.02dcs'>
      <front>
        <title>Mobile Application Part (MAP) Specification (DCS 1800)</title>
        <author><organization>3GPP</organization></author>
        <date day='03' month='March' year='1993' />
      </front>
  
      <seriesInfo name='3GPP TS' value='09.02dcs 3.0.0' />
      <format type='HTML' target='http://www.3gpp.org/ftp/Specs/html-info/0902dcs.htm' />
      </reference>
    XML
  end

  let(:relaton_content_tr) do
    <<~YAML
      ---
      id: 3GPPTR25.999-Rel-7/7.1.0
      title:
      - type: main
        content: High Speed Packet Access (HSPA) evolution; Frequency Division Duplex (FDD)
        format: text/plain
      link:
      - content: http://www.3gpp.org/ftp/Specs/archive/25_series/25.999/25999-710.zip
        type: src
      type: standard
      docid:
      - id: 3GPP TR 25.999:Rel-7/7.1.0
        type: 3GPP
        primary: true
      docnumber: TR 25.999:Rel-7/7.1.0
      date:
      - type: created
        value: '2008-03-20'
      - type: published
        value: '2008-03-20'
      - type: confirmed
        value: '2007-12-19'
      fetched: '2022-03-30'
      doctype: TR
    YAML
  end

  let(:relaton_content_ts) do
    <<~YAML
      ---
      id: 3GPPTS09.02dcs-Ph1-DCS/3.0.0
      title:
      - type: main
        content: Mobile Application Part (MAP) Specification (DCS 1800)
        format: text/plain
      link:
      - content: http://www.3gpp.org/ftp/Specs/archive/09_series/09.02dcs/0902dcs-300.zip
        type: src
      type: standard
      docid:
      - id: 3GPP TS 09.02dcs:Ph1-DCS/3.0.0
        type: 3GPP
        primary: true
      docnumber: TS 09.02dcs:Ph1-DCS/3.0.0
    YAML
  end

  subject { described_class.new(bibxml_mapping, relaton_mapping) }

  it "extracts seriesInfo value from bibxml file" do
    expect(described_class.series_info_value_from_bibxml(bibxml_content_tr)).to eq(series_info_value_tr)
    expect(described_class.series_info_value_from_bibxml(
      "<reference anchor='3GPP.33.917'><seriesInfo name='3GPP TR' value='33.917' /></reference>"))
      .to eq("TR 33.917")
  end

  it "converts seriesInfo value to relaton filename" do
    expect(subject.series_info_value_to_relaton_filename(series_info_value_tr)).to eq(relaton_filename_tr)
    expect(subject.series_info_value_to_relaton_filename(series_info_value_ts)).to eq(relaton_filename_ts)
    expect(subject.series_info_value_to_relaton_filename("TR 33.917")).to eq("TR_33.917_REL-6_0.0.1.yaml")
    expect(subject.series_info_value_to_relaton_filename("TS 02.04 3.7.1")).to eq("TS_02.04_PH1_3.7.1.yaml")
    expect(subject.series_info_value_to_relaton_filename("TS 29.949 0.1.0")).to eq("TR_29.949_REL-12_0.1.0.yaml")
  end

  it "extracts docid from relaton file" do
    expect(described_class.source_docid_from_relaton(relaton_content_tr)).to eq(relaton_docid_tr)
  end
  #
  it "create a map between bibxml and relaton docid" do
    expect(subject.mapping).to eq([Mapping.new(bibxml_filename_tr, relaton_docid_tr),
                                   Mapping.new(bibxml_filename_ts, relaton_docid_ts),
                                   Mapping.new("reference.3GPP.33.917.xml", "3GPP TR 33.917:Rel-6/0.0.1"),
                                   Mapping.new("reference.3GPP.02.04.xml", "3GPP TS 02.04:Ph1/3.7.1"),
                                   Mapping.new("reference.3GPP.29.949.xml", "3GPP TR 29.949:Rel-12/0.1.0")])
  end
end
