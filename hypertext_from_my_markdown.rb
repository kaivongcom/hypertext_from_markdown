# html_from = ''
# require_relative "../helpers/#{html_from}/HTML_elements/"
ENDING_INDEX = -1
STARTING_INDEX = 0
class HypertextFromMyMarkdownParser < Object

	attr_reader :text, :obj

	# START_TABLE = '<table summary="">'

	def initialize(markdown_text, attrs_hash={})
		@attrs = {}
		element_name, @attrs[:class], @attrs[:title], @attrs[:href],@attrs[:id] = attrs_hash[:element_name], attrs_hash[:attr_class], attrs_hash[:link_title], attrs_hash[:href], attrs_hash[:attr_id]
		# element_name = find_element(element_name, markdown_text) if element_name == nil
		# 
		# markdown_obj = { text: @markdown_text, length: length }
		html_text = find_html_element(markdown_text)
		@obj = create_object()
		@text = html_text
	end

	def create_object
		more = Hash.new
		# elements_count = @markdown_text.scan(/\n/).count 
		more[:elements_count] = 0 # read lines of hypertext elements?
		more[:text] = String.new
		hypertext_and_more = more
	end

	def find_html_element(markdown_text)
		results = markdown_text
		if results.strip.empty?
			# give a warning message?
			# find_bold(markdown_text)
			# find_emphasis(markdown_text)
		elsif results[0] == '#' 
			results = surround_a_header(markdown_text, STARTING_INDEX)
		elsif results[ENDING_INDEX] == '='
			results = surround_a_header(markdown_text, ENDING_INDEX)
			# find_img(markdown_text)
			# find_links(markdown_text)
			# find_strong(markdown_text)
			# find_tables(markdown_text)
		else 
			results = surround_by_paragraph(results)
		end
		results
	end

	def surround_a_header(text, markdown_from)
		if markdown_from == STARTING_INDEX
			text_arr = text.split('# ')
			header = text_arr[1].strip
			header_level = text_arr[STARTING_INDEX].scan('#').count + 1
		elsif markdown_from == ENDING_INDEX
			header = text.split("\n")[STARTING_INDEX]
			header_level = 1
		end
		"<h#{header_level}>#{header}</h#{header_level}>"
	end

	def surround_by_paragraph(text)
		"<p>#{text}</p>"
	end
end
