
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
