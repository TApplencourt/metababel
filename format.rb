require 'open3'

def format_erb(str_)
  r = /<%\s+(.*?)\s*%>/

  d_sub = {}
  i = 0

  # Handle <%=
  str_.gsub!(/<%=\s+(.*?)\s*%>/) do |m|
    prefix = '_' * (m.size - i.to_s.size - 1)
    new_str = "#{prefix}#{i}_" # Avoid 10 matching 1
    i += 1
    d_sub[new_str] = m
    new_str
  end

  # Handle <%
  str_.gsub!(/<%#?\s+(.*?)\s*%>/) do |m|
    new_str = "//___#{i}___"
    i += 1
    d_sub[new_str] = m
    new_str
  end

  str_, = Open3.capture2('clang-format -style="{ColumnLimit: 100}"', stdin_data: str_)

  d_sub.each do |k, v|
    str_.gsub!(/#{k}/, v)
  end

  str_
end

ARGV.each do |f|
  puts "Formating #{f}"
  str_ = File.read(f)
  str_ = format_erb(str_)
  File.write(f, str_)
end
