require 'spec_helper'

describe ZK::Group::Group do
  include_context 'connections'

  let(:group_name) { 'the_mothers' }
  let(:group_data) { 'of invention' }
  let(:member_names) { %w[zappa jcb collins estrada underwood] }

  subject { described_class.new(@zk, group_name, :root => @base_path) }
  after { subject.close }
 
  describe :create do
    it %[should create the group with empty data] do
      subject.create
      @zk.stat(subject.path).should be_exist
    end

    it %[should create the group with specified data] do
      subject.create(group_data)
      @zk.get(subject.path).first.should == group_data
    end

    it %[should return nil if the group is not created] do
      @zk.mkdir_p(subject.path)
      subject.create.should be_nil
    end
  end # create

  describe :exists? do
    it %[should return false if the group has not been created] do
      @zk.stat(subject.path).should_not exist
      subject.should_not exist
    end

    it %[should return true if the group has been created] do
      subject.create
      @zk.stat(subject.path).should exist
      subject.should exist
    end
  end

  describe :create! do
    it %[should raise GroupAlreadyExistsError if the group already exists] do
      @zk.mkdir_p(subject.path)
      lambda { subject.create! }.should raise_error(ZK::Exceptions::GroupAlreadyExistsError)
    end
  end # create!

  describe :data do
    it %[should return the group's data] do
      @zk.mkdir_p(subject.path)
      @zk.set(subject.path, group_data)
      subject.data.should == group_data
    end
  end # data

  describe :data= do
    it %[should set the group's data] do
      @zk.mkdir_p(subject.path)
      subject.data = group_data
      @zk.get(subject.path).first == group_data
    end
  end # data=

  describe :member_names do
    before do
      member_names.each do |name|
        @zk.mkdir_p("#{subject.path}/#{name}")
      end
    end

    it %[should return a list of relative znode paths that belong to the group] do
      subject.member_names.should == member_names.sort
    end

    it %[should return a list of absolute znode paths that belong to the group when :absolute => true is given] do
      subject.member_names(:absolute => true).should == member_names.sort.map {|n| "#{subject.path}/#{n}" }
    end
  end # member_names

  describe :join do
    it %[should raise GroupDoesNotExistError if the group has not been created already] do
      lambda { subject.join }.should raise_error(ZK::Exceptions::GroupDoesNotExistError)
    end

    it %[should return a Member object if the join succeeds] do
      subject.create!
      subject.join.should be_kind_of(ZK::Group::Member)
    end

    it %[should return just the path if :member_class => nil] do
      subject.create!

      subject.join(:member_class => nil).should match(%r%^#{subject.path}%)
    end
  end # join

  describe :on_membership_change do
    before { @events = [] }

    describe 'with default options' do
      before do
        subject.on_membership_change do |old,cur|
          @events << [old,cur]
        end

        subject.create!
      end

      it %[should return an object with an unsubscribe method] do
        sub = subject.on_membership_change { |old,cur| }

        sub.should respond_to(:unsubscribe)
      end

      it %[should deliver when the membership changes] do
        subject.should be_created

        member = subject.join
        wait_while { @events.empty? }
        @events.length.should == 1

        old, cur = @events.first

        old.should be_empty
        cur.length.should == 1
        cur.first.should match(/\Am\d+\Z/)
      end

      it %[should deliver notification when a member joins or leaves] do
        subject.should be_created

        members = []

        10.times { members << subject.join }

        # wait until we've received notification that includes our last created member
        wait_until { @events.last.last.length == 10 }

        # there should be a difference in the size of the group
        # this won't always be true, but in this case it should be
        @events.each do |old,cur|
          old.length.should < cur.length
        end

        @events.clear

        members.each { |m| m.leave }

        # wait until we've received notification that includes our last created member
        wait_until { @events.last.last.empty? }

        @events.each do |old,cur|
          old.length.should > cur.length
        end
      end

      it %[should deliver all events to all listeners in order] do
        other_events = []
        mutex = Monitor.new
        offset = 10
        saw_six = false

        subject.on_membership_change do |old,cur|
          num = mutex.synchronize { (offset -= 1) + 1 }
          sleep(num * 0.005)
          other_events << [old,cur]
          mutex.synchronize { saw_six = (cur.length == 6) }
        end

        6.times { subject.join }

        wait_until { @events.last.last.length == 6 }
        wait_until { @events.length == other_events.length }

        @events.should == other_events
      end # in order
    end # default options

    describe 'with :absolute => true' do
      before do
        subject.on_membership_change(:absolute => true) do |old,cur|
          @events << [old,cur]
        end

        subject.create!
      end

      it %[should deliver the members as absolute paths if the :absolute option is true] do
        member = subject.join

        wait_while { @events.empty? }
        @events.length.should == 1

        old, cur = @events.first

        cur.first.should start_with('/')
      end
    end # absolute
  end # on_membership_changed
end # ZK::Group::Base
