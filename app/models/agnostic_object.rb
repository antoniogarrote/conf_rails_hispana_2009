class AgnosticObject < Persistence::Base

  def self.agnostic_accessor property
#    class_eval <<__END
#       def #{property.to_s}
#         get(#{property.to_sym})
#       end
#
#       def #{property.to_s}= value
#         set(#{property.to_sym},value)
#       end
#__END
  end
end
