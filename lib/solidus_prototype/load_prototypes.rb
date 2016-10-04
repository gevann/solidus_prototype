# Preload the model's prototype before any ModelController#create
# action.
#
# Adds a `create.before :load_prototype` callback to the base class
# it is included in.
module Spree
  module Prototypes

    def self.included(base)
      base.extend(ClassMethods)
      base.__send__(:create).before :load_prototype
    end

    module ClassMethods
      protected

      def load_prototype
        resource = name.underscore.split("_").first.split("/").last.singularize.to_sym
        return if params[resource][:prototype_id].blank?
        @prototype = Spree::Prototype.find(params[resource][:prototype_id])
      end
    end

    Spree::Admin::ProductsController.include(Spree::Prototypes)
  end
end
