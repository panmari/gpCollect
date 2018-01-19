# Monkey patching Arel so we can call expression.concat for concatenating stuff.
module Arel
  module Nodes
    class Concatenation < ::Arel::Nodes::InfixOperation
      def initialize(left, right)
        super(:"||", left, right)
      end
    end
  end

  module Expression
    include ::Arel::OrderPredications

    def concat(other)
      Nodes::Concatenation.new self, other
    end
  end

  module Attributes
    class Attribute
      include Arel::Expression
    end
  end

  module Nodes
    class InfixOperation
      include Arel::Expression
    end
  end
end
