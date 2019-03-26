require 'scraperwiki'
require 'mechanize'
require 'json'

agent = Mechanize.new
url = "https://www.casey.vic.gov.au/api/planning-applications?_format=json&page=0"
page = agent.get(url)


_json = JSON.parse(page.body)
if ( _json['pager'] )
  for i in 0.._json['pager']['total_pages'] - 1 do
    puts "Scraping page " + (i+1).to_s + " of " + _json['pager']['total_pages'].to_s

    url = "https://www.casey.vic.gov.au/api/planning-applications?_format=json&page=" + i.to_s
    page = agent.get(url)
    _json = JSON.parse(page.body)

    _json['rows'].each do |row|

      record = {
        'council_reference' => row['application_number'].to_s.strip,
        'address'           => row['field_coc_address'].to_s.strip + ', ' + row['field_coc_suburb_ref'].to_s.strip,
        'description'       => row['field_coc_proposal'].to_s.strip,
        'info_url'          => 'https://www.casey.vic.gov.au/view-planning-applications',
        'comment_url'       => 'https://www.casey.vic.gov.au/contact-us',
        'date_scraped'      => Date.today.to_s,
        'on_notice_to'      => Date.parse(row['field_coc_date'].to_s).to_s.strip,
      }

      if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
        record['address'] = record['address'] + ', VIC'
        puts "Saving record " + record['council_reference'] + ", " + record['address']
#         puts record
        ScraperWiki.save_sqlite(['council_reference'], record)
      else
        puts "Skipping already saved record " + record['council_reference']
      end
    end
  end
else
  puts "Invalid JSON received"
end
