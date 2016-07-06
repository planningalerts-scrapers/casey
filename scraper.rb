require 'scraperwiki'
require 'mechanize'

<<<<<<< HEAD
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
=======
# Scraping from Masterview 2.0

def scrape_page(page, info_url_base, comment_url)
  page.at("table.rgMasterTable").search("tr.rgRow,tr.rgAltRow").each do |tr|
    tds = tr.search('td').map{|t| t.inner_html.gsub("\r\n", "").strip}
    day, month, year = tds[2].split("/").map{|s| s.to_i}
    record = {
      "info_url" => (page.uri + tr.search('td').at('a')["href"]).to_s,
      "council_reference" => tds[1],
      "date_received" => Date.new(year, month, day).to_s,
      "description" => tds[3].gsub("&amp;", "&").split("<br>")[1].squeeze(" ").strip,
      "address" => tds[3].gsub("&amp;", "&").split("<br>")[0].squeeze(" ").strip + ", NSW",
      "date_scraped" => Date.today.to_s,
      "comment_url" => comment_url
    }
    # p record
>>>>>>> 6ec0a0695c23cc740cf46dee674383516c83da72
    if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
      ScraperWiki.save_sqlite(['council_reference'], record)
    else
      puts "Skipping already saved record " + record['council_reference']
    end
  end
end

<<<<<<< HEAD

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
=======
# Implement a click on a link that understands stupid asp.net doPostBack
def click(page, doc)
  href = doc["href"]
  if href =~ /javascript:__doPostBack\(\'(.*)\',\'(.*)'\)/
    event_target = $1
    event_argument = $2
    form = page.form_with(id: "aspnetForm")
    form["__EVENTTARGET"] = event_target
    form["__EVENTARGUMENT"] = event_argument
    form.submit
  else
    # TODO Just follow the link likes it's a normal link
    raise
  end
end

url_base = "http://infomaster.griffith.nsw.gov.au/DATrackingUI/modules/applicationmaster/default.aspx"
info_url_base = url_base + "?page=wrapper&key="
url = url_base + "?page=found&1=thismonth&4a=10&6=F"
comment_url = "mailto:council@griffith.nsw.gov.au"

agent = Mechanize.new

# Read in a page
page = agent.get(url)

form = page.forms.first
button = form.button_with(value: "Agree")
form.submit(button)
# It doesn't even redirect to the correct place. Ugh
page = agent.get(url)
current_page_no = 1
next_page_link = true

while next_page_link
  puts "Scraping page #{current_page_no}..."
  scrape_page(page, info_url_base, comment_url)

  page_links = page.at(".rgNumPart")
  if page_links
    next_page_link = page_links.search("a").find{|a| a.inner_text == (current_page_no + 1).to_s}
  else
    next_page_link = nil
  end
  if next_page_link
    current_page_no += 1
    page = click(page, next_page_link)
  end
end
>>>>>>> 6ec0a0695c23cc740cf46dee674383516c83da72
