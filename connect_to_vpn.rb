require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = "http://www.freecloudvpn.com"
doc = Nokogiri::HTML(open(url))
password = nil

	puts "Connecting to FreeCloudVPN.com"

doc.css(".col-one").each do |para|
	paragraph = para.at_css("p:nth-child(8)")
	File.open("output.txt", "w") do |f|
		f.puts "#{paragraph}"
	end
	line_num = 0
	content = File.open('output.txt').read
	content.gsub!(/\r\n/,"\n")
	password_line =nil
	content.each_line do |line|
		if(line_num == 3)
			password_line = "#{line}"
		end
		line_num = line_num +1
	end
	if(password_line != nil)
		password_part = password_line.split("\s")[3]
		password = password_part.split("<")[0]
	end
end
	puts "Logging in.."
File.open("/etc/NetworkManager/system-connections/VPN", "w") do |f|
	f.puts "[connection]
	id=VPN
	uuid=144b9f8f-8d7d-499e-9161-7769ccd4035f
	type=vpn
	autoconnect=false
	timestamp=1401084497

	[vpn]
	service-type=org.freedesktop.NetworkManager.pptp
	gateway=uk.freecloudvpn.com
	require-mppe=yes
	user=freecloudvpn.com
	refuse-eap=yes
	refuse-chap=yes
	password-flags=0
	refuse-pap=yes

	[ipv4]
	method=auto

	[vpn-secrets]
	password=#{password}"
end
exec 'nmcli con up id VPN'
