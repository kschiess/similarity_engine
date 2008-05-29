require File.join(File.dirname(__FILE__), 'spec_helper')

require 'similarity_engine/index'
require 'similarity_coefficient'
include SimilarityEngine

describe Index do
  require 'fixtures/user_scenario_schema'
  require 'fixtures/user_scenario_models'
  
  attr_reader :index, :users
  before(:each) do
    @users = {}
    
    # Create a few users for us to work with
    %w{bob alice marcella matz barbara}.each do |name|
      @users[name.to_sym] = User.create!(:name => name)
    end
    
    @index = Index.new(User, SimilarityEngine::ProgressTracker.new)
  end

  describe '#build' do
    before(:each) do
      index.build
    end
    it "should have created at least fact(5)/fact(2)/fact(3) coefficients (number of elements above the diagonale in a nxn matrix)" do
      SimilarityCoefficient.count.should >= 10
    end
  end
  
  it "should allow look up of coefficients" do
    lambda {
      index.update_similarity_coefficient users[:bob], users[:barbara]
    }.should change(SimilarityCoefficient, :count).by(1)
    
    index.lookup( users[:bob], users[:barbara] ).coeff.should == 0.625
  end 
  it "should return nil if lookup fails" do
    index.lookup( users[:bob], users[:barbara] ).should be_nil
  end 
end