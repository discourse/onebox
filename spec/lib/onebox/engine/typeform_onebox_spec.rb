require 'spec_helper'

describe Onebox::Engine::TypeformOnebox do
  it 'Appends the embed widget param when is missing' do
    raw_preview = Onebox.preview('https://basvanleeuwen1.typeform.com/to/NzdRpx').to_s

    query_params = get_query_params(raw_preview)

    expect_to_have_embed_widget(query_params)
  end

  it 'Uses the URL as it is when the embed widget param is present' do
    raw_preview = Onebox.preview('https://basvanleeuwen1.typeform.com/to/NzdRpx?typeform-embed=embed-widget').to_s

    query_params = get_query_params(raw_preview)

    expect_to_have_embed_widget(query_params)
  end

  it 'Does not adds an ? when it is already present' do
    raw_preview = Onebox.preview('https://basvanleeuwen1.typeform.com/to/NzdRpx?').to_s

    query_params = get_query_params(raw_preview)

    expect_to_have_embed_widget(query_params)
  end

  def expect_to_have_embed_widget(query_params)
    embed_widget_params = 'typeform-embed=embed-widget'

    expect(query_params).to eq embed_widget_params
  end

  def get_query_params(raw_preview)
    preview = Nokogiri::HTML::DocumentFragment.parse(raw_preview)

    form_url = preview.css('iframe').first['src']
    URI::parse(form_url).query
  end
end
