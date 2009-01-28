module ClassyResources
  module ActiveRecord
    def load_collection(resource, parent = nil)
      parent.nil? ? load_normal_collection(resource) : load_parent_collection(resource, parent)
    end

    def load_normal_collection(resource)
      class_for(resource).all
    end

    def load_parent_collection(resource, parent)
      find_object(parent, params[parent_id_name(parent)]).send(resource)
    end

    def create_object(resource, params)
      class_for(resource).create!(params)
    end

    def find_object(resource, id)
      class_for(resource).find(id)
    end

    def update_object(object, params)
      object.update_attributes(params)
    end

    def destroy_object(object)
      object.destroy
    end
  end
end

include ClassyResources::ActiveRecord

