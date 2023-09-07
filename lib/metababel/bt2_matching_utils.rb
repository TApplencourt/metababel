module Babeltrace2Gen
  class Hash
    # Special case for ':default_clock_class: {}''
    def match?(obj)
      self == obj ? [] : nil
    end
  end

  module BTMatch
    def match?(obj)
      match_attrs = self.class.class_variable_get(:@@bt_match_attrs)
      match = attrs_match?(match_attrs, self, obj).flatten
      match.include?(nil) ? nil : match.map(&:get_arg)
    end
  end

  module BTMatchUtils
    # Required to properly parse the result of match?
    # when applied on native data types such as String.
    def normalize(obj)
      obj == true ? [] : (obj == false ? nil : obj)
    end 

    def equivament?(obj, match_obj)
      match_obj ? (obj ? normalize(obj.match?(match_obj)) : nil) : []
    end

    def attrs_match?(attrs, obj, match_obj)
      attrs.map { |s| equivament?(obj.send(s), match_obj.send(s)) }
    end

    # This function applied only at Struct and Enviroment level to extract
    # entries (in env) and members (in struct). Since match? only return 
    # nil and []. if a member or an entry match we need to return the 
    # member or entry itself, thats why obj.match?(match_obj) ? obj : nil, 
    # as [] is evaluated to true.
    def each_match_once?(objs, match_objs)
      args_matched = match_objs.map do |match_obj|
      # 'obj.match?(match_obj)' will return all the matches made in the member nested attributes.
      # if all the attributes match, the member is returned, otherwise nil.
      matches = objs.map { |obj| obj.match?(match_obj) ? obj : nil }
      raise "Match expression '#{match_obj.name}' must match only one member, '#{ matches.length }' matched." unless matches.length < 2
      matches
      end.flatten(1)

      # We need to valudate that one function argument is not matched by two different match expressions.
      raise "Argument matched multiple times '#{args_matched.uniq.map(&:get_arg)}' in match expression '#{match_objs.map(&:name)}'. " unless args_matched.uniq.length == args_matched.length
      args_matched
    end
  end
end
