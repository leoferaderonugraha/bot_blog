require 'open-uri'
#require 'pry'

#test output on heroku
puts "Hello Rion"


u_agent = 'Mozilla/5.0 (platform; rv:geckoversion) Gecko/geckotrail Firefox/firefoxversion'
proxies = Array.new

open("https://www.proxy-list.download/api/v1/get?type=http"){|fp|
  proxies.append(fp.read.split("\r\n"))
}

proxies.flatten! #set the array to 1 dimension
tmp = ''
counter = 0
time = Time.now.strftime("%I:%M:%S").split(':')
if time[0].to_i >= 11 #set reminder to 2 hours in 12 
  dest = "#{time[0].to_i - 10}:#{time[1].to_i + 1}:#{time[2].to_i}".split(':')
else
  dest = "#{time[0].to_i + 2}:#{time[1].to_i}:#{time[2].to_i}".split(':')
end

loop do
  begin
    curtime = Time.now.strftime("%I:%M:%S").split(':')
    curtime = "#{curtime[0].to_i}:#{curtime[1].to_i}:#{curtime[2].to_i}".split(':')
    if (curtime[0] == dest[0] && curtime[1] == dest[1] && curtime[2].to_i.between?(0,dest[2].to_i)) \
        || proxies.nil?  #if it's hit our 2 hours reminder or proxies is empty
      puts "Updating proxies..."
      proxies = Array.new
      open("https://www.proxy-list.download/api/v1/get?type=http"){|fp|
        proxies.append(fp.read.split("\r\n"))
      }
      proxies.flatten!
      #binding.pry
      #sleep 30
    end
    puts("[#{curtime}] - [#{dest}]")
    proxy = proxies[rand(0...proxies.size)]
    while proxy == tmp do #use another proxy if has been used before for fixing connection issue
      proxy = proxies[rand(0...proxies.size)]
    end
    open(
      'https://lfnugraha.blogspot.com/',
      proxy: URI.parse("http://#{proxy}"),
      :open_timeout => 3, #set timeout for connecting
      :read_timeout => 3,
      'User-Agent' => u_agent
    ){|page|
      counter += 1
      puts "#{proxy} : #{page.status[1]} [#{counter}]"
    }
    tmp = proxy
  rescue Timeout::Error
    proxies.delete(proxy)
    puts "Timeout on #{proxy}, deleted"
  rescue Interrupt
    puts "Done..."
    exit
  rescue SignalException => e
    puts "#{e}, bye..."
    exit
  rescue Exception => e
    proxies.delete(proxy)
    puts "#{e} on #{proxy}, deleted"
  end
end
