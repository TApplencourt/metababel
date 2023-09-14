module HashRefinements
  refine Hash do
    # Special case for empty hash {} in ':default_clock_class: {}'.
    def match?(obj)
      self == obj
    end
  end
end

module Babeltrace2Gen
  using HashRefinements

  module BTMatch

  def find_bt_match_attrs(c)
      a = c.instance_variable_get(:@bt_match_attrs)
      if a.nil?
        find_bt_match_attrs(c.superclass)
      else
        a
      end
  end

    def match?(match_obj)
      attrs_syms = find_bt_match_attrs(self.class)
      attrs_syms.map do |attr_sym|
        match_attr = match_obj.send(attr_sym)
        self_attr = self.send(attr_sym)
        match_attr.nil? ? true : (self_attr.nil? ? false : self_attr.match?(match_attr))
      end.flatten
    end
  end

  module BTMatchMembers
    def match?(match_obj)
      attr_sym = self.class.instance_variable_get(:@bt_match_attrs)[0]
      self_members, match_members = self.send(attr_sym), match_obj.send(attr_sym)

      args_matched = match_members.filter_map do |match_obj|
        # Exist in the model, but doesn't exist in matching, but we will not extract it, so true
        next true if match_obj.nil?
        matches = self_members.filter { |member| member.match?(match_obj).all? }
        # Check that one match_obj only match zero or one member.
        raise "Match expression '#{match_obj.name}' must match only one member, '#{ matches.length }' matched #{matches.map(&:name)}." unless matches.length < 2 
        # If not argument matched, then nil; otherwise, return the matched member.
        matches.pop.get_arg unless matches.empty?
      end

      return false if args_matched.empty?

      raise "Members '#{args_matched.uniq.map(&:name)}' matched multiple times in '#{match_members.map(&:name)}'. " unless args_matched.uniq.length == args_matched.length
      
      return false unless args_matched.uniq.length == match_members.length
      args_matched.zip(match_members).map {|obj, match_obj| match_obj.extract ? obj : true}
    end
  end
end
