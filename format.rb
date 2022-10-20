require 'open3'

str_ = File.read(ARGV[0])

r = /<%\s+(.*?)\s*%>/

d_sub = {}
i = 0

# Handle <%=
str_.gsub!(/<%=\s+(.*?)\s*%>/){ |m|
    prefix = "_"*(m.size - i.to_s.size - 1)
    new_str =  "#{prefix}#{i}_" # Avoid 10 matching 1
    i=i+1
    d_sub[new_str] = m
    new_str
}

# Handle <%
str_.gsub!(/<%\s+(.*?)\s*%>/){ |m|
    new_str =  "//___#{i}___"
    i=i+1
    d_sub[new_str] = m
    new_str
}


str_, _ = Open3.capture2("clang-format", :stdin_data=>str_)

d_sub.each { |k,v|
  str_.gsub!(/#{k}/,v)
}

File.write(ARGV[0], str_)
