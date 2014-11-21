INFLUXDB_HOST = 'localhost'
INFLUXDB_API_PORT = 8086
INFLUXDB_ADMIN_CREDS = '?u=testerton&p=yupper'

# The helper functions in this file go from generic to more specific.

def api_response(root_relative_path, opts = '')
  <<-cmd.gsub('  ', '').strip
  curl \\
  \t\t#{opts} \\
  \t\t2>/dev/null \\
  \t\t'http://#{INFLUXDB_HOST}:#{INFLUXDB_API_PORT}/#{root_relative_path}'
  cmd
end

def http_code(root_relative_path, opts = '')
  api_response(root_relative_path, "-w \"%{http_code}\" -o /dev/null #{opts}")
end

def list_databases
  api_response "db#{INFLUXDB_ADMIN_CREDS}"
end

def list_cluster_admins
  api_response "cluster_admins#{INFLUXDB_ADMIN_CREDS}"
end

def list_database_users(database)
  api_response "db/#{database}/users#{INFLUXDB_ADMIN_CREDS}"
end

def name_exists_in_list(cmd, name, should_exist = true)
  describe command(cmd) do
    regex = /"name":"#{name}"/
    its(:stdout) do
      if should_exist
        should match(regex)
      else
        should_not match(regex)
      end
    end
  end
end
