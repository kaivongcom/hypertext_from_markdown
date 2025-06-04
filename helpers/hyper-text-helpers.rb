CLOSE_TABLE = '</table>'
HTML_LIST_ITEM = 'li'
HTML_TABLE = 'table'
HTML_TABLE_DATA = 'td'
HTML_TABLE_HEADER = 'thead'
HTML_TABLE_ROW = 'tr'
NEW_LINE = "\n"

def	html_body(body_content, styles)
	"<html><head>#{ styles }</head><body>#{body_content}</body></html>"
end

def	html_table(content)
	"<table><tbody>\n #{content} </tbody></table>"
end

def html_table_data(class_name, displaying, data)
	"<td class=\"#{ class_name } #{ displaying }\">#{ data }</td>\n"
end

def html_table_row(data)
	"<tr>" + data + "</tr>"
end
