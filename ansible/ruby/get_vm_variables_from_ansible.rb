require 'yaml'

def get_vm_variables_from_ansible(pwd, playbook)
  variable_files = []
  ansible_playbook = YAML.load_file("#{pwd}/ansible/#{playbook}.yml")
  ansible_playbook[0]["vars_files"].each {|item| if !item.respond_to?('each') then variable_files << item else variable_files << item[0] end}

  variables = {}

  variable_files.each {
    |variable_file|
    variable_yaml_file = variable_file.index('~') === 0 ? File.expand_path("#{variable_file}") : "#{pwd}/ansible/#{variable_file}"

    if File.exists?(variable_yaml_file) then
      file_variables = YAML.load_file(variable_yaml_file)

      variables.deep_merge!(file_variables)
    end
  }

  variables
end
