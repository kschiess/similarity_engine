
class SimilarityCoefficient < ActiveRecord::Base
  validates_presence_of :model_klass
  validates_presence_of :id_lo
  validates_presence_of :id_hi
  validates_presence_of :coeff
  validates_presence_of :updated_at
  
  before_validation_on_create :set_updated_at
  
  private
    
    def set_updated_at
      self.updated_at = Time.now
    end
end