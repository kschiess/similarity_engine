require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Similarity Engine' do
  it "should smoke" do; end

  require 'fixtures/user_scenario_schema'
  require 'fixtures/user_scenario_models'
  describe 'in a test scenario with Users' do
    describe 'fixtures' do
      it "should have user model and allow creation of users" do
        User.create!(:name => 'test')
      end 
    end

    attr_reader :users
    before(:each) do
      @users = {}
      
      # Create a few users for us to work with
      %w{bob alice marcella matz barbara}.each do |name|
        @users[name.to_sym] = User.create!(:name => name)
      end        
      
      User.build_similarity_index
    end

    describe 'User.recommend' do
      it "should exist" do
        User.recommend(10, {})
      end
      describe 'test case 1' do
        before(:each) do
          @result = User.recommend(10, 
            @users[:bob] => 10, 
            @users[:alice] => 1
          )
        end
        it "should have 3 result elements" do
          @result.should have(3).elements
        end 
        it "should be marcella, matz and barbara" do
          @result.should == [:barbara, :marcella, :matz].map { |s| @users[s] }
        end 
      end
    end
    describe 'bob#find_similar(1)' do
      attr_reader :result
      before(:each) do
        @result = @users[:bob].find_similar(1)
      end
      it "should return similar users from name index" do; end
      it "should return an array" do
        result.size.should == 1
      end
      it "should return barbara (using word count)" do
        result.first.should == users[:barbara]
      end 
    end
    describe 'bob#find_similar(1, :threshold => 0.7)' do
      before(:each) do
        @result = @users[:bob].find_similar(1, :threshold => 0.7)
      end
      it "should not find anything" do
        @result.should be_empty
      end 
    end
    describe '#similarity_index' do
      it "should return an index for :name" do
        User.similarity_index(:name).should_not be_nil
      end 
    end
    describe '#has_similarity_index' do
      class TestComputation < SimilarityEngine::Computation
        def coefficient(a,b); 1; end
      end
      class Model < ActiveRecord::Base
      end
      
      it "should pass the two instances to the computation class" do
        computation = TestComputation.new
        Model.has_similarity_index :class_index, :method => computation
        
        flexmock(computation).should_receive(:coefficient).once.with(:model1, :model2)
        
        Model.similarity_for(:model1, :model2)
      end
      it "should pass only subfields to the class if :field is present" do
        computation = TestComputation.new
        Model.has_similarity_index :class_index, :method => computation, 
          :extract_field => :some_field
        
        models = (1..2).collect { |i|
          flexmock('model').should_receive(:some_field).once.and_return("value#{i}").mock
        }
        flexmock(computation).should_receive(:coefficient).once.with('value1', 'value2')
        
        Model.similarity_for(*models)
      end
    end
  end
end