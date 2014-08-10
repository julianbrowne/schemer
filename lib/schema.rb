
require "json"

class Schema

    def initialize(h={})
        @schema=Hash.new { |h, k| h[k] = Hash.new(&h.default_proc) }
        @schema.merge! JSON.parse(h.to_json) # ensures consistent string keys
        @values = []
    end

    def extract_values(obj=@schema, parent=nil)
        list = []
        obj.each_with_index.find_all do |kv,i|
            k,v=kv
            if !v
                v=k; k=i
            end
            leader = parent ? "#{parent}.#{k}" : "#{k}"
            if v.class==Hash||v.class==Array
                list << extract_values(v,leader)
            else
                if parent
                    levels = parent.split('.')
                    if levels.last.to_i.to_s == levels.last
                        # array index so snip off end
                        list << {"#{levels[0..-2].join}.#{k}" => v}
                    else
                        list << {"#{leader}" => v}
                    end
                else
                    list << {"#{leader}" => v}
                end
            end
        end
        return list.flatten
    end

    def extractor(obj)
        @values.concat extract_values(obj)
    end

    def values_for(field)
        r = []
        matches = @values.find_all { |v| v.has_key?(field) }
        matches.each { |v| r << v[field] }
        r.uniq.join(',')
    end

    def all_values
        @values
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