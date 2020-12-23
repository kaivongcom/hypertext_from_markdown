#class ITS_NOW_HTML
class MyMarkdownToHypertextParser
	attr_reader :results

	def initialize(markdown_text, element_name=true)
		@markdown_text = markdown_text.chomp
		link_matches = markdown_text.match(/\[(.*)\]\((.*)\)/)
		link_html(markdown_text, link_matches) if link_matches
		length = @markdown_text.scan(/\n/).count
		markdown_obj = { text: @markdown_text, length: length }
		if @markdown_text[1] == 'a' || element_name == false
			@results = @markdown_text
		elsif element_name != true
			@results = @markdown_text.match(/^#|====/) ? header_html(markdown_obj) : wrap_html(markdown_obj, element_name)
		else
			@results = @markdown_text.match(/^#|====/) ? header_html(markdown_obj) : paragraph_html(markdown_obj)
		end
	end

	def link_html(text, match_data)
		element = 'a'
		full_link = text.match(/\[(.*)\)/)[0]
		text = match_data[1]
		url_data = match_data[2].split(' ')
		link = url_data[0]
		attr_text = url_data[1..-1].join(' ').gsub("\\",'').gsub("'",'"')
		link_text = "<#{element} href='#{link}' title=#{attr_text}>#{text}</#{element}>"
		@markdown_text.gsub!(full_link, link_text)
	end

	def single_header_html(text)
		strip_length = text.scan('#').length
		element = "h#{strip_length}"
		plain_text = text[strip_length..-1].strip
		"<#{element}>#{plain_text}</#{element}>"
	end

	def multi_header_html(text)
		single_header_html '#' + text.split("\n")[0]
	end

	def header_html(obj)
		if obj[:length] == 0
			single_header_html(obj[:text])
		elsif obj[:length] == 1
			multi_header_html(obj[:text])
		end
	end

	def wrap_html(obj, element_name)
		element_name == 'span' ? element_attr=' class="line-break"' : ''
		obj[:text].split("\n").collect do |element_text|
			"<#{element_name}#{element_attr}>#{element_text}</#{element_name}>"
		end.join
	end

	def paragraph_html(obj)
		obj[:text].split("\n").collect do |element_text|
			"<p>#{element_text}</p>"
		end.join
	end
end

def tests_for_parser
	markdown = "\nA Second Level Header\n---------------------\nNow is the time for all good men to come to\nthe aid of their country. This is just a\nregular paragraph.\n\nThe quick brown fox jumped over the lazy\ndog's back.\n\n> ## This is an H2 in a blockquote"
	MyMarkdownToHypertextParser.new(markdown).results
end

tests_for_parser()
