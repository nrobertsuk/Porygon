# encoding: utf-8

class Wolfram
	include Cinch::Plugin

	match /wa (.+)$/i

	def execute(m, query)
		return if ignore_nick(m.user.nick)

		begin
	 
			@url = open("http://api.wolframalpha.com/v2/query?appid=#{$WOLFRAMAPI}&input=#{CGI.escape(query)}")
			@url = Nokogiri::XML(@url)

			success = @url.xpath("//queryresult/@success").text

			input  = ""
			output = ""

			more  = shorten_url("http://www.wolframalpha.com/input/?i=#{CGI.escape(query)}")

			if success == "true"
				input  = @url.xpath("//pod[@position='100']//plaintext[1]").text.gsub(/\s+/, ' ')
				output = @url.xpath("//pod[@position='200']/subpod[1]/plaintext[1]").text.gsub(/\s+/, ' ')

				input  = input[0..140]+"..."  if input.length > 140
				output = output[0..140]+"..." if output.length > 140

				replaces = /\\:(\w{4})/.match(output)

				if replaces != nil
					replaces.captures.each do |uni|
						foo = [uni.hex].pack("U")

						output.gsub!("\\\:", '')
						output.gsub!(uni, foo)
					end
				end

				if output.length < 1 and input.length > 1
					reply = input + " => Can not render answer. Check link"
				elsif output.length < 1 and input.length < 1
					reply = "Fucked if I know"
				else
					reply = "#{input} => #{output}"
				end

			else
				reply = "Fucked if I know"
			end

			m.reply "Wolfram 07|\u000F %s 07|\u000F More info: %s" % [reply, more]
		rescue
			m.reply "Wolfram 07|\u000F Error"
		end
	end
end