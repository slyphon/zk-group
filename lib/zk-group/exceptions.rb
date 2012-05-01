module ZK
  module Exceptions
    # Raised when you try to perform an operation on a group but it hasn't been
    # created yet
    class GroupDoesNotExistError < NoNode; end

    # Raised when you try to create! a group but it already exists
    class GroupAlreadyExistsError < NodeExists; end

    # Raised if an operation is performed that assumes that a membership is active but it wasn't
    class MemberDoesNotExistError < NoNode; end

    # for symmetry with GroupAlreadyExistsError but in the base implementation, should probably never happen
    class MemberAlreadyExistsError < NodeExists; end
  end
end
