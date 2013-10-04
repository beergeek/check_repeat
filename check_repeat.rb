#!/opt/puppet/bin/ruby

require 'puppet'
require 'yaml'

Puppet.initialize_settings
#get modules path
$mod_dir = Puppet.settings[:modulepath].split(':')

#global variables
$include_variables = []
$resource_variables = {}

#Class to search for resources, defined resources and classes
def search_class(module_name)
  file_array = module_name.split('::')

  #search module path for the class
  $mod_dir.each do |y|
    if File.directory?("#{y}/#{file_array[0]}")
      @filename = "#{y}/#{file_array[0]}"
      break
    end
  end

  #did we find the class?
  if defined? @filename
    @filename = "#{@filename}/manifests"
    #if base case make the path correct, else fill out the whole path with sub classes
    if file_array.count == 1
      @filename = "#{@filename}/init"
    else
      file_array.shift
      file_array.each do |k|
        @filename = "#{@filename}/#{k}"
      end
    end
    @filename = "#{@filename}.pp"
  else
    #Error if class cannot be found
    puts "Cannot find class"
    return 0
  end

  #Determine if the file actually exists
  if not File.exists?(@filename)
    puts "No such class"
    return 1
  end

  #Read the file
  f = File.open(@filename,'r')
  g =f.readlines

  #loop through the lines and find recourses and included classes
  g.each do |val|
    # find resources
    if n = val.match(/^[ \t]*[a-z:].*{[ \t]*['\"].*['\"]:/)
      out_val = n[0].sub(/"/,"'").gsub(/\s+/,"")
      #Determine if we have a duplicate resource and display if we do
      if $resource_variables.has_key?(out_val)
        puts "\n******** DEPLICATE FOUND! ********"
        $resource_variables[out_val] = $resource_variables[out_val].push(module_name)
        puts "#{out_val} defined in these classes: #{$resource_variables[out_val]}"
      else
        #Add resource to hash with name of containing class
        $resource_variables[out_val] = [module_name]
      end
      next
    end
    # find included classes
    if m = val.match(/^[ \t]*include[ \t]*.*/)
      out_val = m[0]
      x = m[0].gsub(/^[ \t]*include[ \t]/,'')
      #if class is not in our array add it and then call this class to iterate that included class
      if not $include_variables.include?(x)
        $include_variables.push(x.strip)
        search_class(x)
      end
    end
  end
end

raise PuppetError, "Need only one argument" if ARGV.length != 1
search_class(ARGV[0])
puts "\n\nClasses and Defined Resources Checked:"
puts $include_variables.sort
puts "\n\nResources Found and Source:"
puts $resource_variables.sort.to_yaml
