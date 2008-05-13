module SimilarityEngine
  class Search
    
    attr_reader :klass, :instance
    
    # Create a similarity Searcher for klass.   
    #
    def initialize(instance)
      @klass = instance.class
      @instance = instance
    end
    
    # Look for similar objects to the object given. Returns first +n+ objects
    # that are similar (coeff > threshold, threshold defaults to 0)
    #
    def similar(n, options={})
      args = []
      conditions = []
      
      # lower threshold
      if options[:threshold]
        conditions << 'ifnull(sc1.coeff, sc2.coeff) >= ?'
        args << options[:threshold]
      end
      
      # Limit scan to all other objects (will not find self)
      conditions << "#{klass.table_name}.id <> ?"
      args << instance.id
      
      klass.find(
        :all, 
        :select => "#{klass.table_name}.*, 
          ifnull(sc1.coeff, sc2.coeff) as similarity",
        :joins => sanitize_sql("
          left join similarity_coefficients sc1
            on sc1.id_lo=#{klass.table_name}.id 
              and sc1.id_hi=? 
              and sc1.model_klass='#{klass}'
          left join similarity_coefficients sc2
            on sc2.id_hi=#{klass.table_name}.id 
              and sc2.id_lo=? 
              and sc2.model_klass='#{klass}'
        ", instance.id, instance.id),
        :conditions => ["(" + conditions.join(') and (') + ")", *args],
        :order => 'similarity desc',
        :limit => n 
      )
    end
    
    private 
      
      # This is a delegate to a very useful function. Note that we allow 
      # a list of arguments to be passed in and transform that into an array. 
      # You can for example write: 
      #
      #   sanitize_sql('a=?', 345)    # => 'a=345'
      #
      def sanitize_sql(*args)
        klass.send(:sanitize_sql, args)
      end
  end
end