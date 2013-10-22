class LogUtil
 	@logfile = nil
	@errfile = nil
	def self.cleanup
		@logfile.close()
	end

	def initialize(_filename,_errfile)
		@logfile = open(_filename, "a")		
		@errfile = open(_errfile, "a")		
		ObjectSpace.define_finalizer(self) {
			@logfile.close()
			@errfile.close()
		}
	end

	def write(_log)
		time = DateTime.now
		@logfile.write(sprintf("[%d-%d-%d %d:%d:%d]",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
		@errfile.write("\n")
		@logfile.write(_log + "\n")
	end

	def writeError(_log)
		time = DateTime.now
		@errfile.write(sprintf("[%d-%d-%d %d:%d:%d]",time.year,time.mon,time.mday,time.hour,time.min,time.sec))
		@errfile.write("\n")
		@errfile.write(_log + "\n")
	end
end
