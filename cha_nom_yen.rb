def inputs_are_valid
  ARGV.each do |argument|
    if !argument.include?("--")
      raise Exception.new("Incorrect argument parameters. the correct format is '--property=type' ")
    end
  end
end

inputs_are_valid

def class_name
  ARGV.each do |r|
    if r.include?("model")
      model = r.partition('=').last
      return model
    end
  end
end

def is_valid_property(argument)
  if !argument.to_s.include?("model") && !argument.to_s.include?("database")
    return true
  end
  return false
end

def database_type
  ARGV.each do |r|
    if r.include?("database")
      db = r.partition('=').last
      return db
    end
  end
end

def varDeclarations # returns  astring
 response_string = ""
 regex = /\--(.*?)=/
  ARGV.each  do |argument|
    property_name = argument.slice(regex, 1)
    property_type = argument.partition('=').last
    if is_valid_property(property_name)
      response_string << "    var #{property_name}:#{property_type} \n"
    end
  end
  return response_string
end

def init_method
  regex = /\--(.*?)=/
  response_string = "    init("
  ARGV.each_with_index  do |argument, index|
    property_name = argument.slice(regex, 1)
    property_type = argument.partition('=').last
    suffix = ARGV.count == index + 1 ? ")" :  ", "
    if is_valid_property(property_name)
      response_string << "#{property_name}: #{property_type}#{suffix} "
    end
  end
  response_string << " { \n"
  response_string << init_assignments
  return response_string
end

def init_assignments
  regex = /\--(.*?)=/
  response_string = ""
  ARGV.each_with_index  do |argument, index|
    property_name = argument.slice(regex, 1)
    suffix = ARGV.count == index + 1 ? "" :  "\n"
    if is_valid_property(property_name)
      response_string << "        self.#{property_name} = #{property_name} #{suffix}"
    end
  end
  response_string << "\n    }"
  return response_string
end

database = database_type.to_s + "Model"
import_statement = "Fluent" + database_type.to_s
File.open("Sources/App/Models/#{class_name}.swift", "w") {|f| f.write("import Foundation \nimport Vapor \n#{import_statement} \n\nclass #{class_name}: #{database} {
    var id:Int?
#{varDeclarations}
#{init_method}
}") }
