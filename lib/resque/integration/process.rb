# coding: utf-8

require 'pathname'

module Resque
  module Integration
    # Абстракция над стандартным классом Process, которая
    # позволяет управлять процессом с прикрепленным pid-файлом.
    #
    # @example
    #   process = Process.new('supervisor.pid')
    #   process.alive? # => false
    #   process.spawn('sleep 5') # => 21445
    #   process.send('EXIT') # => 1
    #   process.alive? # => true
    #   process.detach # => Thread spawned
    #   process.pid # => 21445
    #   process.send('KILL')
    #   process.wait
    #   process.alive? # => false
    class Process
      attr_reader :pid_file

      def initialize(pid_file)
        @pid_file = Pathname.new(pid_file.to_s)
      end

      # Returns pid of the process
      def pid
        if pid_file.exist? && (str = pid_file.read.strip) && !str.empty?
          str.to_i
        end
      end

      # Send given +signal+ to process. See Process.kill.
      def send(signal)
        pid && ::Process.kill(signal, pid)
      rescue Errno::ESRCH
        false
      end

      # Returns false if process is not started or dead
      def alive?
        pid && !!send(0)
      rescue Errno::EPERM
        true
      end

      # Spawn new process, write its pid to pid-file and return pid.
      #
      # You should #detach or #wait for process.
      def spawn(*args)
        pid = ::Process.spawn(*args)
        File.write(pid_file.to_s, pid.to_s)

        pid
      end

      # Fork a process, write its pid to pid-file and return pid
      #
      # You should #detach or #wait for process.
      def fork(&block)
        pid = ::Process.fork(&block)
        File.write(pid_file.to_s, pid.to_s)

        pid
      end

      # Detach from spawned process
      def detach
        pid && ::Process.detach(pid)
      end

      # Wait for process to die
      def wait
        pid && ::Process.wait(pid)
      rescue Errno::ECHILD
        # ignore
      ensure
        pid_file.delete if pid_file.exist?
      end
    end
  end
end