def get_ansible_version
  output = `ansible --version`
  re = /ansible ([\d\.]+)/

  match = output.match re
  version = match[1]

  return version
end
