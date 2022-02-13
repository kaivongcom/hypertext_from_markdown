require "test/unit"
require_relative "../hypertext_from_my_markdown"

class TestHypertextFromMyMarkdownParser < Test::Unit::TestCase
	def assert_equal_of_parser(markdown_text, html)
		actual, expected = HypertextFromMyMarkdownParser.new(markdown_text).text, html
		assert_equal(actual, expected)
	end

	def test_for_paragraph_text_without_element
		paragraph = "example line of text unstyled"
		assert_equal_of_parser(paragraph, "<p>example line of text unstyled</p>")
	end

	def test_for_text_surrounded_by_pTag
		a_passage_of_markdown = HypertextFromMyMarkdownParser.new("a block containing my text in the middle").text
		assert_equal('<p>a block containing my text in the middle</p>', a_passage_of_markdown)
	end

	def test_for_h1_long_parse
		# pend
		assert_equal_of_parser("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_for_anchor_link_text
		# pend
		# 	actual = "[home page](/example)"
		# 	assert_equal_of_parser(actual, '<a href="/example">home page</a>', false)
	end

	def test_for_anchor_link_text_within_text
		pend
		test = { markdown: 'Link to [Google](http://google.com)', html: 'Link to <a href="http://google.com">Google</a>' }
		assert_equal_of_parser(test[:markdown], test[:html], false)
	end

	def test_for_anchor_link_text_wrapped
		pend
		markdown = "[home page](/example) "
		markdown = HypertextFromMyMarkdownParser.new(markdown).results
		assert_equal(markdown, '<p><a href="/example">home page</a> </p>')
	end

	def test_complex_link
		pend
		md = "[CSS prefers-reduced-data media-query](https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data ""Media Queries Level 5 Editor’s Draft, 21 November 2020"")"
		act = '<a href="https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data" title="Media Queries Level 5 Editor’s Draft, 21 November 2020">CSS prefers-reduced-data media-query</a>'
		assert_equal_of_parser(md, act, false)
	end


	# def test_for_h2_plus_class
	# 	pend
	# 	# 	original = 'A Second Level Header'
	# 	# 	markdown_parsed = HypertextFromMyMarkdownParser.new(original).text
	# 	# 	expected = '<h2 class="warning">A Second Level Header</h2>'
	# 	# 	assert_equal_of_parser(markdown_parsed, expected)
	# end

	# def test_for_h2_inline_class
	# 	pend
	# 	original = '##.warning different Second Level Header'
	# 	# markdown_parsed = HypertextFromMyMarkdownParser.new(original, {element_name: false}).text
	# 	markdown_parsed = HypertextFromMyMarkdownParser.new(original).text
	# 	expected = '<h2 class="warning">different Second Level Header</h2>'
	# 	assert_equal_of_parser(markdown_parsed, expected)
	# end

	# def test_for_h4_class_name
	# 	pend
	# 	# 	markdown =  HypertextFromMyMarkdownParser.new("####.tidy a title").text
	# 	# 	output_html_desired = '<h4 class="tidy">a title</h4>'	
	# 	# 	assert_equal(output_html_desired, markdown)
	# end

	# def test_for_h1
	# 	tests = { actual: '# A First Level Header', expected: '<h1>A First Level Header</h1>' }
	# 	assert_equal_of_parser(tests[:actual], tests[:expected] )
	# end

	# def test_for_h1_hashtag
	# 	markdown, expected = '# Header and the #Hashtag', '<h1>Header and the #Hashtag</h1>'
	# 	assert_equal_of_parser(markdown, expected)
	# end

	# def test_for_h2
	# 	assert_equal_of_parser('## A Second Level Header', '<h2>A Second Level Header</h2>')
	# end

	# def test_for_attrs_with_img
	# 	pend
	# 	# 	md = "![pop tarts](/images/notes/square/20.png),  { element_name: 'a', link_title: 'computer game shop', href: 'https://kaivong.com' }"
	# end

	# def test_emphesis
	# 	pend
	# 	# 	markdown = "*browsing* right now"
	# 	# 	expected = '<em>browsing</em> right now'
	# 	# 	assert_equal_of_parser(markdown, expected, false)
	# end

	# def test_for_emphasis_text
	# 	pend
	# 	# 	test = { md: 'This text is *emphasised*.', html: 'This text is <em>emphasised</em>.' }
	# 	# 	assert_equal_of_parser(test[:md], test[:html], false)
	# end

	# def test_emoji_class_name_1
	# 	pend
	# #  	md = "[🦔](# ""emoji"")"
	# #  	actual = '<span><a href="#" title="emoji">🦔</a></span>'
	# #  	assert_equal_of_parser(md, actual, 'span', 'emoji')
	#  end

	# def test_emoji_class_name
	# 	pend
	# #  	md = "[🦔](# 'has title')"
	# #  	actual = '<a href="#" title="has title">🦔</a>'
	# #  	assert_equal_of_parser(md, actual, false, 'emoji')
	#  end

	# def test_for_external_links
	# 	pend
	# 	# 	actual = "[home page](http://example.com/pages/index.html external)"
	# 	# 	assert_equal_of_parser(actual, '<a href="http://example.com/pages/index.html" title="external" class="external">home page</a> (http://example.com)', false)
	# end

	# def test_img_html
	# 	pend
	# 	# 	markdown_image = '![computer game shop](http://www.kaivong.com/images/square/515.jpg)'
	# 	# 	attrs = {element_name: false, link_title: 'computer game shop'} # alt
	# 	# 	markdown = HypertextFromMyMarkdownParser.new(markdown_image, attrs).results
	# 	# 	actual = '<img alt="computer game shop" src="http://www.kaivong.com/images/square/515.jpg">'
	# 	# 	assert_equal(actual, markdown)
	# end

	# def test_a_img_html_params
	# 	pend
	# 	# 	markdown_image = '![link factory](http://www.kaivong.com/images/square/515.jpg alt="something amazing" height="100" width="100")'
	# 	# 	attrs = { element_name: 'a', link_title: 'link factory', href: 'https://kaivong.com' }
	# 	# 	markdown = HypertextFromMyMarkdownParser.new(markdown_image, attrs).results
	# 	# 	actual = '<a href="https://kaivong.com"><img alt="link factory" src="http://www.kaivong.com/images/square/515.jpg"></a>'
	# 	# 	assert_equal(actual, markdown)
	# end

	# def test_to_links_with_tag_element
	# 	pend
	# 	# 	wrapper_element = 'p'
	# 	# 	markdown = "[example page](/example 'With a Title')"
	# 	# 	expected = '<p><a href="/example" title="With a Title">example page</a></p>'
	# 	# 	assert_equal_of_parser(markdown, expected, wrapper_element)
	# end

	# def test_to_links_with_title
	# 	pend
	# 	# 	markdown = "[example page](/example ""With a Title"")"
	# 	# 	expected = '<a href="/example" title="With a Title">example page</a>'
	# 	# 	assert_equal_of_parser(markdown, expected, false)
	# end

	# def test_for_paragraph_text
	# 	pend
	# 	# 	paragraph = "example text line for unstyled\n"
	# 	# 	assert_equal_of_parser(paragraph, "<p>example text line for unstyled</p>")
	# end

	# def test_for_tables_header
	# 	pend
	# 	# 	original = '| # | name1 | name2 | name3 |'
	# 	# 	expected = '<table summary=""><thead><tr><td> name1 </td><td> name2 </td><td> name3 </td></tr></thead>'
	# 	# 	attrs = { element_name: false, attr_class: '' }
	# 	# 	assert_equal_of_parser(original, expected, attrs[:element_name])
	# end

	# def test_for_table_row
	# 	pend
	# 	# 	original = '| ## | bill | bob | jess |'
	# 	# 	expected = '<tr><td> bill </td><td> bob </td><td> jess </td></tr>'
	# 	# 	attrs = { element_name: false, attr_class: '' }
	# 	# 	assert_equal_of_parser(original, expected, attrs[:element_name])
	# end

	# def test_for_table_row_id
	# 	pend
	# 	# 	original = '| ## | bill | bob | jess |'
	# 	# 	actual = '<tr id="people"><td> bill </td><td> bob </td><td> jess </td></tr>'
	# 	# 	attrs = { element_name: false, attr_id: 'people' }
	# 	# 	markdown = HypertextFromMyMarkdownParser.new(original, attrs).results
	# 	# 	assert_equal(markdown, actual)
	# end

	# def test_for_table_row_class_and_id
	# 	pend
	# 	# 	original = '| ## | bill | bob | jess |'
	# 	# 	actual = '<tr id="footballers" class="players"><td> bill </td><td> bob </td><td> jess </td></tr>'
	# 	# 	attrs = { element_name: false, attr_id: 'footballers', attr_class: 'players' }
	# 	# 	markdown = HypertextFromMyMarkdownParser.new(original, attrs).results
	# 	# 	assert_equal(markdown, actual)
	# end

	# def test_text_left_side_to_short_link_in_paragraph
	# 	pend
	# 	# 	markdown = "This is an [example link](/example/ ""With a Title"")."
	# 	# 	expected = '<p>This is an <a href="/example/" title="With a Title">example link</a>.</p>'
	# 	# 	assert_equal_of_parser(markdown, expected)
	# end

	# def test_text_left_side_to_http_link_in_paragraph
	# 	pend
	# 	# 	markdown = "This is an [example link](http://example.com/ ""With a Title"")."
	# 	# 	expected = '<p>This is an <a href="http://example.com/" title="With a Title">example link</a>.</p>'
	# 	# 	assert_equal_of_parser(markdown, expected)
	# end

	# def test_text_right_side_to_short_link_in_paragraph
	# 	pend
	# 	# 	markdown = "[example link](/example/ ""With a Title"") for that."
	# 	# 	expected = '<p><a href="/example/" title="With a Title">example link</a> for that.</p>'
	# 	# 	assert_equal_of_parser(markdown, expected)
	# end
	
	# def test_strong_element
	# 	pend
	# 	# 	md = "here is **bold or strong text**"
	# 	# 	html = '<p>here is <strong>bold or strong text</strong></p>'
	# 	# 	assert_equal_of_parser(md, html)
	# end

	# def test_wrapped_in_text_link_paragraph
	# 	pend
	# 	# 	md = "here is [a example link](http://example.com/ ""With a Title"") to something else"
	# 	# 	actual = '<p>here is <a href="http://example.com/" title="With a Title">a example link</a> to something else</p>'
	# 	# 	assert_equal_of_parser(md, actual)
	# end

	# def test_wrapper_p2
	# 	pend
	# 	# 	md = "here is [a example link](http://example.com/ ""With a Title"") to something else"
	# 	# 	html = '<strong>here is <a href="http://example.com/" title="With a Title">a example link</a> to something else</strong>'
	# 	# 	assert_equal_of_parser(md, html, 'strong')
	# end

	# def test_for_empty_space
	# 	pend
	# 	# tests = { actual: ' ', expected: '' }
	# 	# assert_equal_of_parser(tests[:actual], tests[:expected] )
	# end
end
