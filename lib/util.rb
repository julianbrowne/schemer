
require "json"

class Util

    def self.read_json_files(directory)
        puts "reading json files from '#{directory}'"
        docs= []
        Dir.glob("#{directory}/**/*.json") do |file|
            doc = File.read(file)
            begin
                docs << { :filename => file, :hash => JSON.parse(doc), :text => doc }
            rescue Exception => e
                abort "error: file: #{file} : #{e}"
            end
        end
        puts "#{docs.length} json files loaded"
        return docs
    end

    def self.generate_name(key, parent)
        #puts "parent: #{parent.inspect} key: #{key.inspect}"
        if parent
            levels = parent.split('.')
            if levels.last.to_i.to_s == levels.last
                key_tag = levels[0..-2].join('.')
                "#{key_tag}[n].#{key}"
            else
                levels = key.to_s.split('.')
                if levels.last.to_i.to_s == levels.last
                    key_tag = levels[0..-2].join('.')
                    key_tag = ".#{key_tag}" if key_tag != ""
                    "#{parent}#{key_tag}[n]"
                else
                    "#{parent}.#{key}"
                end
            end
        else
            levels = key.to_s.split('.')
            if levels.last.to_i.to_s == levels.last
                key_tag = levels[0..-2].join('.')
                "#{key_tag}[n]"
            else
                "#{key}"
            end
        end
    end

    def self.json_keys(obj, parent=nil)
        return [] if obj == nil
        list = []
        obj.each_with_index.find_all do |key_value, index|
            key,value = key_value
            if !value
                name = generate_name(index, parent)
                leader = parent ? "#{parent}.#{index}" : "#{index}"
                case key
                    when Array
                        list << "#{name}[]"
                        list << json_keys(key,"#{leader}")
                    when Hash
                        list << "#{name}"
                        list << json_keys(key,"#{leader}")
                    else
                        name = "#{parent}[n]"
                        name = "#{parent}#{parent ? '.' : ''}#{key}" if obj[index].inspect == 'nil'
                        list << name
                end
            else
                name = generate_name(key, parent)
                leader = parent ? "#{parent}.#{key}" : "#{key}"
                case value
                    when Array
                        list << "#{name}[]"
                        list << json_keys(value,"#{leader}")
                    when Hash
                        list << "#{name}"
                        list << json_keys(value,"#{leader}")
                    else
                        list << "#{name}"
                end
            end
        end
        return list.flatten.uniq
    end

    def self.json_values(obj, parent=nil)
        return [] if obj == nil
        list = []
        obj.each_with_index.find_all do |key_value, index|
            key,value = key_value
            if !value
                name = generate_name(index, parent)
                leader = parent ? "#{parent}.#{index}" : "#{index}"
                case key
                    when Array
                        list << json_values(key,"#{leader}")
                    when Hash
                        list << json_values(key,"#{leader}")
                    else
                        name = "#{parent}[n]"
                        name = "#{parent}#{parent ? '.' : ''}#{key}" if obj[index].inspect == 'nil'
                        v2 = key
                        v2 = nil if obj[index].inspect == 'nil'
                        list << { "#{name}" => v2 }
                end
            else
                name = generate_name(key, parent)
                leader = parent ? "#{parent}.#{key}" : "#{key}"
                case value
                    when Array
                        list << json_values(value,"#{leader}")
                    when Hash
                        list << json_values(value,"#{leader}")
                    else
                        list << { "#{name}" => value }
                end
            end
        end
        return list.flatten.uniq
    end

    def self.usage
        "usage: schemer {json_source_directory}"
    end

    def self.log(mesg)
        puts mesg
    end

    def self.debug(mesg)
        puts mesg if $debug
    end

end
