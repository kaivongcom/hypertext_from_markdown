# require "builder"

#class MarkdownIntoHypertext
class MyMarkdownToHypertextParser
	attr_reader :results

	def initialize(markdown_text, attrs_hash={})
		attrs = {}
		element_name, attrs[:class], attrs[:title] = attrs_hash[:element_name], attrs_hash[:attr_class], attrs_hash[:link_title]
		@markdown_text = markdown_text.chomp
		find_links(markdown_text)
		find_emphasis(markdown_text)
		length = @markdown_text.scan(/\n/).count
		markdown_obj = { text: @markdown_text, length: length }
		@results = wrap_markdown(element_name, markdown_obj, attrs)
	end

	def find_emphasis(markdown_text)
		em_matches = markdown_text.match(/\*(.*)\*/)
		em_html(em_matches) if em_matches
	end

	def em_html(em_matches)
		html_em = "<em>#{em_matches[1]}</em>"
		@markdown_text.gsub!(em_matches[0], html_em)
	end

	def find_links(markdown_text)
		link_matches = markdown_text.match(/\[(.*)\]\((.*)\)/)
		link_html(markdown_text, link_matches) if link_matches
	end

	def wrap_markdown(element, markdown, attrs)
		if element == false || (element == false && @markdown_text[1] == 'a')
			@markdown_text
		elsif element == true
			if @markdown_text.match(/^#|====/)
				header_html(markdown)
			else
				paragraph_html(markdown, attrs)
			end
		elsif element
			if @markdown_text.match(/^#|====/)
				header_html(markdown)
			else
				wrap_html(markdown, element, attrs)
			end
		end
	end

	def split_title_arr(match_data)
		attrs, title  = {}, match_data[2].split(' ')
		attrs['href'] = title[0]
		title = title[1..-1].join(' ')
		title.split(' ')
		title = title.length > 1 ? title.to_s : ''
		attrs['title'] = title if (title.length > 1)
		attrs
	end

	def link_html(text, match_data)
		full_link = text.match(/\[(.*)\)/)[0]
		attrs = split_title_arr(match_data)
		text = match_data[1]
		element_attrs = attrs.collect { |attr, value| " #{attr}=\"#{value.gsub("'",'')}\"" }.join('')
		link_text = "<a#{element_attrs}>#{text}</a>"
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

	def wrap_html(obj, element_name, attrs)
		# element_attrs = ''
		# attr_class && ['span','p'].include?(element_name) ? element_attrs=" class=""#{attr_class}"""  : ''
		element_attrs = ''
		element_attrs = " class=""#{attrs[:class]}""" if attrs[:class]
		obj[:text].split("\n").collect do |element_text|
			"<#{element_name}#{element_attrs}>#{element_text}</#{element_name}>"
		end.join
	end

	def paragraph_html(obj, attrs)
		wrap_html(obj, 'p', attrs)
	end
end

def tests_for_parser
	markdown = "\nA Second Level Header\n---------------------\nNow is the time for all good men to come to\nthe aid of their country. This is just a\nregular paragraph.\n\nThe quick brown fox jumped over the lazy\ndog's back.\n\n> ## This is an H2 in a blockquote"
	MyMarkdownToHypertextParser.new(markdown).results
end

tests_for_parser()
