#class MarkdownIntoHypertext
class MyMarkdownToHypertextParser
	attr_reader :results

	def initialize(markdown_text, element_name=false, attr_class=false)
		@markdown_text = markdown_text.chomp
		find_links(markdown_text)
		length = @markdown_text.scan(/\n/).count
		markdown_obj = { text: @markdown_text, length: length }
		@results = wrap_markdown(element_name, markdown_obj, attr_class)
	end

	def find_links(markdown_text)
		link_matches = markdown_text.match(/\[(.*)\]\((.*)\)/)
		link_html(markdown_text, link_matches) if link_matches
	end

	def wrap_markdown(element,markdown, attr_class)
		if element == false || (element == false && @markdown_text[1] == 'a')
			@markdown_text
		elsif element == true
			@markdown_text.match(/^#|====/) ? header_html(markdown) : paragraph_html(markdown, attr_class)
		elsif element
			@markdown_text.match(/^#|====/) ? header_html(markdown) : wrap_html(markdown, element, attr_class)
		end
	end

	def link_html(text, match_data)
		element = 'a'
		full_link = text.match(/\[(.*)\)/)[0]
		text = match_data[1]
		attr_text = match_data[2].split(' ')
		link = attr_text[0]
		attr_text = attr_text[1..-1].join(' ').gsub("\\",'').gsub("'",'"')
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

	def wrap_html(obj, element_name, attr_class)
		element_attrs = ''
		attr_class && ['span','p'].include?(element_name) ? element_attrs=" class=\"#{attr_class}\""  : ''
		obj[:text].split("\n").collect do |element_text|
			"<#{element_name}#{element_attrs}>#{element_text}</#{element_name}>"
		end.join
	end

	def paragraph_html(obj, attr_class)
		wrap_html(obj, 'p', attr_class)
	end
end

def tests_for_parser
	markdown = "\nA Second Level Header\n---------------------\nNow is the time for all good men to come to\nthe aid of their country. This is just a\nregular paragraph.\n\nThe quick brown fox jumped over the lazy\ndog's back.\n\n> ## This is an H2 in a blockquote"
	MyMarkdownToHypertextParser.new(markdown).results
end

tests_for_parser()
