
require 'similarity_engine/computation'
require 'similarity_engine/search'
require 'similarity_engine/recommend'
require 'similarity_engine/index'
require 'similarity_coefficient'
require 'similarity_engine/similarity_engine.rb'

class ActiveRecord::Base
  include SimilarityEngine::ActiveRecordExtension
end