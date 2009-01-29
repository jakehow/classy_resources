dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << dir unless $LOAD_PATH.include?(dir)
require 'classy_resources/mime_type'
require 'classy_resources/post_body_params'

module ClassyResources
  def class_for(resource)
    resource.to_s.singularize.classify.constantize
  end

  def define_resource(*options)
    ResourceBuilder.new(self, *options)
  end

  def load_collection(resource, parent = nil)
    parent.nil? ? load_shallow_collection(resource) : load_nested_collection(resource, parent)
  end

  def create_object(resource, object_params, parent = nil)
    parent.nil? ? create_shallow_object(resource, object_params) : create_nested_object(resource, object_params, parent)
  end

  def load_parent_object(parent)
    load_object(parent, params[parent_id_name(parent)])
  end

  def parent_id_name(parent)
    :"#{parent.to_s.singularize}_id"
  end

  def collection_url_for(resource, format, parent = nil)
    parent = parent.nil? ? "" : "/#{parent}/:#{parent_id_name(parent)}"
    [parent, "/#{resource}.#{format}"].join
  end

  def object_route_url(resource, format)
    "/#{resource}/:id.#{format}"
  end

  def object_url_for(resource, format, object)
    "/#{resource}/#{object.id}.#{format}"
  end

  def set_content_type(format)
    content_type Mime.const_get(format.to_s.upcase).to_s
  end

  def serialize(object, format)
    object.send(:"to_#{format}")
  end

  class ResourceBuilder
    attr_reader :resources, :options, :main, :formats

    def initialize(main, *args)
      @main      = main
      @options   = args.pop if args.last.is_a?(Hash)
      @resources = args
      @formats   = options[:formats] || :xml

      build!
    end

    def build!
      resources.each do |r|
        [*formats].each do |f|
          [:member, :collection].each do |t|
            [*options[t]].each do |v|
              send(:"define_#{t}_#{v}", r, f) unless v.nil?
            end
          end
        end
      end
    end

    protected
      def define_collection_get(resource, format)
        parent = options[:parent]
        get collection_url_for(resource, format, parent) do
          set_content_type(format)
          serialize(load_collection(resource, parent), format)
        end
      end
      
      def define_collection_post(resource, format)
        parent = options[:parent]
        post collection_url_for(resource, format, parent) do
          set_content_type(format)
          object = create_object(resource, params[resource.to_s.singularize] || {}, parent)
          redirect object_url_for(resource, format, object)
        end
      end

      def define_member_get(resource, format)
        get object_route_url(resource, format) do
          set_content_type(format)
          object = load_object(resource, params[:id])
          serialize(object, format)
        end
      end

      def define_member_put(resource, format)
        put object_route_url(resource, format) do
          set_content_type(format)
          object = load_object(resource, params[:id])
          update_object(object, params[resource.to_s.singularize])
          serialize(object, format)
        end
      end

      def define_member_delete(resource, format)
        delete object_route_url(resource, format) do
          set_content_type(format)
          object = load_object(resource, params[:id])
          destroy_object(object)
          ""
        end
      end
  end
end

include ClassyResources

