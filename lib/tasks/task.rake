namespace :scrape do
  #6069
  task :gag_init => :environment do
    home_gag_url = "http://9gag.tv/"
    get_gag_json(home_gag_url, 50)
  end

  task :gag_update => :environment do
    channels = ["prank", "cute", "music", "movie-and-tv", "nsfw"]
    channels.each do |channel|
      home_gag_url = "http://9gag.tv/channel/#{channel}"
      get_gag_json(home_gag_url, 1)
    end
  end

  def get_gag_json(home_gag_url, frequency)
    require 'open-uri'
    require 'json'

    browser = open(home_gag_url).read
    html_doc = Nokogiri::HTML(browser)

    data_index_key = html_doc.css('#jsid-video-post-grid-container').attr('data-index-key')
    data_ref_id = html_doc.css('#jsid-video-post-grid-container').attr('data-ref-id')

    inner_gag_url = "http://9gag.tv/api/index/"+ data_index_key + "?ref_key=" + data_ref_id + "&count=50&direction=1&includeSelf=1"


    for i in 1..frequency do
      puts i

      browser2 = JSON.parse open(inner_gag_url).read
      browser2["data"]["posts"].each do |post|
        if post["sourceUrl"].match(/youtube/)
          puts post["videoExternalId"]
          create_gag_video(post["ogTitle"], post["videoExternalId"])
          data_ref_id = post['hashedId']
        end
      end
      inner_gag_url = "http://9gag.tv/api/index/LJEGX?ref_key=" + data_ref_id + "&count=50&direction=1&includeSelf=0"
    end
  end

  def create_gag_video(title, youtube_code)
    YoutubeUrl.create(title: title, youtube_code: youtube_code)
  end
#--------------------------------------------------------------------------------------------------------------
  #2024
  task :buzz_init => :environment do
    get_buzz_url(25)
  end

  task :buzz_update => :environment do
    get_buzz_url(1)
  end

  def get_buzz_url(frequency)
    require 'open-uri'
    require 'nokogiri'

    for i in 1..frequency
      puts i

      url = "http://www.buzzfeed.com/videos?p=" + i.to_s + "&r=1"
      browser = open(url).read
      html_doc = Nokogiri::HTML(browser)

      buzz_links = html_doc.css('li.posts-list__item.lede--stacked > div:nth-child(1).lede > div:nth-child(2).lede__body > h2:nth-child(1).lede__title.lede__title--medium > a:nth-child(1).lede__link')
      buzz_links.each do |link|
        title = link.text.strip
        buzz_url = "http://www.buzzfeed.com" + link.attr('href')
        get_buzz_rendered_html(title, buzz_url)
      end
    end
  end

  def get_buzz_rendered_html(title, buzz_url)
    require 'open-uri'
    require 'nokogiri'

    browser = open(buzz_url).read
    html_doc = Nokogiri::HTML(browser)
    youtube_link = html_doc.css('#video_buzz_element_ > span > a').text
    if youtube_link.match(/youtube/)
      youtube_code = youtube_link.split("http://www.youtube.com/v/")[1]
      puts youtube_code
      create_buzz_video(title, youtube_code)
    end
  end

  def create_buzz_video(title, youtube_code)
    YoutubeUrl.create(title: title, youtube_code: youtube_code)
  end
#--------------------------------------------------------------------------------------------------------------
  #4190
  task :up_init => :environment do
    get_up_url(500)
  end

  task :up_update => :environment do
    get_up_url(1)
  end

  def get_up_url(frequency)
    require 'open-uri'
    require 'nokogiri'

    skipped_page = []
    for i in 1..frequency
      puts "page " + i.to_s

      url = "http://www.upworthy.com/page/" + i.to_s
      tries = 0
      begin
        browser = open(url).read
        html_doc = Nokogiri::HTML(browser)
        up_links = html_doc.css('div > div > div.nugget a.nugget-image')
        up_links.each do |link|
        up_url = "http://www.upworthy.com" + link.attr('href')
        get_up_info(up_url)
      end
      rescue OpenURI::HTTPError => e
        puts e
        case e.io.status[0]
        when "404"
          tries += 1
          if tries < 3
            puts "Attempting to Retry..." + tries.to_s + "...In 5 Seconds"
            sleep 5
            retry
          else
            skipped_page.push(i)
            puts "Skipped the following page" + skipped_page.to_s
            abort("Error...Not Found...Website not found. Exit task")
          end
        else
          tries += 1
          if tries < 3
            puts "Attempting to Retry..." + tries.to_s + "...In 5 Seconds"
            sleep 5
            retry
          else
            skipped_page.push(i)
            puts "Error...Skipping"
            next
          end
        end
      end
    end
    puts "Skipped the following page " + skipped_page.to_s
  end

  def get_up_info(up_url)
    browser = open(up_url).read
    html_doc = Nokogiri::HTML(browser)

    if html_doc.css('div#nuggetBody > iframe').any?
      temp_link = html_doc.css('div#nuggetBody > iframe').attr('src').to_s
      if temp_link.match(/youtube/)
        youtube_link = html_doc.css('div#nuggetBody > iframe').attr('src').to_s
        youtube_link = youtube_link.split('?')[0]
        youtube_code = youtube_link[youtube_link.length - 11..youtube_link.length]
        puts youtube_code
        youtube_info_link = "https://gdata.youtube.com/feeds/api/videos/" + youtube_code + "?v=2"
        begin
          browser2 = open(youtube_info_link).read
          html_doc2 = Nokogiri::HTML(browser2)
          title = html_doc2.css('title')[0].text
          create_up_video(title, youtube_code)
        rescue OpenURI::HTTPError => e
          case e.io.status[0]
          when "403"
            puts "Error...Forbidden...Skipping Page"
            return 
          end
        end
      end
    end
  end

  def create_up_video(title, youtube_code)
    YoutubeUrl.create(title: title, youtube_code: youtube_code)
  end

  task :test => :environment do
    50.times do
      Test.create
    end
  end
end








