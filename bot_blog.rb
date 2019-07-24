require 'open-uri'

u_agent = 'Mozilla/5.0 (platform; rv:geckoversion) Gecko/geckotrail Firefox/firefoxversion'
proxies = Array.new

open("https://www.proxy-list.download/api/v1/get?type=http"){|fp|
  proxies.append(fp.read.split("\r\n"))
}

proxies.flatten! #set the array to 1 dimension
tmp = ''
counter = 0
time = Time.now.strftime("%H:%M").split(':')
if time[0].to_i >= 11
  dest = "#{time[0].to_i - 10}:#{time[1]}}"
else
  dest = "#{time[0].to_i + 2}:#{time[1]}"
end

loop do
  begin
    curtime = Time.now.strftime("%H:%M")
    if curtime == dest
      proxies = Array.new
      open("https://www.proxy-list.download/api/v1/get?type=http"){|fp|
        proxies.append(fp.read.split("\r\n"))
      }
    else
      puts("#{curtime} - #{dest}")
      proxy = proxies[rand(0...proxies.size)]
      while proxy == tmp do #use another proxy if has been used before for fixing connection issue
        proxy = proxies[rand(0...proxies.size)]
      end
      open(
        'https://lfnugraha.blogspot.com/',
        proxy: URI.parse("http://#{proxy}"),
        :open_timeout => 5, #set timeout for connecting
        :read_timeout => 3,
        'User-Agent' => u_agent
      ){|page|
        counter += 1
        puts "#{proxy} : #{page.status[1]} [#{counter}]"
      }
      tmp = proxy
    end
  rescue Timeout::Error
    puts "Timeout on #{proxy}"
  rescue Interrupt => e
    puts "Done..."
    exit
  rescue Exception => e
    proxies.delete(proxy)
    puts "#{e} on #{proxy}, deleted"
  end
end
