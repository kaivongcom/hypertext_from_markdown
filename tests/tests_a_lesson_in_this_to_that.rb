require "test/unit"
require_relative "../mymarkdown_to_hypertext"

class TestMyMarkdownToHypertextParser < Test::Unit::TestCase

	def assert_equal_of_MyMarkdownToHypertextParser(original, html, wrapper_element=true, attr_class=false)
		actual, expected = MyMarkdownToHypertextParser.new(original, wrapper_element, attr_class).results, html
		# actual, expected = MyMarkdownToHypertextParser.new(original, wrapper_element).results, html
		assert_equal(expected, actual)
	end

	def test_for_h1
		assert_equal_of_MyMarkdownToHypertextParser('# A First Level Header', '<h1>A First Level Header</h1>')
	end

	def test_for_h2
		assert_equal_of_MyMarkdownToHypertextParser('## A Second Level Header', '<h2>A Second Level Header</h2>')
	end

	def test_for_h1_long_parse
		assert_equal_of_MyMarkdownToHypertextParser("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_for_paragraph
		paragraph = "example text line for unstyled\n"
		assert_equal_of_MyMarkdownToHypertextParser(paragraph, "<p>example text line for unstyled</p>")
	end

	def test_to_only_text
		markdown = "example text line for unstyled"
		expected = "example text line for unstyled"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected, false)
	end

	def test_to_only_links
		markdown = "[example link](/example/ 'With a Title')"
		expected = "<a href='/example/' title=\"With a Title\">example link</a>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected, false)
	end

	def test_to_links_short
		markdown = "This is an [example link](/example/ 'With a Title')."
		expected = "<p>This is an <a href='/example/' title=\"With a Title\">example link</a>.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_to_link_in_paragraph
		markdown = "This is an [example link](http://example.com/ \"With a Title\")."
		expected = "<p>This is an <a href='http://example.com/' title=\"With a Title\">example link</a>.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_link_inside_paragraph_2
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		act = "<p>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</p>"
		assert_equal_of_MyMarkdownToHypertextParser(md, act)
	end

	def test_wrapper_paragraph_3
		actual = "<p>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</p>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual)
	end

	def test_specific_class_name
		actual = "<p class=\"new-class\">here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</p>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'p', 'new-class')
	end

	def test_emoji_class_name
		actual = "<span class=\"emoji\"><a href='#' title=\"emoji\">🦔</a></span>"
		md = "[🦔](# \"emoji\")"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'span', 'emoji')
	end

	def test_wrapper_p2
		actual = "<strong>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</strong>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'strong')
	end

	# def test_link_inside_p_2
	# 	act = "<p>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something (totally) else</p>"
	# 	md = "here is [a example link](http://example.com/ \"With a Title\") to something (totally) else"
	# 	actual_expected(md, act)
	# end

	def test_complex_link
		act = "<a href='https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data' title=\"Media Queries Level 5 Editor’s Draft, 21 November 2020\">CSS prefers-reduced-data media-query</a>"
		md = "[CSS prefers-reduced-data media-query](https://drafts.csswg.org/mediaqueries-5/#descdef-media-prefers-reduced-data 'Media Queries Level 5 Editor’s Draft, 21 November 2020')"
		assert_equal_of_MyMarkdownToHypertextParser(md, act, false)
	end

end

