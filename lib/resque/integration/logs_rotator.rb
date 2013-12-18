# coding: utf-8
module Resque
  module Integration
    class LogsRotator
      class << self

        # Перенаправить стандартный вывод в файл
        def redirect_std
          log_path = File.join(::Resque.config.root, ::Resque.config.log_file)
          STDOUT.reopen File.open(log_path, 'a')
          STDERR.reopen File.open(log_path, 'a')
          STDOUT.sync = STDERR.sync = true
        end

        def register_hup_signal
          Signal.trap('HUP') { ::Resque::Integration::LogsRotator.reopen_logs }
        end

        # Переоткрытие всех логов
        #
        # @see Unicorn::Utils
        def reopen_logs
          to_reopen = []
          nr = 0
          ObjectSpace.each_object(File) { |fp| is_log?(fp) and to_reopen << fp }

          to_reopen.each do |fp|
            orig_st = begin
              fp.stat
            rescue IOError, Errno::EBADF # race
              next
            end

            begin
              b = File.stat(fp.path)
              next if orig_st.ino == b.ino && orig_st.dev == b.dev
            rescue Errno::ENOENT
            end

            begin
              # stdin, stdout, stderr are special.  The following dance should
              # guarantee there is no window where `fp' is unwritable in MRI
              # (or any correct Ruby implementation).
              #
              # Fwiw, GVL has zero bearing here.  This is tricky because of
              # the unavoidable existence of stdio FILE * pointers for
              # std{in,out,err} in all programs which may use the standard C library
              if fp.fileno <= 2
                # We do not want to hit fclose(3)->dup(2) window for std{in,out,err}
                # MRI will use freopen(3) here internally on std{in,out,err}
                fp.reopen(fp.path, "a")
              else
                # We should not need this workaround, Ruby can be fixed:
                #    http://bugs.ruby-lang.org/issues/9036
                # MRI will not call call fclose(3) or freopen(3) here
                # since there's no associated std{in,out,err} FILE * pointer
                # This should atomically use dup3(2) (or dup2(2)) syscall
                File.open(fp.path, "a") { |tmpfp| fp.reopen(tmpfp) }
              end

              fp.sync = true
              fp.flush # IO#sync=true may not implicitly flush
              new_st = fp.stat

              # this should only happen in the master:
              if orig_st.uid != new_st.uid || orig_st.gid != new_st.gid
                fp.chown(orig_st.uid, orig_st.gid)
              end

              nr += 1
            rescue IOError, Errno::EBADF
              # not much we can do...
            end
          end
          nr
        end

        private

        # @see Unicorn::Utils
        def is_log?(fp)
          append_flags = File::WRONLY | File::APPEND

          ! fp.closed? &&
            fp.stat.file? &&
            fp.sync &&
            (fp.fcntl(Fcntl::F_GETFL) & append_flags) == append_flags
          rescue IOError, Errno::EBADF
            false
        end

      end
    end
  end
end