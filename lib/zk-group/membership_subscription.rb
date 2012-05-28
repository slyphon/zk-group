module ZK
  module Group
    class MembershipSubscription < ZK::Subscription::Base
      include ZK::Logging

      attr_reader :opts

      alias group parent

      def initialize(group, opts, block)
        super(group, block)
        @opts = opts
      end

      def notify(last_members, current_members)
        # XXX: implement this in here for now, but for very large membership lists
        #      it would likely be more efficient to implement this in the caller
        if absolute_paths?
          group_path = group.path

          last_members    = last_members.map { |m| File.join(group_path, m) }
          current_members = current_members.map { |m| File.join(group_path, m) }
        end

        call(last_members, current_members)
      end

      def absolute_paths?
        opts[:absolute]
      end

      protected :call
    end
  end
end

