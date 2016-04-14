#!/usr/bin/ruby -w

require 'nokogiri'
require 'open-uri'

totalPages=53


fmt = "%s\t%s\t%s\n"
printf(fmt, "Riding", "Party", "Email")


(1..totalPages).each { |page|

start = Time.now

doc = Nokogiri::HTML(open("http://www.elections.ca/WPAPPS/WPR/EN/EDA/Details?province=-1&distyear=2013&district=-1&party=-1&appstatus=-1&pageno=#{page}&totalpages=#{totalPages}&totalcount=1301&viewall=1"))

ns = doc.xpath("//fieldset[@class='wpr-detailgroup wpr-fieldset-group']/div[@class='wpr-details']/div[@class='wpr-detailsbody']")

if ns.count != 25 && page < totalPages
    puts "We did not get 25 node set for page #{page}"
    exit 1
else
    #puts "We got #{ns.count} nodes"
end

ns.each { |n|
    hqNode = n.xpath("./div[@class='wpr-detailsleftcol']/div[2]/fieldset");

    email = hqNode.xpath("./a[1]").text

    ppNode = n.xpath("./div[@class='wpr-detailsleftcol']/div[3]");

    party = ppNode.text.split("\r\n")[2].strip

    edNode = n.xpath("./div[@class='wpr-detailsleftcol']/div[4]");

    ed = edNode.text.split("\r\n")[2].split("\302\240")[0].strip

    printf(fmt, ed, party, email)
}

done = Time.now

sleepTime = 1.0 + (done - start)

$stderr.puts "Sleeping #{sleepTime} seconds"

sleep(sleepTime)

}
