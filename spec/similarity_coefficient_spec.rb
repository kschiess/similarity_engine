require File.join(File.dirname(__FILE__), 'spec_helper')

require 'similarity_coefficient'

describe 'SimilarityCoefficient' do
  attr_reader :coefficient
  before(:each) do
    @coefficient = SimilarityCoefficient.create!(
      :model_klass => 'Test', 
      :id_lo => 1, 
      :id_hi => 2, 
      :coeff => 1.0
    )
  end
  it "should validate the test fixture" do; end
end