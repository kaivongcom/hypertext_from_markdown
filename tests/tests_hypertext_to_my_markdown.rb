require "test/unit"
require_relative "../hypertext_from_my_markdown"

class TestHypertextFromMyMarkdownParser < Test::Unit::TestCase
	def assert_equal_of_parser(original, html, wrapper_element=true, attr_class=false, attr_id=false, link_title=false)
		attrs = { element_name: wrapper_element, class: attr_class, link_title: link_title, id: attr_id }
		actual, expected = HypertextFromMyMarkdownParser.new(original, attrs).results, html
		assert_equal(expected, actual)
	end

	def test_for_anchor_link_text
		actual = "[home page](/example)"
		assert_equal_of_parser(actual, '<a href="/example">home page</a>', false)
	end

	def test_for_anchor_link_text_within_text
		test = { markdown: 'Link to [Google](http://google.com)', html: 'Link to <a href="http://google.com">Google</a>' }
		assert_equal_of_parser(test[:markdown], test[:html], false)
	end

	def test_for_anchor_link_text_wrapped
		markdown = "[home page](/example) "
		markdown = HypertextFromMyMarkdownParser.new(markdown).results
		assert_equal(markdown, '<p><a href="/example">home page</a> </p>')
	end

	def test_for_attrs_with_img
		md = "![pop tarts](/images/notes/square/20.png),  { element_name: 'a', link_title: 'computer game shop', href: 'https://kaivong.com' }"
	end

	def test_complex_link
		md = "[CSS prefers-reduced-data media-query](https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data ""Media Queries Level 5 Editor’s Draft, 21 November 2020"")"
		act = '<a href="https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data" title="Media Queries Level 5 Editor’s Draft, 21 November 2020">CSS prefers-reduced-data media-query</a>'
		assert_equal_of_parser(md, act, false)
	end

	def test_emphesis
		markdown = "*browsing* right now"
		expected = '<em>browsing</em> right now'
		assert_equal_of_parser(markdown, expected, false)
	end

	def test_for_emphasis_text
		test = { md: 'This text is *emphasised*.', html: 'This text is <em>emphasised</em>.' }
		assert_equal_of_parser(test[:md], test[:html], false)
	end

	def test_emoji_class_name_1
	 	md = "[🦔](# ""emoji"")"
	 	actual = '<span><a href="#" title="emoji">🦔</a></span>'
	 	assert_equal_of_parser(md, actual, 'span', 'emoji')
	 end

	def test_emoji_class_name
	 	md = "[🦔](# 'has title')"
	 	actual = '<a href="#" title="has title">🦔</a>'
	 	assert_equal_of_parser(md, actual, false, 'emoji')
	 end

	def test_for_external_links
		actual = "[home page](http://example.com/pages/index.html external)"
		assert_equal_of_parser(actual, '<a href="http://example.com/pages/index.html" title="external" class="external">home page</a> (http://example.com)', false)
	end

	def test_for_empty_space
		tests = { actual: ' ', expected: '' }
		assert_equal_of_parser(tests[:actual], tests[:expected] )
	end

	def test_for_h2_plus_class
		original = 'A Second Level Header'
		attrs = { attr_class: 'warning', element_name: 'h2' }
		markdown_parsed = HypertextFromMyMarkdownParser.new(original, attrs).results
		expected = '<h2 class="warning">A Second Level Header</h2>'
		assert_equal_of_parser(markdown_parsed, expected, false, attrs[:attr_class])
	end

	def test_for_h1_long_parse
		assert_equal_of_parser("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_for_h4_class_name
		markdown =  HypertextFromMyMarkdownParser.new("####.tidy a title").results
		output_html_desired = '<h4 class="tidy">a title</h4>'	
		assert_equal(output_html_desired, markdown)
	end

	# def test_for_p_class
	# 	attrs = { attr_class: 'example'}
	# 	markdown = '<p>clever little styled paragraph'
	# 	markdown = HypertextFromMyMarkdownParser.new(markdown, attrs).results
	# 	assert_equal(markdown, '<p class="example">clever little styled paragraph')
	# end

	# def test_for_p_class_escaped
	# 	markdown = "clever little styled paragraph  "
	# 	markdown = HypertextFromMyMarkdownParser.new(markdown).results
	# 	assert_equal(markdown, '<p>clever little styled paragraph</p>')
	# end

	def test_for_plain_text_unescaped
		markdown = "example text line for unstyled"
		expected = "example text line for unstyled"
		assert_equal_of_parser(markdown, expected, false)
	end

	# def test_for_p_within_paragraph
	# 	markdown, markdown_text = "clever little styled paragraph  ", "lorem ipsum is fun"
	# 	markdown = HypertextFromMyMarkdownParser.new(markdown).results
	# 	markdown_paragraphs = HypertextFromMyMarkdownParser.new(markdown + markdown_text).results
	# 	assert_equal(markdown_paragraphs, (markdown + ' ' + markdown_text))
	# end

	def test_for_paragraph_text_without_element
		paragraph = "example text line for unstyled"
		markdown = HypertextFromMyMarkdownParser.new(paragraph).results
		assert_equal_of_parser(markdown, "<p>example text line for unstyled</p>")
	end

	def test_for_h1
		tests = { actual: '# A First Level Header', expected: '<h1>A First Level Header</h1>' }
		assert_equal_of_parser(tests[:actual], tests[:expected] )
	end

	def test_for_h1_hashtag
		markdown = '# Header and the #Hashtag'
		expected = '<h1>Header and the #Hashtag</h1>'
		markdown = HypertextFromMyMarkdownParser.new(markdown).results
		assert_equal(expected, markdown)
	end

	def test_for_h2
		assert_equal_of_parser('## A Second Level Header', '<h2>A Second Level Header</h2>')
	end

	def test_for_h2_without_class
		original = '## A Second Level Header'
		expected = '<h2>A Second Level Header</h2>'
		attrs = { attr_class: 'warning'}
		assert_equal_of_parser(original, expected, true, attrs[:attr_class])
	end

	def test_img_html
		markdown_image = '![computer game shop](http://www.kaivong.com/images/square/515.jpg)'
		attrs = {element_name: false, link_title: 'computer game shop'} # alt
		markdown = HypertextFromMyMarkdownParser.new(markdown_image, attrs).results
		actual = '<img alt="computer game shop" src="http://www.kaivong.com/images/square/515.jpg">'
		assert_equal(actual, markdown)
	end

	def test_a_img_html_params
		markdown_image = '![link factory](http://www.kaivong.com/images/square/515.jpg alt="something amazing" height="100" width="100")'
		attrs = { element_name: 'a', link_title: 'link factory', href: 'https://kaivong.com' }
		markdown = HypertextFromMyMarkdownParser.new(markdown_image, attrs).results
		actual = '<a href="https://kaivong.com"><img alt="link factory" src="http://www.kaivong.com/images/square/515.jpg"></a>'
		assert_equal(actual, markdown)
	end

	def test_to_links_with_tag_element
		wrapper_element = 'p'
		markdown = "[example page](/example 'With a Title')"
		expected = '<p><a href="/example" title="With a Title">example page</a></p>'
		assert_equal_of_parser(markdown, expected, wrapper_element)
	end

	def test_to_links_with_title
		markdown = "[example page](/example ""With a Title"")"
		expected = '<a href="/example" title="With a Title">example page</a>'
		assert_equal_of_parser(markdown, expected, false)
	end

	def test_for_paragraph_text
		paragraph = "example text line for unstyled\n"
		assert_equal_of_parser(paragraph, "<p>example text line for unstyled</p>")
	end

	def test_for_tables_header
		original = '| # | name1 | name2 | name3 |'
		expected = '<table summary=""><thead><tr><td> name1 </td><td> name2 </td><td> name3 </td></tr></thead>'
		attrs = { element_name: false, attr_class: '' }
		assert_equal_of_parser(original, expected, attrs[:element_name])
	end

	def test_for_table_row
		original = '| ## | bill | bob | jess |'
		expected = '<tr><td> bill </td><td> bob </td><td> jess </td></tr>'
		attrs = { element_name: false, attr_class: '' }
		assert_equal_of_parser(original, expected, attrs[:element_name])
	end

	def test_for_table_row_id
		original = '| ## | bill | bob | jess |'
		actual = '<tr id="people"><td> bill </td><td> bob </td><td> jess </td></tr>'
		attrs = { element_name: false, attr_id: 'people' }
		markdown = HypertextFromMyMarkdownParser.new(original, attrs).results
		assert_equal(markdown, actual)
	end

	def test_for_table_row_class_and_id
		original = '| ## | bill | bob | jess |'
		actual = '<tr id="footballers" class="players"><td> bill </td><td> bob </td><td> jess </td></tr>'
		attrs = { element_name: false, attr_id: 'footballers', attr_class: 'players' }
		markdown = HypertextFromMyMarkdownParser.new(original, attrs).results
		assert_equal(markdown, actual)
	end

	def test_text_left_side_to_short_link_in_paragraph
		markdown = "This is an [example link](/example/ ""With a Title"")."
		expected = '<p>This is an <a href="/example/" title="With a Title">example link</a>.</p>'
		assert_equal_of_parser(markdown, expected)
	end

	def test_text_left_side_to_http_link_in_paragraph
		markdown = "This is an [example link](http://example.com/ ""With a Title"")."
		expected = '<p>This is an <a href="http://example.com/" title="With a Title">example link</a>.</p>'
		assert_equal_of_parser(markdown, expected)
	end

	def test_text_right_side_to_short_link_in_paragraph
		markdown = "[example link](/example/ ""With a Title"") for that."
		expected = '<p><a href="/example/" title="With a Title">example link</a> for that.</p>'
		assert_equal_of_parser(markdown, expected)
	end
	
	def test_strong_element
		md = "here is **bold or strong text**"
		html = '<p>here is <strong>bold or strong text</strong></p>'
		assert_equal_of_parser(md, html)
	end

	def test_wrapped_in_text_link_paragraph
		md = "here is [a example link](http://example.com/ ""With a Title"") to something else"
		actual = '<p>here is <a href="http://example.com/" title="With a Title">a example link</a> to something else</p>'
		assert_equal_of_parser(md, actual)
	end

	def test_wrapper_p2
		md = "here is [a example link](http://example.com/ ""With a Title"") to something else"
		html = '<strong>here is <a href="http://example.com/" title="With a Title">a example link</a> to something else</strong>'
		assert_equal_of_parser(md, html, 'strong')
	end

	# def test_no_parsing
	# 	md = """<pre><code>
	# 				test no parse
	# 		</code></pre>"""
	# 	actual = md
	# 	assert_equal_of_parser(md, actual)
	# end
end
