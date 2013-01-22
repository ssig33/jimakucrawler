require 'bundler'
require 'fileutils'
require 'time'
FileUtils.cd File.expand_path(File.dirname(__FILE__))
Bundler.require

def first_id
  FileUtils.mkdir 'data' unless File.exist? 'data'
  n = Dir.glob('data/*.txt').sort.first
  if n
    n.split('/').last.split('.').first
  else
    '128'
  end
end

def crawl url
  retry_count = 0
  begin
    alice = Mechanize.new
    page = alice.get url
    id = url.split('/').last
    
    content = page.root.xpath("//*[@id='post-#{id}']/div/div").first.to_s
    title = page.root.xpath('//*[@class="entry-title"]').first['title']
    data = <<EOS
#{title}
----
#{id}
----
#{content}
EOS
    open("data/#{id}.txt", 'w'){|x| x.puts data}
    puts "saved #{id}:#{title} #{Time.now.to_s}"
    next_a = page.root.xpath("//*[@id='content']//td[@class='next']/a").first
    if next_a
      crawl next_a['href']
    end
  rescue
    if retry_count < 10
      retry_count += 1
      sleep 3
      retry
    end
  end
end

base_url = "http://o.x0.com/m/#{first_id}"
crawl base_url
