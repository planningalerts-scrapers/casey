require 'scraperwiki'
require 'mechanize'

agent = Mechanize.new

def scrape_page(page, url)
  table = page.at("tbody")
  table.search("tr")[0..-1].each do |tr|
    day, month, year = tr.search("td")[3].inner_text.split(" ")
    month_i = Date::MONTHNAMES.index(month.strip)

    # Occasionally we get a leading nbsp character (ascii 160)
    day = day.gsub(/[[:space:]]/, '')

    record = {
      "info_url" => url,
      "comment_url" => url,
      "council_reference" => tr.at("td a").inner_text.split("(")[0],
      "on_notice_to" => Date.new(year.to_i, month_i, day.to_i).to_s,
      "address" => tr.search("td")[1].inner_text + ", VIC",
      "description" => tr.search("td")[2].inner_text,
      "date_scraped" => Date.today.to_s
    }
    
    # Check if record already exists
    if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
      ScraperWiki.save_sqlite(['council_reference'], record)
    else
      puts "Skipping already saved record " + record['council_reference']
    end
  end
end


url = "http://www.casey.vic.gov.au/building-planning/planning-documents-on-exhibition/Advertised-planning-applications/A-C"
page = agent.get(url)
puts "Scraping page A-C..."
scrape_page(page, url)

url = "http://www.casey.vic.gov.au/building-planning/planning-documents-on-exhibition/Advertised-planning-applications/D-K"
page = agent.get(url)
puts "Scraping page D-K..."
scrape_page(page, url)

url = "http://www.casey.vic.gov.au/building-planning/planning-documents-on-exhibition/Advertised-planning-applications/L-Z"
page = agent.get(url)
puts "Scraping page L-Z..."
scrape_page(page, url)
