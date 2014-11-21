require 'serverspec_helper'
require 'influxdb_helper'

describe 'test recipe' do

  describe 'deleted config should not exist' do
    describe file('/opt/influxdb/shared/config2.toml') do
      it { should_not be_file }
    end
  end

  describe 'testdb should exist' do
    name_exists_in_list(list_databases, 'testdb')
  end

  describe 'testdb2 should not exist' do
    name_exists_in_list(list_databases, 'testdb2', false)
  end

  describe 'tester_cluster_admin should exist' do
    name_exists_in_list(list_cluster_admins, 'tester_cluster_admin')
  end

  describe 'tester_cluster_admin2 should not exist' do
    name_exists_in_list(list_cluster_admins, 'tester_cluster_admin2', false)
  end

  describe 'deleted database users should not exist' do
    describe command(list_database_users('testdb')) do
      its(:stdout) do
        %w(
          tester_db_user2
          tester_db_admin2
          tester_read_only_user2
          tester_write_only_user2
        ).each do |name|
          should_not match(/"name":"#{name}"/)
        end
      end
    end
  end

  describe 'tester_db_user should exist' do
    name_exists_in_list(list_database_users('testdb'), 'tester_db_user')
  end

  describe 'tester_db_admin should exist as an admin' do
    describe command(list_database_users('testdb')) do
      its(:stdout) do
        should match(/"name":"tester_db_admin"[^}]*"isAdmin":true/)
      end
    end

    describe 'can create a user' do
      cmd = http_code(
        'db/testdb/users?u=tester_db_admin&p=tester',
        '-d \'{"name":"serverspec","password":"tester"}\'')
      describe command(cmd) do
        its(:stdout) { should eq '200' }

        describe 'serverspec user should exist' do
          name_exists_in_list(list_database_users('testdb'), 'serverspec')
        end
      end
    end

    describe 'can delete a user' do
      cmd = http_code(
        'db/testdb/users/serverspec?u=tester_db_admin&p=tester',
        '-X DELETE')
      describe command(cmd) do
        its(:stdout) { should eq '200' }

        describe 'serverspec user should not exist' do
          name_exists_in_list(
            list_database_users('testdb'), 'serverspec', false)
        end
      end
    end
  end

  describe 'Write a test point' do
    cmd = http_code(
      "db/testdb/series#{INFLUXDB_ADMIN_CREDS}",
      '-X POST -d \'[{"name":"serverspec_test","columns":["val"],'\
      '"points":[[3]]}]\'')
    describe command(cmd) do
      its(:stdout) { should eq '200' }
    end
  end

  describe 'tester_read_only_user should exist with read only privileges' do
    describe command(list_database_users('testdb')) do
      its(:stdout) do
        should match(/"name":"tester_read_only_user"[^{}]*"writeTo":" "/)
        should match(/"name":"tester_read_only_user"[^{}]*"readFrom":".*"/)
      end
    end

    describe 'can read from testdb serverspec_test series' do
      cmd = http_code(
        'db/testdb/series?u=tester_read_only_user&p=tester',
        '-G --data-urlencode \'q=select * from serverspec_test\'')
      describe command(cmd) do
        its(:stdout) { should eq '200' }
      end

      # Delete test series.
      cmd = http_code(
        "db/testdb/series/serverspec_test#{INFLUXDB_ADMIN_CREDS}",
        '-X DELETE')
      describe command(cmd) do
        its(:stdout) { should eq '204' }
      end
    end

    describe 'cannot write to testdb serverspec_test series' do
      cmd = http_code(
        'db/testdb/series?u=tester_read_only_user&p=tester',
        '-X POST -d \'[{"name":"serverspec_test","columns":["val"],'\
          '"points":[[23]]}]\'')
      describe command(cmd) do
        its(:stdout) { should eq '403' }
      end
    end
  end

  describe 'tester_write_only_user should exist with read only privileges' do
    describe command(list_database_users('testdb')) do
      its(:stdout) do
        should match(/"name":"tester_write_only_user"[^{}]*"writeTo":".*"/)
        should match(/"name":"tester_write_only_user"[^{}]*"readFrom":" "/)
      end
    end

    describe 'cannnot read from testdb serverspec_test series' do
      cmd = http_code(
        'db/testdb/series?u=tester_write_only_user&p=tester',
        '-G --data-urlencode \'q=select * from serverspec_test\'')
      describe command(cmd) do
        its(:stdout) { should eq '403' }
      end
    end

    describe 'can write to testdb serverspec_test series' do
      cmd = http_code(
        'db/testdb/series?u=tester_write_only_user&p=tester',
        '-X POST -d \'[{"name":"serverspec_test","columns":["val"],'\
          '"points":[[23]]}]\'')
      describe command(cmd) do
        its(:stdout) { should eq '200' }
      end
    end
  end

  describe 'Delete test series.' do
    cmd = http_code(
      "db/testdb/series/serverspec_test#{INFLUXDB_ADMIN_CREDS}",
      '-X DELETE')
    describe command(cmd) do
      its(:stdout) { should eq '204' }
    end
  end

end
