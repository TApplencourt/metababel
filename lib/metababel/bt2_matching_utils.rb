module HashRefinements
  refine Hash do
    # Special case for empty hash {} in ':default_clock_class: {}'.
    def match?(obj)
      self == obj ? [] : nil
    end
  end
end

module Babeltrace2Gen
  module BTMatch
    def match?(obj)
      match_attrs = self.class.class_variable_get(:@@bt_match_attrs)
      match = attrs_match?(match_attrs, self, obj).flatten
      # forward nil value if encountered; ortherwise, trasnform returned args if not transformed yet.
      match.include?(nil) ? nil : match.map { |m| m.respond_to?(:get_arg) ? m.get_arg : m }
    end
  end

  module BTMatchUtils
    using HashRefinements
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
      matches = objs.map { |obj| obj.match?(match_obj) ? obj : nil }.compact
      raise "Match expression '#{match_obj.name}' must match only one member, '#{ matches.length }' matched." unless matches.length < 2
      
      # If not argument matched, then nil.
      matches.empty? ? nil : matches
      end.flatten(1)

      # We need to validate that one function argument is not matched by two different match expressions.
      raise "Argument matched multiple times '#{args_matched.uniq.map(&:get_arg)}' in match expression '#{match_objs.map(&:name)}'. " unless args_matched.uniq.length == args_matched.length

      # Extract required args, convert non-required args to [], preserve nil if found.
      args_matched.zip(match_objs).map {|obj, match_obj| match_obj.extract ? obj : (obj.nil? ? nil : []) }
    end
  end
end
