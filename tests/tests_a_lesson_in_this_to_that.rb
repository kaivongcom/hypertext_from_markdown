require "test/unit"
require_relative "../mymarkdown_to_hypertext"

class TestMyMarkdownToHypertextParser < Test::Unit::TestCase

	def assert_equal_of_MyMarkdownToHypertextParser(original, html, wrapper_element=true)
		actual, expected = MyMarkdownToHypertextParser.new(original, wrapper_element).results, html
		assert_equal(expected, actual)
	end

	def test_to_html_for_h1
		assert_equal_of_MyMarkdownToHypertextParser('# A First Level Header', '<h1>A First Level Header</h1>')
	end

	def test_to_html_for_h2
		assert_equal_of_MyMarkdownToHypertextParser('## A Second Level Header', '<h2>A Second Level Header</h2>')
	end

	def test_to_html_for_h1_long_parse
		assert_equal_of_MyMarkdownToHypertextParser("A First Level Header\n ====================", '<h1>A First Level Header</h1>')
	end

	def test_to_html_for_p_singleline
		paragraph = "The quick brown fox jumped over the lazy dog's back.\n"
		assert_equal_of_MyMarkdownToHypertextParser(paragraph, "<p>The quick brown fox jumped over the lazy dog's back.</p>")
	end

	def test_to_html_for_p
		paragraph = "Now is the time for all good men to come to the aid of their country. This is just a regular paragraph.\n The quick brown fox jumped over the lazy dog's back.\n"
		assert_equal_of_MyMarkdownToHypertextParser(paragraph, "<p>Now is the time for all good men to come to the aid of their country. This is just a regular paragraph.</p><p> The quick brown fox jumped over the lazy dog's back.</p>")
	end

	def test_to_links_only
		markdown = "[example link](/example/ 'With a Title')"
		expected = "<a href='/example/' title=\"With a Title\">example link</a>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_to_links_short
		markdown = "This is an [example link](/example/ 'With a Title')."
		expected = "<p>This is an <a href='/example/' title=\"With a Title\">example link</a>.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_to_links_full
		markdown = "This is an [example link](http://example.com/ \"With a Title\")."
		expected = "<p>This is an <a href='http://example.com/' title=\"With a Title\">example link</a>.</p>"
		assert_equal_of_MyMarkdownToHypertextParser(markdown, expected)
	end

	def test_link_inside_p_1
		act = "<p>here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</p>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, act)
	end

	def test_wrapper_p1
		actual = "<span class=\"line-break\">here is <a href='http://example.com/' title=\"With a Title\">a example link</a> to something else</span>"
		md = "here is [a example link](http://example.com/ \"With a Title\") to something else"
		assert_equal_of_MyMarkdownToHypertextParser(md, actual, 'span')
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
		assert_equal_of_MyMarkdownToHypertextParser(md, act)
	end

end

