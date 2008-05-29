module SimilarityEngine
  class Recommend
    attr_reader :klass
    
    # Create a similarity Searcher for klass.   
    #
    def initialize(klass)
      @klass = klass
    end
    
    def recommend(n, prefs)
       # select users.*, 
        #   sum(coeff * (
        #     case if(id_lo=users.id, id_hi, id_lo)
        #       when 1 then 1
        #       when 2 then 10
        #     end
        #   )) as summed_scored_coeff
        #   from users
        #   inner join similarity_coefficients
        #     on (id_lo=users.id or id_hi=users.id) and
        #        (id_lo in (1, 2) or id_hi in (1, 2))
        #   where users.id not in (1, 2) 
        #   group by users.id
        
      pref_object_ids = prefs.keys.map(&:id)
      
      whens = prefs.map { |obj, score| "when #{obj.id} then #{score}"}.join("\n")
      pref_score = %Q{(
        case if(id_lo=#{klass.table_name}.id, id_hi, id_lo)
          #{whens}
        end
      )}
      
      klass.find( :all, 
        :select => "users.*, sum(coeff * #{pref_score}) as summed_scored_coeff",
        :joins => sanitize_sql(
          %Q{
            inner join similarity_coefficients on 
            model_klass='#{klass}' and 
            (id_lo=#{klass.table_name}.id or id_hi=#{klass.table_name}.id) and 
            (id_lo in (?) or id_hi in (?))
          }, 
          pref_object_ids, pref_object_ids
        ),
        :conditions => ["#{klass.table_name}.id not in (?)", pref_object_ids],
        :group => "users.id", 
        :order => "summed_scored_coeff desc",
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