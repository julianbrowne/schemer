
dir = File.dirname(__FILE__)
$: << File.expand_path("#{dir}")

require "json"
require "util"

class Schema

    def initialize(h={})
        @schema=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
        @schema.merge! JSON.parse(h.to_json) # ensures consistent string keys
        @values = []
        @keys = []
    end

    def extractor(obj)
        @keys.concat Util.json_keys(obj)
        @values.concat Util.json_values(obj)
    end

    def values_for(key)
        r = []
        matches = @values.find_all { |v| v.has_key?(key) }
        matches.each { |v| r << v[key] }
        r.uniq
    end

    def all_keys
        @keys.uniq.sort
    end

    def all_values
        @values.uniq
    end

    def fetch_key(key, hsh=@schema)
        if hsh.respond_to?(:key?) && hsh.key?(key)
            return hsh[key].is_a?(Hash) ? Schema.new(hsh[key]) : hsh[key]
        elsif hsh.respond_to?(:each)
            r = nil
            hsh.find do |*a|
                r=fetch_key(key, a.last)
            end
            return r.is_a?(Hash) ? Schema.new(r) : r
        end
    end

    def set_key(key, value, hsh=@schema)
        if hsh.respond_to?(:key?) && hsh.key?(key)
            hsh[key] = value
        elsif hsh.respond_to?(:each)
            r = nil
            hsh.find do |*a|
                r=fetch_key(key, a.last)
            end
            r = value
        end
    end

    def has_key?(path)
        return nil if !path
        *parent, key = path.split('.')
        obj = (parent==[]) ? @schema: retrieve(parent.join('.'))
        return false if obj == nil
        return false if obj.class != Hash
        obj.has_key? key
    end

    def retrieve(path)
        result = path.split('.').inject(@schema) { |m,o| m[o] if m.class==Hash }
        return (result == {}) ? nil : result
    end

    def insert(path, value)
        *parent, last = path.split('.')
        insert_key last, value, parent.join('.')
    end

    def insert_key(key, value, path=nil)
        if path == [] || path == nil
            @schema[key] = value
        else
            levels = path.split('.')
            levels.inject(@schema) { |h, k| h[k] }[key] = value
        end
    end

    def to_s
        @schema.inspect
    end

    def to_json
        @schema.to_json
    end

end