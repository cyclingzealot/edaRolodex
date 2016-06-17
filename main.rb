#!/usr/bin/ruby -w

require 'nokogiri'
require 'open-uri'
#require 'byebug'


if ARGV[0].nil? or ARGV[1].nil? then
    $stderr.puts "Go to http://www.elections.ca/WPAPPS/WPR/EN/EDA , click search, then 'Next 25 >>' and tell me how many pages you see in the URL using $pages $count"
    puts ARGV
    exit 1
end

totalPages=ARGV[0].to_i
totalCount=ARGV[1].to_i
seperator="\t"

seperator=ARGV[2] if ! ARGV[2].nil?




fmt = "%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s\n"
printf(fmt, "Province", "Riding", "Party", "Email", "City HQ")


(1..totalPages).each { |page|

start = Time.now

doc = Nokogiri::HTML(open("http://www.elections.ca/WPAPPS/WPR/EN/EDA/Details?province=-1&distyear=2013&district=-1&party=-1&appstatus=-1&pageno=#{page}&totalpages=#{totalPages}&totalcount=#{totalCount}&viewall=1"))

ns = doc.xpath("//fieldset[@class='wpr-detailgroup wpr-fieldset-group']/div[@class='wpr-details']/div[@class='wpr-detailsbody']")

if ns.count != 25 && page < totalPages
    puts "We did not get 25 node set for page #{page}"
    exit 1
else
    #puts "We got #{ns.count} nodes"
end

ns.each { |n|
    hqNode = n.xpath("./div[@class='wpr-detailsleftcol']/div[2]/fieldset");

    provinceNode = hqNode.xpath('./span[@class="wpr-field"][1]');
    province    = provinceNode.text.split(',')[1].strip
    city    = provinceNode.text.split(',')[0].strip

    email = hqNode.xpath("./a[1]").text

    ppNode = n.xpath("./div[@class='wpr-detailsleftcol']/div[3]");

    party = ppNode.text.split("\r\n")[2].strip

    edNode = n.xpath("./div[@class='wpr-detailsleftcol']/div[4]");

    ed = edNode.text.split("\r\n")[2].split("\302\240")[0].strip

    printf(fmt, province, ed, party, email, city)
}

done = Time.now

sleepTime = 1.0 + (done - start)

$stderr.puts "Sleeping #{sleepTime} seconds"

sleep(sleepTime)

}
