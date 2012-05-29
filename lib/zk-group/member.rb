module ZK
  module Group
    class Member
      include Common

      attr_reader :zk 

      # @return [Group] the group instance this member belongs to
      attr_reader :group

      # @return [String] the relative path of this member under `group.path`
      attr_reader :name

      # @return [String] the absolute path of this member
      attr_reader :path

      def initialize(zk, group, path)
        @zk = zk
        @group = group
        @path = path
        @name = File.basename(@path)
        @mutex = Mutex.new
      end

      # probably poor choice of name, but does this member still an active membership
      # to its group (i.e. is its path still good). 
      #
      # This will return false after leave is called.
      def active?
        zk.exists?(path)
      end

      # Leave the group this membership is associated with.
      # In the basic implementation, this is not meant to kick another member
      # out of the group.
      #
      def leave
        zk.delete(path)
      end

      def data
        @data ||= zk.get(path).first
      end

      def data=(data)
        @data = data
        zk.set(path, data)
        data
      end
    end # Member
  end # Group
end # ZK
