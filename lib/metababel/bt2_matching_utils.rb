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
      attrs_match?(self.class.class_variable_get(:@@bt_match_attrs), self, obj)
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

    # Return [] or [GenArg,...] iff all attrs match, nil otherwise.
    def attrs_match?(attrs, obj, match_obj)
      match = attrs.map { |s| equivament?(obj.send(s), match_obj.send(s)) }.flatten
      match.include?(nil) ? nil : match
    end

    # Return [] or [GenArg,..] iff every member is matched uniquelly, nil otherwise.
    def each_match_once?(objs, match_objs)
      args_matched = match_objs.map do |match_obj|
        matches = objs.map { |obj| obj.match?(match_obj) ? obj : nil }.compact

        # Check that one match_obj only match cero or one member.
        raise "Match expression '#{match_obj.name}' must match only one member, '#{ matches.length }' matched." unless matches.length < 2

        # If not argument matched, then nil; otherwise, return the matched member.
        matches.pop
      end

      # Check that member is not matched by two different match_objs.
      raise "Argument matched multiple times '#{args_matched.uniq.map(&:get_arg)}' in match expression '#{match_objs.map(&:name)}'. " unless args_matched.uniq.length == args_matched.length

      # If at least one match_obj did not match a member, then nil.
      return nil if args_matched.include?(nil)

      # Extract required args.
      args_matched.zip(match_objs).filter_map {|obj, match_obj| obj.get_arg if match_obj.extract }
    end
  end
end
