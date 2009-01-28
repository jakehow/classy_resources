require File.dirname(__FILE__) + '/../lib/classy_resources'
require 'rubygems'
require 'test/unit'
require 'context'
require 'zebra'
require 'mocha'

class Test::Unit::TestCase
  protected
    def create_post(opts = {})
      Post.create!({}.merge(opts))
    end

    def hash_for_comment(opts = {})
      {}.merge(opts)
    end

    def create_comment(opts = {})
      Comment.create!(hash_for_comment(opts))
    end

    def create_user(opts = {})
      u = User.new({}.merge(opts))
      u.save
      u
    end
end
