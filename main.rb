#!/usr/bin/ruby -w

require 'nokogiri'
require 'open-uri'
#require 'byebug'

def generateFVCName(province, party, ed)
    partyShortName = case party
        when 'Bloc Québécois'                       then 'BQ'
        when 'Canadian Action Party'                then 'Action'
        when 'Christian Heritage Party of Canada'   then 'Christian'
        when 'Communist Party of Canada'            then 'Communist'
        when 'Conservative Party of Canada'         then 'Conservative'
        when 'Green Party of Canada'                then 'Green'
        when 'Liberal Party of Canada'              then 'Liberal'
        when 'Libertarian Party of Canada'          then 'Libertarian'
        when 'Marijuana Party'                      then 'Marijuana'
        when 'New Democratic Party'                 then 'New Democrat'
        when 'Progressive Canadian Party'           then 'PC'
        else 'Other'
    end

    provinceShortName = case province
        when 'Alberta'                      then 'Alberta'
        when 'British Columbia'             then 'BC'
        when 'Manitoba'                     then 'Manitoba'
        when 'New Brunswick'                then 'NB'
        when 'Newfoundland and Labrador'    then 'NFL'
        when 'Northwest Territories'        then 'NWT'
        when 'Nova Scotia'                  then 'NS'
        when 'Nunavut'                      then 'Nunavut'
        when 'Ontario'                      then 'Ontario'
        when 'Prince Edward Island'         then 'PEI'
        when 'Quebec'                       then 'Quebec'
        when 'Saskatchewan'                 then 'SK'
        when 'Yukon'                        then 'Yukon'
    end

    return "EDA #{provinceShortName} #{partyShortName} #{ed}"
end



if ARGV[0].nil? or ARGV[1].nil? then
    $stderr.puts %Q[Go to http://www.elections.ca/WPAPPS/WPR/EN/EDA , click "Find Assocations", then "Select All", then "View Selected".  Enter the url as an argument]
    puts ARGV
    exit 1
end

totalPages=ARGV[0].to_i
totalCount=ARGV[1].to_i
seperator="\t"

seperator=ARGV[2] if ! ARGV[2].nil?

fullBool=(ARGV[3] == 'full') if ! ARGV[3].nil?



fmt = "%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s\n"
if fullBool
    fmt = "%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s#{seperator}%s\n"
    printf(fmt, "Fair Vote Name", "EDA Name", "Province", "Riding", "Party", "Email", "HQ City", "HQ Address", "HQ Postal Code")
else
    printf(fmt, "Province", "Riding", "Party", "Email", "City HQ")
end


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

    fvcName = address = edaName = postalCode = '';
    if fullBool
        # Determine Fair Vote Name
        fvcName = generateFVCName province, party, ed

        # Fetch address
        address = hqNode.text.split("\n")[2].strip

        # Fetch eda name
        edaName = n.xpath("../../legend[@class='wpr-ltitle']").text.strip;

        # Fetch postal code
        postalCode = hqNode.xpath('./span[@class="wpr-field"][2]').text.strip;
    end


    if fullBool
        printf(fmt, fvcName, edaName, province, ed, party, email, city, address, postalCode)
    else
        printf(fmt, province, ed, party, email, city)
    end
}

done = Time.now

sleepTime = 1.0 + (done - start)

$stderr.puts "Sleeping #{sleepTime} seconds"

sleep(sleepTime)

}



