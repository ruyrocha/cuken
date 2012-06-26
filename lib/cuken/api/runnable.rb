require 'etc'

module Cuken
  module Api
    module Runnable
      include Etc

      EXECUTOR_INDICES = {'u'=>2,'g'=>5,'o'=>8}

      def get_bin_permissions(file,file_stats = nil)
        file_stats = ::File.stat(file) unless file_stats
        file_stats.mode.to_s(2)[-9..-1]
      end

      def get_hash_permissions(file,file_stats=nil)
        perms = get_bin_permissions(file,file_stats)
        perm_hash = {}
        perm_hash[:user] = (perms[EXECUTOR_INDICES['u']] == '1')
        perm_hash[:group] = (perms[EXECUTOR_INDICES['g']] == '1')
        perm_hash[:other] = (perms[EXECUTOR_INDICES['o']] == '1')
        perm_hash
      end

      def check_executable_by_executors(file,executors='u')
        executors.downcase!
        permissions = ::File.stat(file).mode.to_s(2)[-9..-1]
        executors.split("").each do |char|
          permissions[EXECUTOR_INDICES[char]].should be_eql('1')
        end
      end

      def check_setuid(file)
        ::File.stat(file).setuid?
      end

      def check_setgid(file)
        ::File.stat(file).setgid?
      end

      def check_executable_by_user(file,user)
        file_info = ::File.stat(file)
        perms = get_hash_permissions(file,file_info)
        return if user == "root" and perms.values.include?(true)
        #check if the user owns the file
        file_user = Etc.getpwuid(file_info.uid).name
        return if perms[:user] and user == file_user
        #check if the user is in the proper group
        file_group = Etc.getgrgid(file_info.gid)
        return if perms[:group] and file_group.mem.include?(user)
        #check if anyone can execute
        return if perms[:other]
        #otherwise, we fail
        false.should be_true
      end

      def check_executables(executables)
        executables.each do |executable|
          if executable.keys.include?('setuid')
            check_setuid(executable['file']).should be_eql(executable['setuid'].to_bool)
          end
          if executable.keys.include?('setgid')
            check_setgid(executable['file']).should be_eql(executable['setgid'].to_bool)
          end
          if executable.keys.include?('executors')
            check_executable_by_executors(executable['file'],executable['executors'])
          end
          if executable.keys.include?('user')
            check_executable_by_user(executable['file'],executable['user'])
          end
        end
      end

      #checks a command's response
      #WARNING: STDERR is redirected to STDOUT
      def check_response(command,expected,contains=false)
        response = `#{command} 2>&1`.strip
        if contains
          response.should be_include(expected)
        else
          response.should be_eql(expected.strip)
        end
      end

    end
  end
end
