require 'spec_helper'

describe ZK::Group::Member do
  include_context 'connections'

  let(:group_name) { 'the_mothers' }
  let(:group) do
    double(
      name: group_name, 
      root: @base_path,
      path: "#{ZK::Group::DEFAULT_ROOT}/#{group_name}"
    )
  end

  let(:member_data) { "LA DI *FREAKIN* DA!" }

  let(:member_path) do 
    @zk.mkdir_p group.path
    @zk.create("#{group.path}/#{ZK::Group::DEFAULT_PREFIX}", member_data, ephemeral: true, sequential: true)
  end
  
  subject { described_class.new(@zk, group, member_path) }

  describe :active? do
    it %[should return true if the path exists] do
      @zk.stat(member_path).should exist
      subject.should be_active
    end

    it %[should return false if the path does not exist] do
      @zk.delete(member_path)
      subject.should_not be_active
    end
  end

  describe :leave do
    it %[should delete the underlying path] do
      subject.leave
      @zk.stat(member_path).should_not exist
    end

    it %[should not be active after leave] do
      subject.leave
      subject.should_not be_active
    end
  end

  describe :data do
    it %[should return the data in the member's node] do
      subject.data.should == member_data
    end
  end

  describe :data= do
    it %[should set the data for the member's node] do
      subject.data = "new data"
      @zk.get(member_path).first.should == 'new data'
    end
  end
end

