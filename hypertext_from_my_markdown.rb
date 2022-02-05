# html_from = ''
# require_relative "../helpers/#{html_from}/HTML_elements/"

class HypertextFromMyMarkdownParser < Object

	attr_reader :text
	# START_TABLE = '<table summary="">'

	def initialize(markdown_text, attrs_hash={})
		@attrs = {}
		element_name, @attrs[:class], @attrs[:title], @attrs[:href],@attrs[:id] = attrs_hash[:element_name], attrs_hash[:attr_class], attrs_hash[:link_title], attrs_hash[:href], attrs_hash[:attr_id]
		# @markdown_text = markdown_text.chomp
		# element_name = find_element(element_name, markdown_text) if element_name == nil
		# 
		# length = @markdown_text.scan(/\n/).count
		# markdown_obj = { text: @markdown_text, length: length }
		html_text = find_html_element(markdown_text)
		@text = html_text
	end

	def find_html_element(markdown_text)
		results = markdown_text
		# find_bold(markdown_text)
		# find_emphasis(markdown_text)
		results = surround_a_header(markdown_text) if results[0] == '#'
		# find_img(markdown_text)
		# find_links(markdown_text)
		# find_strong(markdown_text)
		# find_tables(markdown_text)
		results = surround_by_paragraph(results) if results[-1] == ' '
		results
	end

	def surround_a_header(text)
		text_arr = text.split('# ')
		header = text_arr[1].strip
		header_level = text_arr[0].scan('#').count + 1
		"<h#{header_level}>#{header}</h#{header_level}>"
	end

	def surround_by_paragraph(text)
		"<p>#{text.chop}</p>"
	end
end
	