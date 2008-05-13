

class User < ActiveRecord::Base
  validates_presence_of :name
  
  class BogusSimilarity < SimilarityEngine::Computation
    def coefficient(a,b)
      1
    end
  end
  
  has_similarity_index :name, 
    :method => SimilarityEngine::Coefficients::Tanamoto.new, 
    :extract_field => :letters_in_name
    
  has_similarity_index :bogus, 
    :method => BogusSimilarity.new
    
  def letters_in_name
    name.split('')
  end
end