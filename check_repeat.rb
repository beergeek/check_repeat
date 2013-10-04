#!/opt/puppet/bin/ruby

require 'puppet'
Puppet.initialize_settings
$mod_dir = Puppet.settings[:modulepath].split(':')
$include_variables = []
$resource_variables = {}

#!/opt/puppet/bin/ruby

require 'puppet'
Puppet.initialize_settings
$mod_dir = Puppet.settings[:modulepath].split(':')
$include_variables = []
$resource_variables = {}
require 'puppet'
Puppet.initialize_settings
$mod_dir = Puppet.settings[:modulepath].split(':')
$include_variables = []
$resource_variables = {}

def search_class(module_name)
  file_array = module_name.split('::')
  $mod_dir.each do |y|
    if File.directory?("#{y}/#{file_array[0]}")
audit/                   maillog                  pe-puppet-dashboard/     VBoxGuestAdditions.log
    if File.directory?("#{y}/#{file_array[0]}")
      @filename = "#{y}/#{file_array[0]}"
$mod_dir = Puppet.settings[:modulepath].split(':')
$include_variables = []
$resource_variables = {}

def search_class(module_name)
  file_array = module_name.split('::')
  $mod_dir.each do |y|
    if File.directory?("#{y}/#{file_array[0]}")
      @filename = "#{y}/#{file_array[0]}"
      break
    end
  end
  if defined? @filename
boot.log                 maillog-20131003         pe-puppetdb/             wtmp
    @filename = "#{@filename}/manifests"
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
    puts "Cannot find class"
    return 0
  end
  if not File.exists?(@filename)
    puts "No such class"
    return 1
  end
  f = File.open(@filename,'r')
  g =f.readlines
  g.each do |val|
    if n = val.match(/^[ \t]*[a-z:].*{[ \t]*['\"].*['\"]:/)
      out_val = n[0].sub(/"/,"'").gsub(/\s+/,"")
      if $resource_variables.has_key?(out_val)
        puts "\n******** DEPLICATE FOUND! ********"
        $resource_variables[out_val] = $resource_variables[out_val].push(module_name)
        puts "#{out_val} defined in these classes: #{$resource_variables[out_val]}"
      else
        $resource_variables[out_val] = [module_name]
      end
      next
    end
    if m = val.match(/^[ \t]*include[ \t]*.*/)
      out_val = m[0]
      x = m[0].gsub(/^[ \t]*include[ \t]/,'')
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
