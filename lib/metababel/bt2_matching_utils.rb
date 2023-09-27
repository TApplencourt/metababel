module HashRefinements
  refine Hash do
    # Special case for hash, default value of
    # ':default_clock_class: {}'.
    def match?(obj)
      self == obj
    end
  end
end

module Babeltrace2Gen
  using HashRefinements

  module BTMatch
    def match?(match_obj)
      attrs_syms = self.class::BT_MATCH_ATTRS
      attrs = attrs_syms.map do |attr_sym|
        match_attr = match_obj.send(attr_sym)
        # In the model, but not in the match, assuming True
        next true if match_attr.nil?

        self_attr = send(attr_sym)
        # Not matching because in the match but not in the model
        next false if self_attr.nil?

        # Continue the recursion
        self_attr.match?(match_attr)
      end.flatten
      return false unless attrs.all?
      attrs.filter { |a| a.is_a?(Babeltrace2Gen::GeneratedArg) }
    end
  end

  module BTMatchMembers
    def match?(match_obj)
      # Object here have only one symbol, who cannot be nil
      attr_sym = self.class::BT_MATCH_ATTRS[0]

      self_members = send(attr_sym)
      match_members = match_obj.send(attr_sym)

      # Do the product of menbers to get the matching one
      # We keep only the matching one.
      args_matched = match_members.filter_map do |match_obj|
        # Find all machings members
        matches = self_members.filter { |member| member.match?(match_obj) }
        # Check that one match_obj only match zero or one member.
        unless matches.length < 2
          raise "Match expression '#{match_obj.name}' must match only one member, '#{matches.length}' matched #{matches.map(&:name)}."
        end
        # If not argument matched, then nil; otherwise, return the matched member.
        matches.pop.get_arg unless matches.empty?
      end

      # We didn't match anything
      if args_matched.empty? or args_matched.uniq.length != match_members.length
        return false
      # Same arguments in the model have been matched twice
      elsif args_matched.uniq.length != args_matched.length
        raise "Members '#{args_matched.uniq.map(&:name)}' matched multiple times in '#{match_members.map(&:name)}'. "
      # Not all match mernbers found a matchings
      elsif args_matched.uniq.length != match_members.length
        return false
      end

      # Filter one we need to extract
      args_matched.zip(match_members).filter_map { |obj, match_obj| obj if match_obj.extract }
    end
  end
end
